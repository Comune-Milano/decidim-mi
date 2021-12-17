# frozen_string_literal: true

class RemoveScopeFromDecidimReferendumsVotes < ActiveRecord::Migration[5.1]
  def change
    remove_column :decidim_referendums_votes, :scope, :integer
  end
end
