# frozen-string_literal: true

module Decidim
  module Signatures
    class SignaturePublishReferendumOkAuthorComunaleEvent < Decidim::Events::BaseEvent
      include Decidim::Events::EmailEvent
      include Decidim::Events::NotificationEvent

      def email_greeting
        return 'Congratulazioni  ' + @user.nickname + '!'
      end

      def email_subject
        return 'Il referendum "' + translated_attribute(@resource.title) + '" ha ottenuto le firme necessarie'
      end

      def email_intro
        return ''
      end

      def resource_text
        return 'La tua proposta referendaria "' + translated_attribute(@resource.title) + '" ha raggiunto le firme valide necessarie.<br/>
I controlli formali sulle sottoscrizioni hanno avuto esito favorevole, ai sensi dell\'art. 12 dello Statuto Comunale, e hanno confermato il raggiungimento di almeno ' + @resource.supports_required.to_s + ' firme valide, raccolte sia online sia offline.<br/>
Di seguito la sintesi delle firme validate:<br/>
- Firme online raccolte: ' + extra[:online_total].to_s + '<br/>
- Firme offline inviate: ' + extra[:offline_total].to_s + '<br/>
- Firme offline validate: ' + extra[:offline_validated].to_s + '<br/>
- Firme totali ritenute valide:  ' + extra[:total].to_s + '<br/>
<br/>
Ti ricordiamo che una firma offline risulta valida se risponde ai requisiti indicati nello <a href="https://partecipazione.comune.milano.it/pages/regoledellapartecipazione" target="_blank">Statuto del Comune di Milano</a><br/>
<br/>
Sarai informato degli sviluppi.'
      end

      def email_outro
        return 'A presto! 
Lo Staff di Milano Partecipa'
      end

    end
  end
end
