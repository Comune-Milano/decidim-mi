# frozen_string_literal: true

module Decidim
  module Referendums
    module Admin
      # Controller that allows managing the Referendum's Components in the
      # admin panel.
      class ComponentsController < Decidim::Admin::ComponentsController
        layout "decidim/admin/referendum"

        include NeedsReferendum
      end
    end
  end
end
