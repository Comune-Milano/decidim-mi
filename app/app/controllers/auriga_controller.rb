include AurigaHelper
class AurigaController < ApplicationController

  def test_login
    @token_login = get_login()
  end

  def test
    ss = Decidim::Ws::Auriga.new(Dir.pwd + '/app/controllers/wsdl/auriga/admin--Auriga-Login2.0.wsdl', ':none', ':TLSv1')
    #ss = Decidim::Ws::Auriga.new('https://your_secret_server_url/webservices/SSWebService.asmx?WSDL', ':none', ':TLSv1')

    token = Rails.configuration.token_autenticazione_servizi
    codApplicazione = "PARTECIPAZIONI"
    istanzaApplicazione = "TEST"
    userName = "user-partecipazioni"
    password = ""
    xml = ""
    hash = ""


    puts " "

    puts "### Authenticate ###"
    token = ss.Authenticate(token,codApplicazione,istanzaApplicazione,userName, password, xml,hash)
    puts token
    puts " "

    puts '-> Finished'
    #@doc = Nokogiri::XML::Document.parse(token.to_json)
    #render json:  token.to_hash
    #render inline: token.to_s
    render :json => token
  end
end