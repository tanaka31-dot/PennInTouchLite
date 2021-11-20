class CreateCourses < ActiveRecord::Migration[5.2]
  def change
    create_table :courses do |t|
      t.references :department, foreign_key: true
      t.integer :code
      t.string :title
      t.text :description

      t.timestamps
    end
  end
end
