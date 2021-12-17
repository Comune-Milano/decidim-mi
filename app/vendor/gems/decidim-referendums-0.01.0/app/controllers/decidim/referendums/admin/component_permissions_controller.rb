# frozen_string_literal: true

module Decidim
  module Referendums
    module Admin
      # Controller that allows managing the Referendum's Component
      # permissions in the admin panel.
      class ComponentPermissionsController < Decidim::Admin::ComponentPermissionsController
        include ReferendumAdmin
      end
    end
  end
end
