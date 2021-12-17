# frozen_string_literal: true

class AddHashIdToDecidimReferendumsVotes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_referendums_votes, :hash_id, :string
  end
end
