# frozen_string_literal: true
# This migration comes from decidim_referendums (originally 20170906091626)

class CreateDecidimReferendumsTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_referendums_types do |t|
      t.jsonb :title, null: false
      t.jsonb :description, null: false
      t.integer :supports_required, null: false

      t.integer :decidim_organization_id,
                foreign_key: true,
                index: {
                  name: "index_decidim_referendum_types_on_decidim_organization_id"
                }

      t.timestamps
    end
  end
end
