class CreateSecureDataStorages < ActiveRecord::Migration[5.1]
  def change
    create_table :secure_data_storages do |t|
      t.string :token, null: false, comment: 'Unique identifier of the secured document'
      t.text :document, comment: 'Base64 encrypted document'
    end

    add_index :secure_data_storages, :token, unique: true
  end
end
