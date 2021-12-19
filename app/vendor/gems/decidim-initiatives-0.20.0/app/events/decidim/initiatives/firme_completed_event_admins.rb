# frozen-string_literal: true

module Decidim
  module Initiatives
    class FirmeCompletedEventAdmins < Decidim::Events::SimpleEvent
      i18n_attributes :percentage

      def email_greeting
        return 'Ciao Amministratore,'
      end

      def email_subject
        return 'Firme petizione raggiunte. Avviare procedura amministrativa'
      end

      def email_intro
        return ''
      end

      def resource_text
        return 'La petizione '+ translated_attribute(@resource.title) +' ha raggiunto le firme necessarie all\'avvio della procedura per la risposta da parte dell\'Amministrazione.<br/>Ricordati di comunicare al proponente NOME PROPONENTE le informazioni relative al procedimento.'
      end

      def email_outro
        return 'A presto!
Lo Staff di Milano Partecipa'
      end
      def event_has_roles?
        true
      end
    end
  end
end
