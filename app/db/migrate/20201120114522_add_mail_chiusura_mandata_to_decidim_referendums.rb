class AddMailChiusuraMandataToDecidimReferendums < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_referendums, :mail_chiusura_mandata, :boolean
  end
end
