# frozen-string_literal: true

module Decidim
  module Referendums
    class ExtendReferendumEvent < Decidim::Events::SimpleEvent
      def participatory_space
        resource
      end
    end
  end
end
