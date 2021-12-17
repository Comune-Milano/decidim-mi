# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Referendums
    module Admin
      # This concern is meant to be included in all controllers that are scoped
      # into an referendum's admin panel. It will override the layout so it shows
      # the sidebar, preload the assembly, etc.
      module ReferendumAdmin
        extend ActiveSupport::Concern
        include ReferendumSlug

        included do
          include NeedsReferendum

          include Decidim::Admin::ParticipatorySpaceAdminContext
          participatory_space_admin_layout

          alias_method :current_participatory_space, :current_referendum
        end
      end
    end
  end
end
