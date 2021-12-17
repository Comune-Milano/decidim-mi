# frozen_string_literal: true

module Decidim
  module Referendums
    module ContentBlocks
      class HighlightedReferendumsSettingsFormCell < Decidim::ViewModel
        alias form model

        def content_block
          options[:content_block]
        end

        def label
          I18n.t("decidim.referendums.admin.content_blocks.highlighted_referendums.max_results")
        end
      end
    end
  end
end
