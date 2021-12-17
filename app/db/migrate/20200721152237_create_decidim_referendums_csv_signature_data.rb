class CreateDecidimReferendumsCsvSignatureData < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_referendums_csv_signature_data do |t|
      t.integer :referendums_id, index: true, null: false, default: 0
      t.integer :decidim_user_id
      t.string :name
      t.string :surname
      t.string :email
      t.string :codice_fiscale
      t.integer :decidim_organization_id
      t.string :stato
      t.boolean :validazione, default: false, null: false
      t.timestamps
    end
  end
end
