# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing user officializations at the admin panel.
    #
    class OfficializationsController < Decidim::Admin::ApplicationController
      layout "decidim/admin/users"

      helper_method :user
      helper Decidim::Messaging::ConversationHelper

      def index
        enforce_permission_to :read, :officialization
        @query = params[:q]
        @state = params[:state]

        @totale_partecipanti = Decidim::User.count
        @totale_partecipanti_newsletter = Decidim::User.where("newsletter_notifications_at is not null").count
        # il campo newsletter_notifications_at indica quando è stato attivato il flag
        # se questo campo è null allora il flag è disattivato

        @users = Decidim::Admin::UserFilter.for(current_organization.users.not_deleted, @query, @state)
                                           .page(params[:page])
                                           .per(15)
      end

      def new
        enforce_permission_to :create, :officialization
        @form = form(OfficializationForm).from_model(user)
      end

      def create
        enforce_permission_to :create, :officialization

        @form = form(OfficializationForm).from_params(params)

        OfficializeUser.call(@form) do
          on(:ok) do |user|
            notice = I18n.t("officializations.create.success", scope: "decidim.admin")

            redirect_to officializations_path(q: user.name), notice: notice
          end
        end
      end

      def destroy
        enforce_permission_to :destroy, :officialization

        UnofficializeUser.call(user, current_user) do
          on(:ok) do
            notice = I18n.t("officializations.destroy.success", scope: "decidim.admin")

            redirect_to officializations_path(q: user.name), notice: notice
          end
        end
      end

      def disabilita
        enforce_permission_to :create, :officialization

        @form = form(OfficializationForm).from_model(user)
      end

      def disable_user

        user = Decidim::User.find_by(id: params[:user_id])
        user.update!(
            deleted_at: Time.current,
            email_on_notification: false,
            newsletter_notifications_at: nil,
	    sign_in_count: 1,
	    name: '',
	    nickname:'',
            form_inviato: false,
            richiesta_at: nil,
            body_richiesta: nil
        )
        #url_name = user.name.gsub! ' ', '+'
        redirect_to "/admin/officializations"
      end

      private

      def user
        @user ||= Decidim::User.find_by(
          id: params[:user_id],
          organization: current_organization
        )
      end
    end
  end
end
