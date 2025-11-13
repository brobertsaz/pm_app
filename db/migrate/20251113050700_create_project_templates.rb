class CreateProjectTemplates < ActiveRecord::Migration[7.2]
  def change
    create_table :project_templates do |t|
      t.string :name, null: false
      t.text :description
      t.boolean :is_public, default: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :project_templates, [:user_id, :is_public]
  end
end
