# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # Controller that allows managing initiatives signature
      # permissions in the admin panel.
      class InitiativesOfflineSignaturePermissionsController < Decidim::Admin::ResourcePermissionsController
        layout "decidim/admin/initiatives"

        register_permissions(::Decidim::Initiatives::Admin::InitiativesOfflineSignaturePermissionsController,
                             ::Decidim::Initiatives::Permissions,
                             ::Decidim::Admin::Permissions)

        def permission_class_chain
          ::Decidim.permissions_registry.chain_for(::Decidim::Initiatives::Admin::InitiativesOfflineSignaturePermissionsController)
        end
      end
    end
  end
end
