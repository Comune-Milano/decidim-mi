class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token, raise: false
 
  helper_method :profile_user, :logged_in?, :current_user
  include SessionsHelper
before_action :ssologin
  def ssologin
    logger.warn "**** BEGIN RAW ALL REQUEST HEADERS ***"
    logger.warn response.body.to_json
    self.request.headers.each do |header|
        if header[0].include? "HTTP"
           logger.warn "HEADER KEY: #{header[0]}"
           logger.warn "HEADER VAL: #{header[1]}"
        end
     end
     logger.warn "*** END RAW ALL REQUEST HEADERS ***"
  end

  #non cancellare questo metodo
  #è utile se si vuole il context
  def redirect_to_decidim
    redirect_to "/decidim"
  end


#non cancellare questo metodo
#  #è utile se si vuole il context
#  def redirect_to_api
 #   redirect_to "/api"
#  end


end
