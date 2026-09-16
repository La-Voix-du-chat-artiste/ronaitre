class WholeAccountShareLinks < ActiveRecord::Migration[8.1]
  def change
    change_column_null :share_links, :track_id, true
  end
end
