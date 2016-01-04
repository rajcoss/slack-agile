class AddClosedToRound < ActiveRecord::Migration
  def change
    add_column :rounds, :closed, :boolean
  end
end
