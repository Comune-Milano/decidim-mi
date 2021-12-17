# frozen_string_literal: true

class AddEncryptedMetadataToDecidimReferendumsVotes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_referendums_votes, :encrypted_metadata, :text
  end
end
