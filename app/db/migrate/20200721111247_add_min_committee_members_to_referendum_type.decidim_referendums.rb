# frozen_string_literal: true
# This migration comes from decidim_referendums (originally 20181213184712)

class AddMinCommitteeMembersToReferendumType < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_referendums_types, :minimum_committee_members, :integer, null: true, default: nil
  end
end
