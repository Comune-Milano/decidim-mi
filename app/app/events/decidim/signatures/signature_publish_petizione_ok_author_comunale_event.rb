# frozen-string_literal: true

module Decidim
  module Signatures
    class SignaturePublishPetizioneOkAuthorComunaleEvent < Decidim::Events::BaseEvent
      include Decidim::Events::EmailEvent
      include Decidim::Events::NotificationEvent

      def email_greeting
        return 'Congratulazioni  ' + @user.name + '!'
      end

      def email_subject
        return 'La tua petizione ha ricevuto risposta'
      end

      def email_intro
        return ''
      end

      def resource_text
        return 'Il Comune ha risposto alla tua petizione "' + translated_attribute(@resource.title) + '".<br/>
        <a href="' + extra[:initiative_url].to_s + '">Leggila su Milano Partecipa</a>.<br/>
        Ti ricordiamo che la risposta viene pubblicata anche su Albo Pretorio.<br/>
        Grazie del tuo impegno. Non esitare a contattarci per ulteriori informazioni.'
      end

      def email_outro
        return 'A presto! 
Lo Staff di Milano Partecipa'
      end

    end
  end
end
