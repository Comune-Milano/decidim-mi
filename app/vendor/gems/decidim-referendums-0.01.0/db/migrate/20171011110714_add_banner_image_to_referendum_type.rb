# frozen_string_literal: true

class AddBannerImageToReferendumType < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_referendums_types, :banner_image, :string
  end
end
