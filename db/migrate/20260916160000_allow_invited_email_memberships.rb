class AllowInvitedEmailMemberships < ActiveRecord::Migration[8.1]
  def change
    change_column_null :memberships, :member_id, true
    add_column :memberships, :invited_email, :string
    add_index :memberships, :invited_email
  end
end
