# frozen_string_literal: true

module Decidim
  module Referendums
    module ContentBlocks
      class HighlightedReferendumsCell < Decidim::ViewModel
        include Decidim::SanitizeHelper

        delegate :current_organization, to: :controller

        def show
          render if highlighted_referendums.any?
        end

        def max_results
          model.settings.max_results
        end

        def highlighted_referendums
          @highlighted_referendums ||= OrganizationPrioritizedReferendums
                                       .new(current_organization)
                                       .query
                                       .limit(max_results)
        end

        def i18n_scope
          "decidim.referendums.pages.home.highlighted_referendums"
        end

        def decidim_referendums
          Decidim::Referendums::Engine.routes.url_helpers
        end
      end
    end
  end
end
