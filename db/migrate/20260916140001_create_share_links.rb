class CreateShareLinks < ActiveRecord::Migration[8.1]
  def change
    create_table :share_links do |t|
      t.references :user, null: false, foreign_key: true
      t.references :track, null: false, foreign_key: true
      t.string :token, null: false
      t.string :password_digest
      t.datetime :expires_at
      t.datetime :revoked_at
      t.integer :views_count, default: 0, null: false
      t.datetime :last_viewed_at

      t.timestamps
    end
    add_index :share_links, :token, unique: true
  end
end
