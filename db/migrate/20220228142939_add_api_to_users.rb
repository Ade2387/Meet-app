class AddApiToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :API_link, :string
  end
end
