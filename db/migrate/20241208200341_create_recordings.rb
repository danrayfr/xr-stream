class CreateRecordings < ActiveRecord::Migration[8.0]
  def change
    create_table :recordings do |t|
      t.string :key, null: false

      t.timestamps
    end

    add_index :recordings, :key, unique: true
  end
end
