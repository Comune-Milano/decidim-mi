# frozen-string_literal: true

module Decidim
  module Referendums
    class MilestoneCompletedEvent < Decidim::Events::SimpleEvent
      i18n_attributes :percentage

      def percentage
        extra[:percentage]
      end

      def participatory_space
        resource
      end

      def event_has_roles?
        true
      end
    end
  end
end
