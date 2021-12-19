# frozen-string_literal: true

module Decidim
  module Signatures
    class SignaturePublishReferendumKoAuthorMunicipaleEvent < Decidim::Events::BaseEvent
      include Decidim::Events::EmailEvent
      include Decidim::Events::NotificationEvent

      def email_greeting
        return 'Caro ' + @user.nickname + ','
      end

      def email_subject
        return 'Il Referendum "' + translated_attribute(@resource.title) + '" non ha ottenuto le firme necessarie.'
      end

      def email_intro
        return ''
      end

      def resource_text
        return 'purtroppo la tua proposta referendaria "' + translated_attribute(@resource.title) + '" non ha raggiunto le firme valide necessarie.<br/>
I controlli formali eseguiti sulle sottoscrizioni hanno dato esito negativo rispetto a quanto previsto dall\'art 12 dello Statuto Comunale, ovvero hanno verificato il non raggiungimento di almeno ' + @resource.supports_required.to_s + ' firme valide, raccolte sia online sia offline.<br/>
Pertanto, la richiesta di referendum non può essere accolta.<br/>
Di seguito la sintesi delle firme validate:<br/>
- Firme online raccolte: ' + extra[:online_total].to_s + '<br/>
- Firme offline inviate: ' + extra[:offline_total].to_s + '<br/>
- Firme offline validate: ' + extra[:offline_validated].to_s + '<br/>
- Firme totali ritenute valide:  ' + extra[:total].to_s + '<br/>
Ti ricordiamo che una firma offline risulta valida se risponde ai requisiti indicati  nello <a href="https://partecipazione.comune.milano.it/pages/regoledellapartecipazione" target="_blank">Statuto del Comune di Milano</a><br/>
Ti ringraziamo e restiamo a tua disposizione per eventuali chiarimenti.'
      end

      def email_outro
        return 'A presto! 
Lo Staff di Milano Partecipa'
      end

    end
  end
end
