class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.string :provider, :null => false
      t.string :uid, :null => false
      t.string :sname
      t.string :smail
      t.references :user

      t.timestamps
    end
    add_index :services, :user_id
  end
end
