class SenderController < ApplicationController

    def index

    	body = params[:sondaggio]
      mailer = ActionMailer::Base.new
    	mailer.delivery_method
    	mailer.smtp_settings

      #invio l'email a tutti gli admin
      Decidim::User.all.each do |user|
        if user.admin?
          mailer.mail(from: 'noreply', to: user.email, subject: 'CDM: form utente non residente', body: body).deliver
         # logger.info "Inviata email all'admin " + user.email
        end
      end

      #chiudo il modal
    	respond_to do |format|
          format.js { render :js => "document.getElementById('sondaggio').value= ''; document.getElementById('myModal').style.display = 'none'; document.getElementById('myModal3').style.display = 'block';
            document.getElementById('button-close3').onclick = function() { document.getElementById('myModal3').style.display = 'none'; }" }
    	end

    end

end
