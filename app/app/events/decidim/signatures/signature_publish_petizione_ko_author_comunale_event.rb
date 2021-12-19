# frozen-string_literal: true

module Decidim
  module Signatures
    class SignaturePublishPetizioneKoAuthorComunaleEvent < Decidim::Events::BaseEvent
      include Decidim::Events::EmailEvent
      include Decidim::Events::NotificationEvent

      def email_greeting
        return 'Caro ' + @user.nickname + ','
      end

      def email_subject
        return 'La petizione "' + translated_attribute(@resource.title) + '" non ha ottenuto le firme necessarie.'
      end

      def email_intro
        return ''
      end

      def resource_text
        return 'purtroppo la tua petizione "' + translated_attribute(@resource.title) + '" non ha raggiunto le ' + @resource.supports_required.to_s + ' firme valide necessarie.<br/>
I controlli formali eseguiti sulle sottoscrizioni hanno dato esito negativo rispetto a quanto previsto dall\'<a href="https://partecipazione.comune.milano.it/pages/regoledellapartecipazione" target="_blank">art 9 dello Statuto Comunale</a><br/>
Pertanto, la petizione non può essere accolta.<br/>
Ti ringraziamo e restiamo a tua disposizione per eventuali chiarimenti.'
      end

      def email_outro
        return 'A presto!
Lo Staff di Milano Partecipa'
      end

    end
  end
end
