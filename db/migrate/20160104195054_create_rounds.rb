class CreateRounds < ActiveRecord::Migration
  def change
    create_table :rounds do |t|
      t.boolean :revealed
      t.integer :value
      t.string :issue
      t.string :channel
      t.timestamps null: false
    end
  end
end
