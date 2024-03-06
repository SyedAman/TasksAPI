class AddProgressToTasks < ActiveRecord::Migration[7.1]
  def change
    add_column :tasks, :progress, :integer
  end
end
