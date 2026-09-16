class CreateConversations < ActiveRecord::Migration[8.1]
  def change
    create_table :conversations do |t|
      t.references :membership, null: false, foreign_key: true
      t.references :a, null: false, foreign_key: { to_table: :users }
      t.references :b, null: false, foreign_key: { to_table: :users }
      t.datetime :last_message_at

      t.timestamps
    end
    add_index :conversations, [ :a_id, :b_id ], unique: true

    create_table :messages do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.text :body, null: false
      t.string :channel, null: false, default: "site"
      t.datetime :read_at

      t.timestamps
    end
    add_index :messages, [ :conversation_id, :created_at ]
  end
end
