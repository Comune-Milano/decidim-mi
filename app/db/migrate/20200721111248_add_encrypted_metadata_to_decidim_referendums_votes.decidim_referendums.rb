# frozen_string_literal: true
# This migration comes from decidim_referendums (originally 20181220134322)

class AddEncryptedMetadataToDecidimReferendumsVotes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_referendums_votes, :encrypted_metadata, :text
  end
end
