class CreateSecureDataStorages < ActiveRecord::Migration[7.2]
  def change
    create_table :secure_data_storages, id: :uuid do |t|
      t.string :token, null: false, comment: 'Unique identifier of the secured document'
      t.text :document, comment: 'Base64 encrypted document'
    end

    add_index :secure_data_storages, :token, unique: true
  end
end
