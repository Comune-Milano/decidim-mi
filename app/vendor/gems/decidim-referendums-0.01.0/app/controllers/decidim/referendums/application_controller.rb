# frozen_string_literal: true

module Decidim
  module Referendums
    # The main admin application controller for referendums
    class ApplicationController < Decidim::ApplicationController
      include NeedsPermission

      register_permissions(::Decidim::Referendums::ApplicationController,
                           ::Decidim::Referendums::Permissions,
                           ::Decidim::Admin::Permissions,
                           ::Decidim::Permissions)

      def permissions_context
        super.merge(
          current_participatory_space: try(:current_participatory_space)
        )
      end

      def permission_class_chain
        ::Decidim.permissions_registry.chain_for(::Decidim::Referendums::ApplicationController)
      end

      def permission_scope
        :public
      end
    end
  end
end
