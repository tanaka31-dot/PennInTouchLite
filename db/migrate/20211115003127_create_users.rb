class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :pennkey
      t.boolean :is_instructor
      t.string :password_hash

      t.timestamps
    end
  end
end
