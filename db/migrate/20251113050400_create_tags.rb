class CreateTags < ActiveRecord::Migration[7.2]
  def change
    create_table :tags do |t|
      t.string :name, null: false
      t.string :color, default: '#9E9E9E'
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end

    add_index :tags, [:project_id, :name], unique: true

    create_table :taggings do |t|
      t.references :tag, null: false, foreign_key: true
      t.references :taggable, polymorphic: true, null: false

      t.timestamps
    end

    add_index :taggings, [:taggable_type, :taggable_id]
  end
end
