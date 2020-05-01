class CreateBackgroundTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :background_tasks do |t|
      t.integer :task_type, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.integer :outcome, null: false, default: 0
      t.datetime :started_at
      t.datetime :finished_at
      t.json :info

      t.timestamps
    end

     add_index :background_tasks, :task_type
     add_index :background_tasks, :status
     add_index :background_tasks, :outcome
  end
end
