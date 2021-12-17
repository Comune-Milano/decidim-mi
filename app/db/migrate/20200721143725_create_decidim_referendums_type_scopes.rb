class CreateDecidimReferendumsTypeScopes < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_referendums_type_scopes do |t|
      t.references :decidim_referendums_types, index: { name: "idx_scoped_referendum_type_type" }
      t.references :decidim_scopes, index: { name: "idx_scoped_referendum_type_scope" }
      t.integer :supports_required, null: false

      t.timestamps
    end
  end
end
