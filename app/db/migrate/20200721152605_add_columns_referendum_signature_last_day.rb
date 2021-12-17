class AddColumnsReferendumSignatureLastDay < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_referendums, :signature_last_day, :date
  end
end
