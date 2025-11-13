class CreateTemplateTasks < ActiveRecord::Migration[7.2]
  def change
    create_table :template_tasks do |t|
      t.string :title, null: false
      t.text :description
      t.string :status, default: 'To Do'
      t.string :priority, default: 'Medium'
      t.integer :position, default: 0
      t.references :project_template, null: false, foreign_key: true

      t.timestamps
    end

    add_index :template_tasks, [:project_template_id, :position]
  end
end
