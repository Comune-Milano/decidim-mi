# frozen_string_literal: true

class AddTimestampToDecidimReferendumsVotes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_referendums_votes, :timestamp, :string
  end
end
