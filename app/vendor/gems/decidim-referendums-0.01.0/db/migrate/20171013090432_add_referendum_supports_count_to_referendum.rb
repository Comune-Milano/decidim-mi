# frozen_string_literal: true

class AddReferendumSupportsCountToReferendum < ActiveRecord::Migration[5.1]
  class Referendum < ApplicationRecord
    self.table_name = :decidim_referendums
  end

  def change
    add_column :decidim_referendums, :referendum_supports_count, :integer, null: false, default: 0

    reversible do |change|
      change.up do
        Referendum.find_each do |referendum|
          referendum.referendum_supports_count = referendum.votes.supports.count
          referendum.save
        end
      end
    end
  end
end
