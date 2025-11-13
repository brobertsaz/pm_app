class CreateActivities < ActiveRecord::Migration[7.2]
  def change
    create_table :activities do |t|
      t.string :trackable_type, null: false
      t.bigint :trackable_id, null: false
      t.string :action, null: false
      t.references :user, null: false, foreign_key: true
      t.references :project, foreign_key: true
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :activities, [:trackable_type, :trackable_id]
    add_index :activities, :action
    add_index :activities, :created_at
  end
end
