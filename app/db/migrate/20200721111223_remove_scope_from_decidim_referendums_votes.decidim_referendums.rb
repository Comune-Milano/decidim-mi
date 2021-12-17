# frozen_string_literal: true
# This migration comes from decidim_referendums (originally 20170928160912)

class RemoveScopeFromDecidimReferendumsVotes < ActiveRecord::Migration[5.1]
  def change
    remove_column :decidim_referendums_votes, :scope, :integer
  end
end
