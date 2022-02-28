class CreateEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :events do |t|
      t.datetime :start_at
      t.datetime :end_at
      t.text :description
      t.integer :duration
      t.string :external_user_emails

      t.timestamps
    end
  end
end
