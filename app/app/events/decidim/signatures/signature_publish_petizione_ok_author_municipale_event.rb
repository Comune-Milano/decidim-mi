# frozen-string_literal: true

module Decidim
  module Signatures
    class SignaturePublishPetizioneOkAuthorMunicipaleEvent < Decidim::Events::BaseEvent
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
        return 'La tua petizione "' + translated_attribute(@resource.title) + '" ha raggiunto ' + @resource.supports_required.to_s + ' firme valide. Verrà quindi inviata al Presidente del Municipio e riceverà risposta scritta e motivata ai sensi dell\'<a href="https://partecipazione.comune.milano.it/pages/partecipazione-municipi" target="_blank">art. 64 del Regolamento dei Municipi</a>.<br/>Oltre che sulla piattaforma Milano Partecipa, la risposta viene pubblicata nell’Albo Pretorio del Comune di Milano.'
      end

      def email_outro
        return 'A presto! Lo Staff di Milano Partecipa'
      end

    end
  end
end
