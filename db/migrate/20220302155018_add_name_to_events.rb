class AddNameToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :name, :string
  end
end
