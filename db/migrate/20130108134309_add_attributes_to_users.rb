class AddAttributesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :mobile, :string
    add_column :users, :phone, :string
    add_column :users, :image, :binary
  end
end
