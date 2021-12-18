# frozen-string_literal: true

module Decidim
  module Signatures
    class SignaturePublishReferendumKoAuthorEventComunale < Decidim::Events::BaseEvent
      include Decidim::Events::EmailEvent
      include Decidim::Events::NotificationEvent

      def email_greeting
        return 'Caro ' + @user.nickname + ','
      end

      def email_subject
        return 'Il Referendum "' + @resource.title + '" non ha ottenuto le firme necessarie.'
      end

      def email_intro
        return 'purtroppo la tua proposta referendaria "' + @resource.title + '" non ha raggiunto le firme valide necessarie.
I controlli formali eseguiti sulle sottoscrizioni hanno dato esito negativo rispetto a quanto previsto dall\'art 12 dello Statuto Comunale, ovvero hanno verificato il non raggiungimento di almeno ' + @resource.support_required + ' firme valide, raccolte sia online sia offline.
Pertanto, la richiesta di referendum non può essere accolta.
Di seguito la sintesi delle firme validate:
- Firme online raccolte: ' + extra[:online_total] + '
- Firme offline inviate: ' + extra[:offline_total] + '
- Firme offline validate: ' + extra[:offline_validated] + '
- Firme totali ritenute valide:  ' + extra[:total] + '
Ti ricordiamo che una firma offline risulta valida se risponde ai requisiti indicati  nello <a href="https://partecipazione.comune.milano.it/pages/regoledellapartecipazione" target="_blank">Statuto del Comune di Milano</a>
Ti ringraziamo e restiamo a tua disposizione per eventuali chiarimenti.'
      end

      def email_outro
        return 'A presto! 
Lo Staff di Milano Partecipa'
      end

    end
  end
end
