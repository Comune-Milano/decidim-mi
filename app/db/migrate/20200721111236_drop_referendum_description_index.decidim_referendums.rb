# frozen_string_literal: true
# This migration comes from decidim_referendums (originally 20171102094250)

class DropReferendumDescriptionIndex < ActiveRecord::Migration[5.1]
  def change
    remove_index :decidim_referendums, :description
  end
end
