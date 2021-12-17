# frozen_string_literal: true
# This migration comes from decidim_referendums (originally 20181212155125)

class AddOnlineSignatureEnabledToReferendumType < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_referendums_types, :online_signature_enabled, :boolean, null: false, default: true
  end
end
