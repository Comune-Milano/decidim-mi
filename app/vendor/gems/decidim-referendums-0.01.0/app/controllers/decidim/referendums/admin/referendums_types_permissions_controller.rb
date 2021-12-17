# frozen_string_literal: true

module Decidim
  module Referendums
    module Admin
      # Controller that allows managing referendums types
      # permissions in the admin panel.
      class ReferendumsTypesPermissionsController < Decidim::Admin::ResourcePermissionsController
        layout "decidim/admin/referendums"

        register_permissions(::Decidim::Referendums::Admin::ReferendumsTypesPermissionsController,
                             ::Decidim::Referendums::Permissions,
                             ::Decidim::Admin::Permissions)

        def permission_class_chain
          ::Decidim.permissions_registry.chain_for(::Decidim::Referendums::Admin::ReferendumsTypesPermissionsController)
        end
      end
    end
  end
end
