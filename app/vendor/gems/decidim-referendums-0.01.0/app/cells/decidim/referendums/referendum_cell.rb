# frozen_string_literal: true

module Decidim
  module Referendums
    # This cell renders the process card for an instance of an Referendum
    # the default size is the Medium Card (:m)
    class ReferendumCell < Decidim::ViewModel
      def show
        cell card_size, model, options
      end

      private

      def card_size
        "decidim/referendums/referendum_m"
      end
    end
  end
end
