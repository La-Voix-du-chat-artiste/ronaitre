class AddProfileToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :display_name, :string
    add_column :users, :anonymous, :boolean, default: false, null: false
    add_column :users, :phone, :string
  end
end
