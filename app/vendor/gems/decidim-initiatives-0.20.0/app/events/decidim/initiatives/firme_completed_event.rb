# frozen-string_literal: true

module Decidim
  module Initiatives
    class FirmeCompletedEvent < Decidim::Events::SimpleEvent
      i18n_attributes :percentage

      def email_greeting
        return 'Congratulazioni ' + @user.name + ','
      end

      def email_subject
        return 'Obiettivo raggiunto!'
      end

      def email_intro
        return ''
      end

      def resource_text
        return 'La tua petizione '+ translated_attribute(@resource.title) +' ha raggiunto l\'obiettivo di firme online. Verrà ora trasmessa agli uffici competenti. Riceverai una nostra comunicazione con le informazioni sui prossimi passi.'
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
