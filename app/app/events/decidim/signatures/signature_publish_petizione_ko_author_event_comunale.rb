module Decidim
  module Signatures
    class SignaturePublishPetizioneKoAuthorEventComunale < Decidim::Events::BaseEvent
      include Decidim::Events::EmailEvent
      include Decidim::Events::NotificationEvent

      def email_greeting
        return 'Caro ' + @user.nickname + ','
      end

      def email_subject
        return 'La petizione "' + @resource.title + '" non ha ottenuto le firme necessarie.'
      end

      def email_intro
        return 'purtroppo la tua petizione "' + @resource.title + '" non ha raggiunto le ' + @resource.support_required + ' firme valide necessarie.
I controlli formali eseguiti sulle sottoscrizioni hanno dato esito negativo rispetto a quanto previsto dall\'<a href="https://partecipazione.comune.milano.it/pages/regoledellapartecipazione" target="_blank">art 9 dello Statuto Comunale</a>
Pertanto, la petizione non può essere accolta.
Ti ringraziamo e restiamo a tua disposizione per eventuali chiarimenti.'
      end

      def email_outro
        return 'A presto!
Lo Staff di Milano Partecipa'
      end

    end
  end
end
