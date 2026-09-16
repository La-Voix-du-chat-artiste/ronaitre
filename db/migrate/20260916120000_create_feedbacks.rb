class CreateFeedbacks < ActiveRecord::Migration[8.1]
  def change
    create_table :feedbacks do |t|
      t.string :kind, null: false
      t.string :email
      t.text :body, null: false
      t.references :user, null: true, foreign_key: true

      t.timestamps
    end
  end
end
