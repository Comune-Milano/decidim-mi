# frozen-string_literal: true

module Decidim
  module Signatures
    class SignaturePublishReferendumOkAuthorEventMunicipale < Decidim::Events::BaseEvent
      include Decidim::Events::EmailEvent
      include Decidim::Events::NotificationEvent

      def email_greeting
        return 'Congratulazioni  ' + @user.nickname + '!'
      end

      def email_subject
        return 'Il referendum "' + @resource.title + '" ha ottenuto le firme necessarie'
      end

      def email_intro
        return 'La tua proposta referendaria "' + @resource.title + '" ha raggiunto le firme valide necessarie.
I controlli formali sulle sottoscrizioni hanno avuto esito favorevole, ai sensi dell’art. 12 dello Statuto Comunale, e hanno confermato il raggiungimento di almeno ' + @resource.support_required + ' firme valide, raccolte sia online sia offline.
Di seguito la sintesi delle firme validate:
- Firme online raccolte: ' + extra[:online_total] + '
- Firme offline inviate: ' + extra[:offline_total] + '
- Firme offline validate: ' + extra[:offline_validated] + '
- Firme totali ritenute valide:  ' + extra[:total] + '

Ti ricordiamo che una firma offline risulta valida se risponde ai requisiti indicati nello <a href="https://partecipazione.comune.milano.it/pages/regoledellapartecipazione" target="_blank">Statuto del Comune di Milano</a>

Sarai informato degli sviluppi.'
      end

      def email_outro
        return 'A presto! 
Lo Staff di Milano Partecipa'
      end

    end
  end
end
