# frozen_string_literal: true
# This migration comes from decidim_referendums (originally 20181211112538)

class AddReferenceToReferendums < ActiveRecord::Migration[5.2]
  class Referendum < ApplicationRecord
    self.table_name = :decidim_referendums

    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization"

    include Decidim::Participable
    include Decidim::HasReference
  end

  def change
    add_column :decidim_referendums, :reference, :string

    reversible do |dir|
      dir.up do
        Referendum.find_each(&:touch)
      end
    end
  end
end
