# frozen_string_literal: true
# This migration comes from decidim_referendums (originally 20171102094556)

class CreateReferendumDescriptionIndex < ActiveRecord::Migration[5.1]
  def up
    execute "CREATE INDEX decidim_referendums_description_search ON decidim_referendums(md5(description::text))"
  end

  def down
    execute "DROP INDEX decidim_referendums_description_search"
  end
end
