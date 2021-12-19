# frozen-string_literal: true

module Decidim
  module Signatures
    class SignaturePublishPetizioneOkAuthorComunaleEvent < Decidim::Events::BaseEvent
      include Decidim::Events::EmailEvent
      include Decidim::Events::NotificationEvent

      def email_greeting
        return 'Congratulazioni  ' + @user.nickname + '!'
      end

      def email_subject
        return 'La petizione "' + translated_attribute(@resource.title) + '" ha ottenuto le firme necessarie'
      end

      def email_intro
        return ''
      end

      def resource_text
        return 'La tua petizione "' + translated_attribute(@resource.title) + '" ha raggiunto ' + @resource.supports_required.to_s + ' firme valide. Verrà quindi inviata al Presidente del Consiglio Comunale per l\'inoltro alla Commissione competente, e riceverà risposta scritta e motivata ai sensi dell\'<a href="https://partecipazione.comune.milano.it/pages/regoledellapartecipazione" target="_blank">art. 9 dello Statuto Comunale</a>.<br/>Oltre che sulla piattaforma Milano Partecipa, la risposta viene pubblicata anche nell’Albo Pretorio del Comune di Milano.'
      end

      def email_outro
        return 'A presto! 
Lo Staff di Milano Partecipa'
      end

    end
  end
end
