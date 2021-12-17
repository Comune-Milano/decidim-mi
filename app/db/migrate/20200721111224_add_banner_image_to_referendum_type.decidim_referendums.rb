# frozen_string_literal: true
# This migration comes from decidim_referendums (originally 20171011110714)

class AddBannerImageToReferendumType < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_referendums_types, :banner_image, :string
  end
end
