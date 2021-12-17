# frozen_string_literal: true

module Decidim
  module Referendums
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          # The public part needs to be implemented yet
          return permission_action if permission_action.scope != :admin
          return permission_action unless user

          user_can_enter_space_area?

          return permission_action if referendum && !referendum.is_a?(Decidim::Referendum)

          user_can_read_participatory_space?

          if !user.admin? && referendum&.has_authorship?(user)
            referendum_committee_action?
            referendum_user_action?
            attachment_action?

            return permission_action
          end

          if !user.admin? && has_referendums?
            read_referendum_list_action?

            return permission_action
          end

          return permission_action unless user.admin? || user.role?("initiative_manager")

          referendum_type_action?
          referendum_type_scope_action?
          referendum_committee_action?
          referendum_admin_user_action?
          if user.admin?

          end

          moderator_action?
          allow! if permission_action.subject == :attachment

          permission_action
        end

        private

        def referendum
          @referendum ||= context.fetch(:referendum, nil) || context.fetch(:current_participatory_space, nil)
        end

        def user_can_read_participatory_space?
          return unless permission_action.action == :read &&
                        permission_action.subject == :participatory_space

          toggle_allow(user.admin? || user.role?("initiative_manager") || referendum.has_authorship?(user) )
        end

        def user_can_enter_space_area?
          return unless permission_action.action == :enter &&
                        permission_action.subject == :space_area &&
                        context.fetch(:space_name, nil) == :referendums

          toggle_allow(user.admin? || has_referendums? || user.role?("initiative_manager"))
        end

        def has_referendums?
          (ReferendumsCreated.by(user) | ReferendumsPromoted.by(user)).any?
        end

        def attachment_action?
          return unless permission_action.subject == :attachment

          attachment = context.fetch(:attachment, nil)
          attached = attachment&.attached_to

          case permission_action.action
          when :update, :destroy
            toggle_allow(attached && attached.is_a?(Decidim::Referendum))
          when :read, :create
            allow!
          else
            disallow!
          end
        end

        def referendum_type_action?
          return unless [:referendum_type, :referendums_type].include? permission_action.subject

          referendum_type = context.fetch(:referendum_type, nil)

          case permission_action.action
          when :destroy
            scopes_are_empty = referendum_type && referendum_type.scopes.all? { |scope| scope.referendums.empty? }
            toggle_allow(scopes_are_empty)
          else
            allow!
          end
        end

        def referendum_type_scope_action?
          return unless permission_action.subject == :referendum_type_scope

          referendum_type_scope = context.fetch(:referendum_type_scope, nil)

          case permission_action.action
          when :destroy
            scopes_is_empty = referendum_type_scope && referendum_type_scope.referendums.empty?
            toggle_allow(scopes_is_empty)
          else
            allow!
          end
        end

        def referendum_committee_action?
          return unless permission_action.subject == :referendum_committee_member

          request = context.fetch(:request, nil)

          case permission_action.action
          when :index
            allow!
          when :approve
            toggle_allow(!request&.accepted?)
          when :revoke
            toggle_allow(!request&.rejected?)
          end
        end

        def referendum_admin_user_action?
          return unless permission_action.subject == :referendum

          case permission_action.action
          when :read
            toggle_allow(Decidim::Referendums.print_enabled)
          when :publish
            toggle_allow(referendum.validating?)
          when :unpublish
            toggle_allow(referendum.published?)
          when :discard
            toggle_allow(referendum.validating?)
          when :export_pdf_signatures
            toggle_allow(referendum.published? || referendum.accepted? || referendum.rejected?)
          when :export_votes
            toggle_allow(referendum.offline_signature_type? || referendum.any_signature_type?)
          when :accept
            allowed = referendum.published? &&
                      referendum.signature_end_date < Date.current &&
                      referendum.percentage >= 100
            toggle_allow(allowed)
          when :reject
            allowed = referendum.published? &&
                      referendum.signature_end_date < Date.current &&
                      referendum.percentage < 100
            toggle_allow(allowed)
          else
            allow!
          end
        end

        def moderator_action?
          return unless permission_action.subject == :moderation

          allow!
        end

        def read_referendum_list_action?
          return unless permission_action.subject == :referendum &&
                        permission_action.action == :list

          allow!
        end

        def referendum_user_action?
          return unless permission_action.subject == :referendum

          case permission_action.action
          when :read
            toggle_allow(Decidim::Referendums.print_enabled)
          when :preview, :edit
            allow!
          when :update
            toggle_allow(referendum.created?)
          when :send_to_technical_validation
            allowed = referendum.created? && (
                        !referendum.created_by_individual? ||
                        referendum.enough_committee_members?
                      )

            toggle_allow(allowed)
          when :manage_membership
            toggle_allow(referendum.promoting_committee_enabled?)
          else
            disallow!
          end
        end
      end
    end
  end
end
