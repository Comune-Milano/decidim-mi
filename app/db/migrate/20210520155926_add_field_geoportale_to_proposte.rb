class AddFieldGeoportaleToProposte < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_proposals_proposals, :geoportale_link, :string
    add_column :decidim_proposals_proposals, :geoportale_id_code, :string
  end
end
