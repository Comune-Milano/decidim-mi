class AddColumnReferendumType < ActiveRecord::Migration[5.2]
  def change
     add_column :decidim_referendums_types, :signature_type, :integer, null: false, default: 0
     add_column :decidim_referendums_types, :promoting_committee_enabled, :boolean, null: false, default: true
  end
end
