class CreateTimeEntries < ActiveRecord::Migration[7.2]
  def change
    create_table :time_entries do |t|
      t.references :task, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.decimal :hours, precision: 8, scale: 2, null: false
      t.text :description
      t.date :logged_date, null: false

      t.timestamps
    end

    add_index :time_entries, :logged_date
    add_index :time_entries, :created_at
  end
end
