# frozen_string_literal: true

class DropReferendumDescriptionIndex < ActiveRecord::Migration[5.1]
  def change
    remove_index :decidim_referendums, :description
  end
end
