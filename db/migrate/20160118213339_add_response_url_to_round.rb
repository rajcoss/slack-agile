class AddResponseUrlToRound < ActiveRecord::Migration
  def change
    add_column :rounds, :response_url, :string
  end
end
