# frozen-string_literal: true

module Decidim
  module Signatures
    class SignaturePublishPropostaKoAuthorEvent < Decidim::Events::BaseEvent
      include Decidim::Events::EmailEvent
      include Decidim::Events::NotificationEvent

      def email_greeting
        return 'Gentile ' + @user.nickname + ' KO,'
      end

      def email_subject
        return 'La proposta è stata pubblicata KO'
      end

      def email_intro
        return 'online votes: ' + @resource.get_online_votes().to_s
      end

      def email_outro
        return 'Grazie, lo staff di Milano Partecipa'
      end

    end
  end
end
