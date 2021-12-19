# frozen_string_literal: true

module Decidim
  module Referendums
    # Mailer for referendums engine.
    class ReferendumsMailer < Decidim::ApplicationMailer
      include Decidim::TranslatableAttributes
      include Decidim::SanitizeHelper

      add_template_helper Decidim::TranslatableAttributes
      add_template_helper Decidim::SanitizeHelper

      # Notifies referendum creation
      def notify_creation(referendum)
        return if referendum.author.email.blank?

        @referendum = referendum
        @organization = referendum.organization
        @link = decidim_admin_referendums.edit_referendum_url(referendum, host: @organization.host)
        with_user(referendum.author) do
          @subject = "Hai creato un referendum " + translated_attribute(referendum.title) + ". Segui le istruzioni per procedere"


          mail(to: "#{referendum.author.name} <#{referendum.author.email}>", subject: @subject, body: @body)
        end
      end

      def notify_validating_to_author(referendum)
        return if referendum.author.email.blank?

        @referendum = referendum
        @organization = referendum.organization
        @link = decidim_admin_referendums.edit_referendum_url(referendum, host: @organization.host)
        with_user(referendum.author) do
          @subject = "Referendum inviato a convalida tecnica"

          mail(to: "#{referendum.author.name} <#{referendum.author.email}>", subject: @subject)
        end
      end

      # Notify changes in state
      def notify_state_change(referendum, user, state)
        return if user.email.blank?

        @organization = referendum.organization

        with_user(user) do
          @subject = I18n.t(
            "decidim.referendums.referendums_mailer.status_change_for",
            title: translated_attribute(referendum.title)
          )

	  if state.to_s == "published"
            stato = "pubblicato"
          elsif state.to_s == "discarded"
            stato = "scartato"
          elsif state.to_s == "rejected"
            stato = "rifiutato"
          elsif state.to_s == "accepted"
            stato = "accettato"
          end

	  @link2 = referendum_url(referendum, host: @organization.host)
	  if stato == 'pubblicato'
      @subject = "Il referendum "+translated_attribute(referendum.title)+" è stato ammesso alla raccolta firme online"
          @body = "Congratulazioni "+user.name+"!<br/>
La tua proposta referendaria <a href=\""+@link2+"\">"+translated_attribute(referendum.title)+"</a> è stata ammessa alla raccolta firme online. Risulta infatti avere già ricevuto riscontro positivo dal Collegio dei Garanti.<br/>
Il referendum può essere da subito sottoscritto online da tutti i cittadini aventi diritto.<br/>
Ti ricordiamo che puoi contestualmente raccogliere le sottoscrizioni anche sui tradizionali moduli cartacei vidimati, alla presenza di un autenticatore.<br/>
<a href=\"https://partecipazione.comune.milano.it/pages/referendum\">Maggiori informazioni</a>   <br/>
Buona fortuna!<br/>
"    
	  elsif stato == 'scartato'
      @subject = "Il referendum "+translated_attribute(referendum.title)+" non è stata ammesso"
		  @body = "Ciao "+user.name+".<br/>
Ci dispiace ma la tua proposta referendaria <a href=\""+@link2+"\">"+translated_attribute(referendum.title)+"</a>  non può essere accolta per la raccolta firme online perché non conforme ai requisiti di ammissibilità previsti dal Comune di Milano.<br/>
Ti ricordiamo che, per ricevere la convalida tecnica, ovvero essere ammessa alla raccolta firme online, la proposta referendaria deve avere già ottenuto almeno 1000 sottoscrizioni valide, apposte su moduli cartacei alla presenza di un autenticatore. Le firme dovranno essere già state validate dall’Ufficio elettorale. Il quesito referendario deve quindi essere già stato trasmesso al Collegio dei Garanti, per il parere di fattibilità.<br/> 
La tua proposta referendaria non risulta avere completato questi passaggi preliminari, pertanto non può essere ammessa alla raccolta firme online.<br/>
Non esitare a contattarci per ulteriori informazioni su Milano Partecipa.<br/>
A presto!<br/>"
	  else
		  @body = "Il referendum "+translated_attribute(referendum.title)+" è stato "+stato.to_s+".<br />Puoi vedere i dettagli <a href='"+@link2+"'>qui.</a>"          
	  end

          if state.to_s == "published" || state.to_s == "accepted"
            @body += "<br /><br />Congratulazioni!<br />Lo Staff di Milano Partecipa"
          else
            @body += "<br /><br />Lo Staff di Milano Partecipa"
          end

			if state.to_s != 'accepted' && state.to_s != 'rejected'
				mail(to: "#{user.name} <#{user.email}>", subject: @subject)
			end
        end
      end

      # Notify an referendum requesting technical validation
      def notify_validating_request(referendum, user)
        return if user.email.blank?

        @organization = referendum.organization
        @link = decidim_admin_referendums.edit_referendum_url(referendum, host: @organization.host)

        with_user(user) do
          @subject = I18n.t(
            "decidim.referendums.referendums_mailer.technical_validation_for",
            title: translated_attribute(referendum.title)
          )
          @body = I18n.t(
            "decidim.referendums.referendums_mailer.technical_validation_body_for",
            title: translated_attribute(referendum.title)
          )

          mail(to: "#{user.name} <#{user.email}>", subject: @subject)
        end
      end

      def notify_start_validation_signature_date(referendum, user)
        return if user.email.blank?

        @organization = referendum.organization
        @link = referendum_url(referendum, host: @organization.host)

        with_user(user) do
          @subject = I18n.t(
              "decidim.referendums.referendums_mailer.validation_signature_started",
              title: translated_attribute(referendum.title)
          )
          @body = I18n.t(
              "decidim.referendums.referendums_mailer.validation_signature_started_body_for",
              title: translated_attribute(referendum.title),
              author_name: user.name
          )

          mail(to: "#{user.name} <#{user.email}>", subject: @subject)
        end
      end


      def notify_end_signature_date(referendum, user)
        return if user.email.blank?

        @organization = referendum.organization
        @link = referendum_url(referendum, host: @organization.host)

        with_user(user) do
          @subject = I18n.t(
              "decidim.referendums.referendums_mailer.end_signature_upload",
              title: translated_attribute(referendum.title)
          )
          @body = I18n.t(
              "decidim.referendums.referendums_mailer.end_signature_upload_body_for",
              title: translated_attribute(referendum.title),
              author_name: user.name

          )

          mail(to: "#{user.name} <#{user.email}>", subject: @subject)
        end
      end

      def notify_start_signature_date(referendum, user)
        return if user.email.blank?

        @organization = referendum.organization
        @link = referendum_url(referendum, host: @organization.host)

        with_user(user) do
          @subject = I18n.t(
              "decidim.referendums.referendums_mailer.start_signature_upload",
              title: translated_attribute(referendum.title)
          )
          @body = I18n.t(
              "decidim.referendums.referendums_mailer.start_signature_upload_body_for",
              title: translated_attribute(referendum.title),
              end_date: referendum.signature_end_date,
              author_name: user.name
          )

          mail(to: "#{user.name} <#{user.email}>", subject: @subject)
        end
      end

      # Notify progress to all referendum subscribers.
      def notify_progress(referendum, user)
        return if user.email.blank?

        @organization = referendum.organization
        @link = referendum_url(referendum, host: @organization.host)

        with_user(user) do
          @body = I18n.t(
            "decidim.referendums.referendums_mailer.progress_report_body_for",
            title: translated_attribute(referendum.title),
            percentage: referendum.percentage
          )

          @subject = I18n.t(
            "decidim.referendums.referendums_mailer.progress_report_for",
            title: translated_attribute(referendum.title)
          )

          mail(to: "#{user.name} <#{user.email}>", subject: @subject)
        end
      end

      ######################## CR

      # Notifica una settimana prima della scadenza delle firme
      def notify_one_week_before_end(referendum, user)
        return if user.email.blank?

        @organization = referendum.organization
        @link = referendum_url(referendum, host: @organization.host)

        with_user(user) do
          @body = "Manca una settimana prima della chiusura della raccolta firme per il referendum #{translated_attribute(referendum.title)}."
          @subject = "Scadenza imminente per la raccolta firme (#{translated_attribute(referendum.title)})"
          mail(to: "#{user.name} <#{user.email}>", subject: @subject)
        end
      end

      ######################## CR DICEMBRE

      # Notifica una settiamana prima della scadenza del referendum
      def notify_one_week_before_end_referendum(referendum, user)
        return if user.email.blank?

        @organization = referendum.organization
        @link = referendum_url(referendum, host: @organization.host)

        with_user(user) do
          @body = "Manca una settimana prima della chiusura del referendum #{translated_attribute(referendum.title)}."
          @subject = "Chiusura imminente del referendum (#{translated_attribute(referendum.title)})"
          mail(to: "#{user.name} <#{user.email}>", subject: @subject)
        end
      end

      # Notifica un giorno dopo la scadenza del referendum
      def notify_one_day_after(referendum, user)
        return if user.email.blank?

        @organization = referendum.organization
        @link = referendum_url(referendum, host: @organization.host)

        with_user(user) do
          @body = "Si avvisa che il referendum #{translated_attribute(referendum.title)} \u00E8 scaduto."
          @subject = "Chiusura referendum (#{translated_attribute(referendum.title)})"
          mail(to: "#{user.name} <#{user.email}>", subject: @subject)
        end
      end



    end
  end
end
