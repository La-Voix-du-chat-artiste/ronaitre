namespace :db do
  desc "Backup all SQLite databases (VACUUM INTO) to BACKUP_DIR (default: storage/backups). Keeps BACKUP_KEEP (default: 7) most recent sets."
  task backup: :environment do
    backup_dir = Pathname.new(ENV.fetch("BACKUP_DIR") { Rails.root.join("storage/backups") })
    keep = ENV.fetch("BACKUP_KEEP", "7").to_i
    stamp = Time.current.strftime("%Y%m%d-%H%M%S")
    target = backup_dir.join(stamp)
    FileUtils.mkdir_p(target)

    databases = (ENV["BACKUP_DATABASES"]&.split(",") || %w[
      storage/production.sqlite3
      storage/production_cache.sqlite3
      storage/production_queue.sqlite3
      storage/production_cable.sqlite3
    ]).select { |path| Rails.root.join(path).exist? }

    raise "No production SQLite databases found to back up." if databases.empty?

    databases.each do |path|
      source_path = Rails.root.join(path)
      destination_path = target.join(File.basename(path))
      source = SQLite3::Database.new(source_path.to_s, readonly: true)
      destination_path.to_s
      source.execute("VACUUM INTO ?", destination_path.to_s)
      source.close
      puts "Backed up #{path} -> #{destination_path}"
    end

    sets = Dir.children(backup_dir).grep(/\A\d{8}-\d{6}\z/).sort
    sets[0...-keep].each { |old| FileUtils.rm_rf(backup_dir.join(old)) } if sets.size > keep

    puts "Backup complete: #{target} (#{databases.size} databases, keeping #{keep} sets)"
  end
end
