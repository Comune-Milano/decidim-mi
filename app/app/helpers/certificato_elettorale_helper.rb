
module CertificatoElettoraleHelper

  def check_elettore_abilitato (codice_fiscale)

	  token = Rails.configuration.token_autenticazione_servizi
    params = {
        "Applicazione" => "DECIDIM",
        "Operatore" => "DECIDI",
        "PwdOperatore" => "DECIDI20",
        "Account" => codice_fiscale,
        "CodiceFiscale" => codice_fiscale,

    }
    begin
      client = Savon.client(
          wsdl: Dir.pwd + '/app/controllers/wsdl/admin--CertificatoElettorale1.3.wsdl',
          headers: { 'Authorization:' => 'Bearer ' + token },
          log: true,
          log_level: :debug,
          logger: Logger.new('log/savon.log', 10, 1024000),
          pretty_print_xml: true
      )
      response = client.call(
          :get_elettore_xml,
          message: params
      )
    rescue StandardError => e
      return false
    end
    is_elettore = response.body.to_hash[:get_elettore_xml_response][:get_elettore_xml_result][:elettore][:elettore]
    if (is_elettore == 'S')
      return true
    else
      return false
    end
    return false
  end
end
