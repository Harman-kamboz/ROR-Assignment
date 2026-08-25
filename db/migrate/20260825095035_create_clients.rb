class CreateClients < ActiveRecord::Migration[8.1]
  def change
    create_table :clients do |t|
      t.string :name
      t.string :email, null: false
      t.string :phone
      t.string :password_digest

      t.timestamps
    end

    add_index :clients, :email, unique: true
    add_index :clients, :phone, unique: true, where: "phone IS NOT NULL"
  end
end
