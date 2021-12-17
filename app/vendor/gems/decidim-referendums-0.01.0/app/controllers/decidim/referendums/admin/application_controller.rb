# frozen_string_literal: true

module Decidim
  module Referendums
    module Admin
      # The main admin application controller for referendums
      class ApplicationController < Decidim::Admin::ApplicationController
        layout "decidim/admin/referendums"

        register_permissions(::Decidim::Referendums::Admin::ApplicationController,
                             ::Decidim::Referendums::Permissions,
                             ::Decidim::Admin::Permissions)

        def permissions_context
          super.merge(
            current_participatory_space: try(:current_participatory_space)
          )
        end

        def permission_class_chain
          ::Decidim.permissions_registry.chain_for(::Decidim::Referendums::Admin::ApplicationController)
        end
      end
    end
  end
end
