# frozen_string_literal: true

module Decidim
  module Referendums
    class Permissions < Decidim::DefaultPermissions
      def permissions
        if read_admin_dashboard_action?
          user_can_read_admin_dashboard?
          return permission_action
        end

        # Delegate the admin permission checks to the admin permissions class
        return Decidim::Referendums::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin
        return permission_action if permission_action.scope != :public

        # Non-logged users permissions
        public_report_content_action?
        list_public_referendums?
        read_public_referendum?
        search_referendum_types_and_scopes?

        return permission_action unless user

        create_referendum?
        request_membership?

        vote_referendum?
        sign_referendum?
        unvote_referendum?

        permission_action
      end

      private

      def referendum
        @referendum ||= context.fetch(:referendum, nil) || context.fetch(:current_participatory_space, nil)
      end

      def list_public_referendums?
        allow! if permission_action.subject == :referendum &&
                  permission_action.action == :list
      end

      def read_public_referendum?
        return unless [:referendum, :participatory_space].include?(permission_action.subject) &&
                      permission_action.action == :read

        return allow! if referendum.published? || referendum.rejected? || referendum.accepted?
        return allow! if user && (referendum.has_authorship?(user) || user.admin? || user.role?("initiative_manager"))

        disallow!
      end

      def search_referendum_types_and_scopes?
        return unless permission_action.action == :search
        return unless [:referendum_type, :referendum_type_scope, :referendum_type_signature_types].include?(permission_action.subject)

        allow!
      end

      def create_referendum?
        return unless permission_action.subject == :referendum &&
                      permission_action.action == :create

        toggle_allow(creation_enabled?)
      end

      def creation_enabled?
        Decidim::Referendums.creation_enabled && (
          Decidim::Referendums.do_not_require_authorization ||
            UserAuthorizations.for(user).any? ||
            Decidim::UserGroups::ManageableUserGroups.for(user).verified.any?
        )
      end

      def request_membership?
        return unless permission_action.subject == :referendum &&
                      permission_action.action == :request_membership

        can_request = !referendum.published? &&
                      referendum.promoting_committee_enabled? &&
                      !referendum.has_authorship?(user) &&
                      (
                        Decidim::Referendums.do_not_require_authorization ||
                        UserAuthorizations.for(user).any? ||
                        Decidim::UserGroups::ManageableUserGroups.for(user).verified.any?
                      )

        toggle_allow(can_request)
      end

      def has_referendums?
        (ReferendumsCreated.by(user) | ReferendumsPromoted.by(user)).any?
      end

      def read_admin_dashboard_action?
        permission_action.action == :read &&
          permission_action.subject == :admin_dashboard
      end

      def user_can_read_admin_dashboard?
        return unless user

        allow! if has_referendums? || user.role?("initiative_manager")
      end

      def vote_referendum?
        return unless permission_action.action == :vote &&
                      permission_action.subject == :referendum

        toggle_allow(can_vote?)
      end

      def authorized?(permission_action, resource: nil, permissions_holder: nil)
        return unless resource || permissions_holder

        ActionAuthorizer.new(user, permission_action, permissions_holder, resource).authorize.ok?
      end

      def unvote_referendum?
        return unless permission_action.action == :unvote &&
                      permission_action.subject == :referendum

        can_unvote = referendum.accepts_online_unvotes? &&
                     referendum.organization&.id == user.organization&.id &&
                     referendum.votes.where(decidim_author_id: user.id, decidim_user_group_id: decidim_user_group_id).any? &&
                     (can_user_support?(referendum) || Decidim::UserGroups::ManageableUserGroups.for(user).verified.any?) &&
                     authorized?(:vote, resource: referendum, permissions_holder: referendum.type)

        toggle_allow(can_unvote)
      end

      def public_report_content_action?
        return unless permission_action.action == :create &&
                      permission_action.subject == :moderation

        allow!
      end

      def sign_referendum?
        return unless permission_action.action == :sign_referendum &&
                      permission_action.subject == :referendum

        can_sign = can_vote? &&
                   context.fetch(:signature_has_steps, false)

        toggle_allow(can_sign)
      end

      def decidim_user_group_id
        context.fetch(:group_id, nil)
      end

      def can_vote?
        referendum.votes_enabled? &&
          referendum.organization&.id == user.organization&.id &&
          referendum.votes.where(decidim_author_id: user.id, decidim_user_group_id: decidim_user_group_id).empty? &&
          (can_user_support?(referendum) || Decidim::UserGroups::ManageableUserGroups.for(user).verified.any?) &&
          authorized?(:vote, resource: referendum, permissions_holder: referendum.type)
      end

      def can_user_support?(referendum)
        !referendum.offline_signature_type? && (
          Decidim::Referendums.do_not_require_authorization ||
          UserAuthorizations.for(user).any?
        )
      end
    end
  end
end
