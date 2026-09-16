class CreateNotificationsAndChat < ActiveRecord::Migration[8.1]
  def change
    create_table :notification_prefs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :event, null: false
      t.boolean :in_app, default: true, null: false
      t.boolean :email, default: true, null: false
      t.boolean :sms, default: false, null: false

      t.timestamps
    end
    add_index :notification_prefs, [ :user_id, :event ], unique: true

    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :event, null: false
      t.json :payload, default: {}
      t.datetime :read_at

      t.timestamps
    end
    add_index :notifications, [ :user_id, :read_at ]

    create_table :chat_threads do |t|
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    create_table :chat_messages do |t|
      t.references :chat_thread, null: false, foreign_key: true
      t.string :role, null: false
      t.text :content, null: false

      t.timestamps
    end
    add_index :chat_messages, [ :chat_thread_id, :created_at ]

    create_table :csapa_facilities do |t|
      t.string :name, null: false
      t.string :kind
      t.string :address
      t.string :zip
      t.string :city
      t.string :dept
      t.string :phone
      t.string :hours
      t.string :source, default: "seed"

      t.timestamps
    end
    add_index :csapa_facilities, [ :city, :dept ]
  end
end
