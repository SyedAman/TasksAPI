class CreateTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :tasks do |t|
      t.string :title
      t.text :description
      t.datetime :due_date
      t.integer :status
      t.integer :priority
      t.datetime :completed_date

      t.timestamps
    end
  end
end
