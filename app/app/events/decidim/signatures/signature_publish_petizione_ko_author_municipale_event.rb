# frozen-string_literal: true

module Decidim
  module Signatures
    class SignaturePublishPetizioneKoAuthorMunicipaleEvent < Decidim::Events::BaseEvent
      include Decidim::Events::EmailEvent
      include Decidim::Events::NotificationEvent

      def email_greeting
        return 'Caro ' + @user.name + ','
      end

      def email_subject
        return 'La tua petizione non può essere ammessa.'
      end

      def email_intro
        return ''
      end

      def resource_text
        return 'Ci dispiace ma la tua petizione "<a href="' + extra[:initiative_url].to_s + '">' + translated_attribute(@resource.title) + '</a>" non può essere accolta perché non conforme ai requisiti di ammissibilità previsti dal Comune di Milano.<br/>
Grazie di averci provato. Non esitare a contattarci per ulteriori informazioni su Milano Partecipa.'
      end

      def email_outro
        return 'A presto! 
Lo Staff di Milano Partecipa'
      end

    end
  end
end
