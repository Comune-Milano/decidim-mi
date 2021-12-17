# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Referendums
    # This module, when injected into a controller, ensures there's an
    # referendum available and deducts it from the context.
    module NeedsReferendum
      extend ActiveSupport::Concern

      RegistersPermissions
        .register_permissions("#{::Decidim::Referendums::NeedsReferendum.name}/admin",
                              Decidim::Referendums::Permissions,
                              Decidim::Admin::Permissions)
      RegistersPermissions
        .register_permissions("#{::Decidim::Referendums::NeedsReferendum.name}/public",
                              Decidim::Referendums::Permissions,
                              Decidim::Admin::Permissions,
                              Decidim::Permissions)

      included do
        include NeedsOrganization
        include ReferendumSlug

        helper_method :current_referendum, :current_participatory_space, :signature_has_steps?

        # Public: Finds the current Referendum given this controller's
        # context.
        #
        # Returns the current Referendum.
        def current_referendum
          @current_referendum ||= detect_referendum
        end

        alias_method :current_participatory_space, :current_referendum

        # Public: Wether the current referendum belongs to an referendum type
        # which requires one or more step before creating a signature
        #
        # Returns nil if there is no current_referendum, true or false
        def signature_has_steps?
          return unless current_referendum

          referendum_type = current_referendum.scoped_type.type
          referendum_type.collect_user_extra_fields? || referendum_type.validate_sms_code_on_votes?
        end

        private

        def detect_referendum
          request.env["current_referendum"] ||
            Referendum.find_by(
              id: (id_from_slug(params[:slug]) || id_from_slug(params[:referendum_slug]) || params[:referendum_id] || params[:id]),
              organization: current_organization
            )
        end

        def permission_class_chain
          if permission_scope == :admin
            PermissionsRegistry.chain_for("#{::Decidim::Referendums::NeedsReferendum.name}/admin")
          else
            PermissionsRegistry.chain_for("#{::Decidim::Referendums::NeedsReferendum.name}/public")
          end
        end
      end
    end
  end
end
