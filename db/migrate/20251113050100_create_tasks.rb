class CreateTasks < ActiveRecord::Migration[7.2]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.text :description
      t.string :status, default: 'To Do'
      t.string :priority, default: 'Medium'
      t.date :due_date
      t.references :project, null: false, foreign_key: true
      t.references :user, foreign_key: true
      t.integer :position, default: 0

      t.timestamps
    end

    add_index :tasks, :status
    add_index :tasks, :priority
  end
end
