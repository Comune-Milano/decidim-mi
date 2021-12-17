# frozen_string_literal: true

module Decidim
  module Referendums
    # Helper methods for the create referendum wizard.
    module CreateReferendumHelper
      def signature_type_options(referendum_form)
        return all_signature_type_options unless referendum_form.signature_type_updatable?

        type = ::Decidim::ReferendumsType.find(referendum_form.type_id)
        allowed_signatures = type.allowed_signature_types_for_referendums

        if allowed_signatures == %w(online)
          online_signature_type_options
        elsif allowed_signatures == %w(offline)
          offline_signature_type_options
        else
          all_signature_type_options
        end
      end

      private

      def online_signature_type_options
        [
          [
            I18n.t(
              "online",
              scope: %w(activemodel attributes referendum signature_type_values)
            ), "online"
          ]
        ]
      end

      def offline_signature_type_options
        [
          [
            I18n.t(
              "offline",
              scope: %w(activemodel attributes referendum signature_type_values)
            ), "offline"
          ]
        ]
      end

      def all_signature_type_options
        Referendum.signature_types.keys.map do |type|
          [
            I18n.t(
              type,
              scope: %w(activemodel attributes referendum signature_type_values)
            ), type
          ]
        end
      end
    end
  end
end
