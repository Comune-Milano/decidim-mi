# This migration comes from decidim_referendums (originally 20171214161410)
# frozen_string_literal: true

class RenameSignatureTimeFieldsToSignatureDate < ActiveRecord::Migration[5.1]
  def change
    rename_column :decidim_referendums, :signature_start_time, :signature_start_date
    rename_column :decidim_referendums, :signature_end_time, :signature_end_date
  end
end
