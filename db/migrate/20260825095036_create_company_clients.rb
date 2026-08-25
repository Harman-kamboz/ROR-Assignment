class CreateCompanyClients < ActiveRecord::Migration[8.1]
  def change
    create_table :company_clients do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.references :company, null: false, foreign_key: true
      t.references :client, null: false, foreign_key: true

      t.timestamps
    end

    add_index :company_clients, [ :company_id, :client_id ], unique: true
  end
end
