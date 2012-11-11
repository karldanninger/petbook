class AddPettypeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :pettype, :string
    add_column :users, :breed, :string
    add_column :users, :birthday, :datetime
  end
end
