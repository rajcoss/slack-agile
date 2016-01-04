class CreateEstimates < ActiveRecord::Migration
  def change
    create_table :estimates do |t|
      t.string :user
      t.integer :value
      t.belongs_to :round
      t.timestamps null: false
    end
  end
end
