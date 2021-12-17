class AddDecidimAreasIdToDecidimReferendumsTypeScopes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_referendums_type_scopes, :decidim_areas_id, :bigint
  end
end
