class CreateDecidimReferendumsCsvData < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_referendums_csv_signature_data do |t|
      t.string :email
      t.references :decidim_organization, foreign_key: true, index: { name: "index_referendums_csv_to_organization" }

      t.timestamps
    end
  end
end
