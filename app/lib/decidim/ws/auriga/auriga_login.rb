module Decidim
  module Ws
    module Auriga
      class AurigaLogin
        def initialize()
          @wsdl=Dir.pwd + '/app/controllers/wsdl/auriga/admin--Auriga-Login2.0.wsdl'
          @ssl_verify_mode=':none'
          @ssl_version=':TLSv1'
        end

        def do_login(token, codApplicazione,istanzaApp, username, password)
          params = {
              "codApplicazione" => codApplicazione,
              "istanzaApplicazione" => istanzaApp,
              "userName" => username,
              "password" => password,
              "xml" => '',
              "hash" => ''

          }

          client = Savon.client(
              wsdl: @wsdl,
              headers: { 'Authorization:' => 'Bearer ' + token },
              log: true,
              log_level: :debug,
              logger: Logger.new('log/auriga.log', 10, 1024000),
              pretty_print_xml: true
          )
          response = client.call(:service_operation, message: params )

          xml_dati = response.attachments[0].body.raw_source
          token = Nokogiri::XML(xml_dati)
          des_user = token.children[0].attr('DesUser')
          id_dominio = token.children[0].attr('IdDominio')
          token_value = token.content

          return [des_user, id_dominio, token_value]
        end
      end
    end
  end
end