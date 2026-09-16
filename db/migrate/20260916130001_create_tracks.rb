class CreateTracks < ActiveRecord::Migration[8.1]
  def change
    create_table :presets do |t|
      t.string :slug, null: false
      t.string :name, null: false
      t.string :icon, default: "circle"
      t.string :color, default: "primary"
      t.string :unit_word
      t.json :milestones, default: []
      t.string :guide_slug
      t.boolean :active, default: true, null: false

      t.timestamps
    end
    add_index :presets, :slug, unique: true

    create_table :tracks do |t|
      t.references :user, null: false, foreign_key: true
      t.references :preset, null: true, foreign_key: true
      t.string :name, null: false
      t.string :color, default: "primary"
      t.datetime :quit_at, null: false
      t.integer :status, default: 0, null: false
      t.json :preset_config, default: {}
      t.integer :personal_best_seconds, default: 0, null: false
      t.integer :paused_seconds
      t.datetime :closed_at

      t.timestamps
    end
    add_index :tracks, [ :user_id, :status ]

    create_table :consumptions do |t|
      t.references :track, null: false, foreign_key: true
      t.datetime :occurred_at, null: false
      t.decimal :quantity, precision: 10, scale: 2
      t.string :unit
      t.text :note

      t.timestamps
    end
    add_index :consumptions, [ :track_id, :occurred_at ]

    create_table :milestones do |t|
      t.references :track, null: false, foreign_key: true
      t.string :label, null: false
      t.integer :seconds, null: false
      t.datetime :reached_at
      t.datetime :celebrated_at

      t.timestamps
    end
    add_index :milestones, [ :track_id, :seconds ], unique: true
  end
end
