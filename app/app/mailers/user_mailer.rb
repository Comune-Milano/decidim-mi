class UserMailer < ApplicationMailer

  include Decidim::TranslatableAttributes
  include Decidim::SanitizeHelper

  add_template_helper Decidim::TranslatableAttributes
  add_template_helper Decidim::SanitizeHelper


  def notify_officialize_user
    @user = params[:user]
    @body = "Congratulazioni #{@user.name}! Sei stato appena ufficializzato da un amministratore di Milano Partecipa."
    @subject = "Ufficializzazione utente"
    mail(to: "#{@user.name} <#{@user.email}>", subject: @subject)
  end

end