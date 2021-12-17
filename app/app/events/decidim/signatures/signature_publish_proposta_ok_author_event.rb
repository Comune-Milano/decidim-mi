# frozen-string_literal: true

module Decidim
  module Signatures
    class SignaturePublishPropostaOkAuthorEvent < Decidim::Events::BaseEvent
      include Decidim::Events::EmailEvent
      include Decidim::Events::NotificationEvent

      def email_greeting
        return 'Gentile ' + @user.nickname + ' OK,'
      end

      def email_subject
        return 'La proposta è stata pubblicata'
      end

      def email_intro
        return 'daidaidaidaidaidaidaida'
      end

      def email_outro
        return 'Grazie, lo staff di Milano Partecipa'
      end

    end
  end
end
