# frozen_string_literal: true

module Decidim
  module Devise
    # Custom Devise SessionsController to avoid namespace problems.
    class SessionsController < ::Devise::SessionsController
      include Decidim::DeviseControllers

      before_action :check_sign_in_enabled, only: :create

      def create
        super
      end

      def after_sign_in_path_for(user)
        Rails.logger.info "\n\n\n"
        Rails.logger.info "CONTROLLO SCADENZA DI UFFICIALIZZAZIONE"
        #se la data attuale è superiore a officialized_until
        #metto a null i campi
        #officialized_at
        #officialized_as
        #officialized_until
        #confirmed_at
        #confirmation_send_at
        if user.officialized_until != nil
          now = Time.now.utc
          Rails.logger.info now.to_s
          Rails.logger.info user.officialized_until.to_s
          if now > user.officialized_until
            Rails.logger.info "Il periodo è scaduto!"
            user.officialized_at = nil
            user.officialized_as = nil
            user.officialized_until = nil
            user.confirmed_at = nil
            user.officialized_until = nil
            user.confirmation_sent_at = nil
            user.save!
            Rails.logger.info "L'utente è stato aggiornato!"
          end
        end
        Rails.logger.info "FINE CONTROLLO"
        Rails.logger.info "\n\n\n"
        if first_login_and_not_authorized?(user) && !user.admin? && !pending_redirect?(user)
          decidim_verifications.first_login_authorizations_path
        else
          super
        end
      end

      # Calling the `stored_location_for` method removes the key, so in order
      # to check if there's any pending redirect after login I need to call
      # this method and use the value to set a pending redirect. This is the
      # only way to do this without checking the session directly.
      def pending_redirect?(user)
        store_location_for(user, stored_location_for(user))
      end

      def first_login_and_not_authorized?(user)
        user.is_a?(User) && user.sign_in_count == 1 && current_organization.available_authorizations.any? && user.verifiable?
      end

      def after_sign_out_path_for(user)
        request.referer || super
      end

      private

      def check_sign_in_enabled
        redirect_to new_user_session_path unless current_organization.sign_in_enabled?
      end
    end
  end
end
