# frozen-string_literal: true

module Decidim
  module PdfSigneds
    class PdfSignedsProtocolloAurigaEvent < Decidim::Events::BaseEvent
      include Decidim::Events::EmailEvent
      include Decidim::Events::NotificationEvent

      def email_greeting
        return 'Gentile ' + extra[:nome_utente] + ','
      end

      def email_subject
        return 'Documento firme con protocollo ' + extra[:protocollo]
      end

      def email_intro
        return 'in data ' + extra[:data_corrente] + ' abbiamo ricevuta i documenti inerenti le firme offline raccolte per ' + extra[:stringa_tipo] + ' "' + extra[:titolo_componente] + '". Ai documenti è stato associato il numero di protocollo ' + extra[:protocollo]
      end

      def email_outro
        return 'Grazie, lo staff di Milano Partecipa'
      end

    end
  end
end
