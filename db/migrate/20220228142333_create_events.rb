class CreateEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :events do |t|
      t.datetime :start
      t.datetime :end
      t.text :description
      t.integer :duration
      t.string :external_user_emails

      t.timestamps
    end
  end
end
