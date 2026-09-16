class CreateConnections < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :role, :string, default: "suivi", null: false
    add_column :users, :bio, :text
    add_index :users, :role

    create_table :memberships do |t|
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.references :member, null: false, foreign_key: { to_table: :users }
      t.string :kind, null: false, default: "proche"
      t.string :status, null: false, default: "invited"
      t.string :invite_token

      t.timestamps
    end
    add_index :memberships, [ :owner_id, :member_id, :kind ], unique: true, where: "status != 'revoked'"
    add_index :memberships, :invite_token, unique: true
    add_index :memberships, :status

    create_table :grants do |t|
      t.references :membership, null: false, foreign_key: true
      t.references :track, null: false, foreign_key: true
      t.boolean :can_view_details, default: false, null: false
      t.boolean :can_message, default: true, null: false

      t.timestamps
    end
    add_index :grants, [ :membership_id, :track_id ], unique: true
  end
end
