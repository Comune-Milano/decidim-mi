class RenameSignatureTimeFieldsReferendumToSignatureDate < ActiveRecord::Migration[5.2]
  def change
    rename_column :decidim_referendums, :signature_start_time, :signature_start_date
    rename_column :decidim_referendums, :signature_end_time, :signature_end_date
  end
end
