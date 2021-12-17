class AddMailChiusuraMandataToDecidimInitiatives < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_initiatives, :mail_chiusura_mandata, :boolean
  end
end
