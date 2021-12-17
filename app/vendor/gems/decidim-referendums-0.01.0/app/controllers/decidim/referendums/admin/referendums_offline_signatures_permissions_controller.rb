# frozen_string_literal: true

module Decidim
  module Referendums
    module Admin
      # Controller that allows managing referendums signature
      # permissions in the admin panel.
      class ReferendumsOfflineSignaturePermissionsController < Decidim::Admin::ResourcePermissionsController
        layout "decidim/admin/referendums"

        register_permissions(::Decidim::Referendums::Admin::ReferendumsOfflineSignaturePermissionsController,
                             ::Decidim::Referendums::Permissions,
                             ::Decidim::Admin::Permissions)

        def permission_class_chain
          ::Decidim.permissions_registry.chain_for(::Decidim::Referendums::Admin::ReferendumsOfflineSignaturePermissionsController)
        end
      end
    end
  end
end
