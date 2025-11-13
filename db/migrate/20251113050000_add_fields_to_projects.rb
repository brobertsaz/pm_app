class AddFieldsToProjects < ActiveRecord::Migration[7.2]
  def change
    add_column :projects, :status, :string, default: 'Not Started'
    add_column :projects, :priority, :string, default: 'Medium'
    add_column :projects, :due_date, :date
    add_reference :projects, :user, foreign_key: true
  end
end
