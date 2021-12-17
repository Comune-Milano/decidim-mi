# This migration comes from decidim_referendums (originally 20171214161410)
# frozen_string_literal: true

class AddUniqueOnVotes < ActiveRecord::Migration[5.1]
  class ReferendumsVote < ApplicationRecord
    self.table_name = :decidim_referendums_votes
  end

  def get_duplicates(*columns)
    ReferendumsVote.select("#{columns.join(",")}, COUNT(*)").group(columns).having("COUNT(*) > 1")
  end

  def row_count(issue)
    ReferendumsVote.where(
      decidim_referendum_id: issue.decidim_referendum_id,
      decidim_author_id: issue.decidim_author_id,
      decidim_user_group_id: issue.decidim_user_group_id
    ).count
  end

  def find_next(issue)
    ReferendumsVote.find_by(
      decidim_referendum_id: issue.decidim_referendum_id,
      decidim_author_id: issue.decidim_author_id,
      decidim_user_group_id: issue.decidim_user_group_id
    )
  end

  def up
    columns = [:decidim_referendum_id, :decidim_author_id, :decidim_user_group_id]

    get_duplicates(columns).each do |issue|
      find_next(issue)&.destroy while row_count(issue) > 1
    end

    add_index :decidim_referendums_votes,
              columns,
              unique: true,
              name: "decidim_referendums_voutes_author_uniqueness_index"
  end
end
