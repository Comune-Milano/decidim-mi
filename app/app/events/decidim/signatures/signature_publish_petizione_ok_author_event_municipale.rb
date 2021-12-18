# frozen-string_literal: true

module Decidim
  module Signatures
    class SignaturePublishPetizioneOkAuthorEventMunicipale < Decidim::Events::BaseEvent
      include Decidim::Events::EmailEvent
      include Decidim::Events::NotificationEvent

      def email_greeting
        return 'Congratulazioni  ' + @user.nickname + '!'
      end

      def email_subject
        return 'La petizione "' + @resource.title + '" ha ottenuto le firme necessarie'
      end

      def email_intro
        return 'La tua petizione "' + @resource.title + '" ha raggiunto ' + @resource.support_required + ' firme valide. Verr? quindi inviata al Presidente del Municipio e ricever? risposta scritta e motivata ai sensi dell’art. 64 del Regolamento dei Municipi https://partecipazione.comune.milano.it/pages/partecipazione-municipi .
Oltre che sulla piattaforma Milano Partecipa, la risposta viene pubblicata nell’Albo Pretorio del Comune di Milano.'
      end

      def email_outro
        return 'A presto! 
Lo Staff di Milano Partecipa'
      end

    end
  end
end
