# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Referendums
    # Common logic to ordering resources
    module Orderable
      extend ActiveSupport::Concern

      included do
        include Decidim::Orderable

        # Available orders based on enabled settings
        def available_orders
          @available_orders ||= begin
            available_orders = %w(random recent most_voted most_commented)
            available_orders
          end
        end

        def default_order
          "random"
        end

        def reorder(referendums)
          case order
          when "most_voted"
            referendums.order_by_supports
          when "most_commented"
            referendums.order_by_most_commented
          when "recent"
            referendums.order_by_most_recent
          else
            referendums.order_randomly(random_seed)
          end
        end
      end
    end
  end
end
