class ApplicationController < ActionController::Base
 skip_before_action :verify_authenticity_token
 # protect_from_forgery with: :null_session
 before_action :ssologin
 require 'savon' 
 #helper_method :current_user, :signed_in?, :is_admin?
 helper_method :is_admin?
 # metodo index aggiunto per il context
 
 before_action :set_default_locale, :check_cie

    def check_cie
        unless current_user.nil?
            current_uri = request.env['PATH_INFO']
            if current_user.birthdate.nil?
                cf = current_user.codice_fiscale.to_s
                unless current_user.nil?
                    if age_from_cf(cf) == 1
						if current_uri != '/pages/access-denied' && current_uri != '/logout/slo' && current_uri != '/users/auth/saml/slo' && current_uri != '/logout'
                            redirect_to 'https://partecipazione.comune.milano.it/pages/access-denied' 
                        end
                    end
                end
                Rails.logger.info "\n\n\n HO USATO IL CODICE FISCALE PER IL CONTROLLO DELL'ETA'"
            else
                # IL CAMPO BIRTHDATE NON E' NULLO QUINDI USO LA DATA DI NASCITA
                dataDiNascita = current_user.birthdate.to_s
                anno = dataDiNascita[0] + dataDiNascita[1] + dataDiNascita[2] + dataDiNascita[3] 	 	
                mese = dataDiNascita[5] + dataDiNascita[6] 	 					
                giorno = dataDiNascita[8] + dataDiNascita[9]					 	
                dataDiNascitaDatetime = DateTime.new(anno.to_i, mese.to_i, giorno.to_i, 0, 0, 0, 0)
                dataAttuale = DateTime.now
                if dataDiNascitaDatetime >= DateTime.now - 16.years
                    if current_uri != '/pages/access-denied' && current_uri != '/logout/slo' && current_uri != '/users/auth/saml/slo' && current_uri != '/logout'
                        redirect_to 'https://partecipazione.comune.milano.it//pages/access-denied' 
                    end
                end
                Rails.logger.info "\n\n\n HO USATO LA DATA DI NASCITA PER IL CONTROLLO DELL'ETA'"
            end
        end
    end
       
    def age_from_cf(cf)
		Rails.logger.info "CF: " + cf
        retval = 0
        # calcolo la data di nascita 
		#anno = "19" + cf[6,2]
		if cf[6,2].to_i < 21
			anno = "20" + cf[6,2]
		else
			anno = "19" + cf[6,2] 		# due cifre a partire dalla sesta posizione
		end
        mese = get_month(cf[8])        # prendo il carattere che identifica il mese
        giorno = cf[9,2]	        # due cifre a partire dalla nona posizione
        if giorno.to_i > 31
            # l'utente è donna quindi tolgo 40
            giorno = giorno.to_i - 40
        end
		Rails.logger.info "Anno: " + anno
		Rails.logger.info "Mese: " + mese
		Rails.logger.info "Giorno: " + giorno
        dataNascita = DateTime.new(anno.to_i, mese.to_i, giorno.to_i, 0, 0, 0)
        dataConfronto = DateTime.now - 16.years
        #Rails::logger.info "luca -> ###############################################################"
        Rails::logger.info "nascita ->  " + dataNascita.to_s
        Rails::logger.info "confronto ->  " + dataConfronto.to_s		
        #Rails::logger.info "luca ->  " + cf.to_s		
        #Rails::logger.info "luca -> ###############################################################"
        if dataNascita.to_s >= dataConfronto.to_s
            retval = 1
        end
        return retval
    end
       
    def get_month(ch)
        return "01" if ch == "A"
        return "02" if ch == "B"
        return "03" if ch == "C"
        return "04" if ch == "D"
        return "05" if ch == "E"
        return "06" if ch == "H"
        return "07" if ch == "L"
        return "08" if ch == "M"
        return "09" if ch == "P"
        return "10" if ch == "R"
        return "11" if ch == "S"
        return "12" if ch == "T"
    end
       
  def set_default_locale
    I18n.default_locale = :it
  end
 
# before_action :authenticate_user!
  def redirect_to_decidim
    redirect_to "/decidim"
  end
  def is_admin?
    self.user_role == 1
  end


def saml_settings

	idp_metadata_xml = File.read(Dir.pwd + '/app/controllers/wsdl/idp_metadata.xml')
        idp_metadata_parser = OneLogin::RubySaml::IdpMetadataParser.new
        # Returns OneLogin::RubySaml::Settings prepopulated with idp metadata
        # settings = idp_metadata_parser.parse_remote("https://sso.comune.milano.it/openam/saml2/jsp/exportmetadata.jsp?entityid=IDP_CdM&realm=/Servizi")
settings = idp_metadata_parser.parse_to_hash(idp_metadata_xml)
  #     settings.assertion_consumer_service_url = "http://#{request.host}/saml/consume"
  #     settings.sp_entity_id                   = "http://#{request.host}/saml/metadata"
  #     settings.name_identifier_format         = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
        # Optional for most SAML IdPs
  #     settings.authn_context = "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"
logger.warn "+*+* BEGIN RAW SAML ***" + settings.to_json
render :json => settings
      end





  def ssologin
   
    @utente_disabilitato = false
    if  !current_user.nil? && current_user.utente_disabilitato?
      @utente_disabilitato = true
      current_user.update!(
         deleted_at: nil,
         email_on_notification: true,
      )
      current_user.save
    end


    logger.warn "*** BEGIN RAW ALL REQUEST HEADERS ***"
    self.request.headers.each do |header|
	if header[0].include? "HTTP_CDM"
  	   logger.warn "HEADER KEY: #{header[0]}"
       	   logger.warn "HEADER VAL: #{header[1]}"
	end
     end
     logger.warn "*** END RAW ALL REQUEST HEADERS ***"

          
     # @user = Decidim::User.find_by(email: params[:CDM_CF].downcase)
     if(self.request.headers['HTTP_CDM_CF'])
       cf = self.request.headers['HTTP_CDM_CF']
       name = self.request.headers['HTTP_CDM_NAME']
       surname = self.request.headers['HTTP_CDM_SURNAME']
       realm = Rails.configuration.token_autenticazione_servizi # token ws Anagrafe
       individuo = wsanagrafe( cf,realm )
       mail = self.request.headers['HTTP_CDM_MAIL']
       if(individuo)
            matricola =  individuo.body.to_hash[:get_ricerca_individui_xml_response][:get_ricerca_individui_xml_result][:lista_individui][:matricola].to_s
            residente = wsresidenza?(cf,matricola,realm)
            logger.warn "*** BEGIN WS ANAGRAFE ***"
            logger.warn "MATRICOLA: #{matricola}"            
	    logger.warn "RESIDENTE: #{residente}"
	    logger.warn "MAIL: #{mail}"
	    logger.warn "NAME: #{name}"
	    logger.warn "SURNAME: #{surname}"
            logger.warn "*** END WS ANAGRAFE ***"
        end
       @user_t = Decidim::User.find_by(codice_fiscale: cf)
       # render :json => @user
       if(@user_t) # se l'utente esiste lo autentico
	  # logica per ufficalizzare a tempo
          if (residente == false)
           #logica luca
	   Rails.logger.info "\n\n\n"
           Rails.logger.info "CONTROLLO SCADENZA DI UFFICIALIZZAZIONE"
           #se la data attuale è superiore a officialized_until
           #metto a null i campi
           #officialized_at
           #officialized_as
           #officialized_until
           #confirmed_at
           #confirmation_send_at
           if @user_t.officialized_until != nil
             now = Time.now.utc
             Rails.logger.info now.to_s
             Rails.logger.info @user_t.officialized_until.to_s
             if now > @user_t.officialized_until
               Rails.logger.info "Il periodo è scaduto!"
               @user_t.officialized_at = nil
               @user_t.officialized_as = nil
               @user_t.officialized_until = nil
               @user_t.confirmed_at = nil
               @user_t.officialized_until = nil
               @user_t.confirmation_sent_at = nil
               @user_t.save!
               Rails.logger.info "L'utente è stato aggiornato!"
            end 
	  end
          Rails.logger.info "FINE CONTROLLO"
          Rails.logger.info "\n\n\n"
	else
            #in questo braccio l'utente è residente
            @user_t.officialized_at = DateTime.now
            @user_t.officialized_until = DateTime.now + 500.years
	    @user_t.save!
            Rails.logger.info "L'utente è stato aggiornato!"
        end
	 
	 sign_in @user_t
          #  redirect_to "/decidim"

       else # creo l'utente
         current_organization = Decidim::Organization.first
         regular_user = Decidim::User.find_or_initialize_by(codice_fiscale: cf)
         password = SecureRandom.urlsafe_base64
	 if (residente == true)
	   confirmed = Time.current
	   confirmed_as = {'ca': '','en': '','es': '','it': ''}
         else
           confirmed =  nil
	   confirmed_as = nil
	 end

	 regular_user.name = name + ' ' + surname
	 regular_user.email = mail
	 regular_user.nickname = Decidim::UserBaseEntity.nicknamize(name, organization: current_organization)
	 regular_user.password = password
	 regular_user.password_confirmation = password
	 regular_user.email_on_notification = true
	 regular_user.confirmed_at = Time.current
	 regular_user.officialized_at = confirmed
	 regular_user.officialized_as = confirmed_as
	 regular_user.locale = I18n.default_locale
	 regular_user.organization = current_organization
	 regular_user.tos_agreement = true
	 regular_user.accepted_tos_version = current_organization.tos_version
	 regular_user.codice_fiscale = cf
	 regular_user.save!


=begin
         regular_user.update!(
           name: name + ' ' + surname,
           email: mail,
           nickname: Decidim::UserBaseEntity.nicknamize(name, organization: current_organization),
           password: password,
           password_confirmation: password,
	   email_on_notification: true
           confirmed_at: Time.current,
	   officialized_at: confirmed,
	   officialized_as: confirmed_as,
           locale: I18n.default_locale,
           organization: current_organization,
           tos_agreement: true,
           #personal_url: Faker::Internet.url,
           #about: Faker::Lorem.paragraph(2),
           accepted_tos_version: current_organization.tos_version,
           codice_fiscale: cf
         )
=end
	 logger.warn "*** BEGIN WS test ANAGRAFE ***"
            logger.warn "MATRICOLA: #{matricola}"
            logger.warn "RESIDENTE: #{residente}"
            logger.warn "MAIL: #{mail}"
            logger.warn "NAME: #{name}"
            logger.warn "SURNAME: #{surname}"
	    logger.warn "USER: #{regular_user}"
            logger.warn "*** END WS test ANAGRAFE ***"
           sign_in regular_user
	  end
     else
	   #redirect_to :controller => 'login_error',:action => 'show' # "/decidim/login_error"
	     	
	    # return render :file => "app/views/decidim/login_error/index.html.erb"
	   # redirect_to ENV["SERVER_COMUNE"] 
     end
    end

  def self.wsanagrafe(cf,realm)
        params = { 
            "Applicazione" => "DECIDIM", 
            "Operatore" => "DECIDI", 
            "PwdOperatore" => "DECIDI20", 
            "Account" => cf, 
            "Cognome" => "",
            "Nome" => "",
            "DataNascitaDAL" => "",
            "DataNascitaAL" => "",
            "DataMorteDAL" => "",
            "DataMorteAL" => "",
            "ComuneNascita" => 0,
            "Sesso" => "",
            "CodiceFiscale" => cf,
            "NumeroFamiglia" => 0,
            "CartaIdentita" => "",
            "TipoRicerca" => "N",
            "FiltroEstrazione" => "T"
            
            }
        client = Savon.client(
            wsdl: Dir.pwd + '/app/controllers/wsdl/admin--Anagrafe1.3.wsdl',
            headers: { 'Authorization:' => 'Bearer ' + realm },
            log: true,
            log_level: :debug,
            logger: Logger.new('log/savon.log', 10, 1024000),
            pretty_print_xml: true
        )
        begin
          response = client.call(
            :get_ricerca_individui_xml,
            message: params
          )
        rescue Savon::Error => soap_fault
        #render :json => "Error: #{soap_fault}\n"
          #print "Error: #{soap_fault}\n"
        end
        #response = nil
        #response = client.call(:get_ricerca_individui_xml, message: params)
        #response = client.request :get_ricerca_individui_xml
        #render :json => response
        # render :json => Dir.pwd #File.expand_path('admin--Anagrafe1.3.wsdl')
    end
    

    # controllo che l\'utente sia residente o no
  def self.wsresidenza?(cf,matricola,realm)

        params = { 
            "Applicazione" => "DECIDIM", 
            "Operatore" => "DECIDI", 
            "PwdOperatore" => "DECIDI20", 
            "Account" => cf, 
            "Matricola" => matricola
            
            }
        client = Savon.client(
            wsdl: Dir.pwd + '/app/controllers/wsdl/admin--Anagrafe1.3.wsdl',
            headers: { 'Authorization:' => 'Bearer ' + realm },
            log: true,
            log_level: :debug,
            logger: Logger.new('log/test.log', 10, 1024000),
            pretty_print_xml: true
        )
        #render :json => client2
        begin
          response = client.call(
            :get_dati_puntuali_xml,
            message: params
          )
        codice_status_anagrafico = response.body.to_hash[:get_dati_puntuali_xml_response][:get_dati_puntuali_xml_result][:dati_individuo][:codice_status_anagrafico].to_s
        codice_status_anagrafico == "A"
        
        rescue Savon::Error => soap_fault
          print "Error: #{soap_fault}\n"
        end
        
    end
    def customredirect
        redirect_to '/'
    end

    

   #   def current_user
   # 	@current_user ||= Decidim::User.find(session[:user_id]) if session[:user_id]
   #   end
   #   def signed_in?
   #	 !!current_user
     # end
end
