class CreatePhoneCalls < ActiveRecord::Migration[7.1]
  def change
    create_table :phone_calls do |t|
      t.string :phone_number
      t.string :status
      t.integer :duration
      t.boolean :answered
      t.string :call_sid
      t.text :error_message

      t.timestamps
    end
  end
end
