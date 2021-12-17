# frozen_string_literal: true

class AddOnlineSignatureEnabledToReferendumType < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_referendums_types, :online_signature_enabled, :boolean, null: false, default: true
  end
end
