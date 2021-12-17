# frozen_string_literal: true

module Decidim
  module Ws


    class Auriga

      def initialize(wsdl, ssl_verify_mode, ssl_version)
        @wsdl=wsdl
        @ssl_verify_mode=ssl_verify_mode
        @ssl_version=ssl_version
        client = Savon.client(wsdl: @wsdl, ssl_verify_mode: :none, ssl_version: :TLSv1)
      end

      def Authenticate(token, codApplicazione,istanzaApp, username, password , xml ='',hash='')
        params = {
            "codApplicazione" => codApplicazione,
            "istanzaApplicazione" => istanzaApp,
            "userName" => username,
            "password" => password,
            "xml" => xml,
            "hash" => hash

        }
        #client = Savon.client(wsdl: @wsdl, ssl_verify_mode: :none, ssl_version: :TLSv1)
        client = Savon.client(
            wsdl: @wsdl,
            headers: { 'Authorization:' => 'Bearer ' + token },
            log: true,
            log_level: :debug,
            logger: Logger.new('log/auriga.log', 10, 1024000),
            pretty_print_xml: true
        )
        response = client.call(:service_operation, message: params )

        @token = response.body.to_hash[:serviceResponse][:serviceReturn].to_s
        if response.success?
          false
        return @token
      end
        end
      def GetTokenIsValid
        client = Savon.client(wsdl: @wsdl, ssl_verify_mode: :none, ssl_version: :TLSv1)
        response = client.call(:get_token_is_valid, message: {
            token: @token
        })

        return response
      end

      def GetSecret(secretId)
        thesame = lambda { |key| key }

        client = Savon.client(wsdl: @wsdl, ssl_verify_mode: :none, ssl_version: :TLSv1, convert_request_keys_to: :none) #, convert_response_tags_to: thesame)
        response = client.call(:get_secret, message: {
            token: @token,
            secretId: secretId,
        })
        return response.to_xml
      end

      def UpdateSecret(secret)
        client = Savon.client(wsdl: @wsdl, ssl_verify_mode: :none, ssl_version: :TLSv1)
        # Nokogiri is stripping the 'xsi' prefix which is required, and it also puts a 'default' prefix in, which is disallowed.
        fixedXml = secret.to_s.gsub! 'nil=', 'xsi:nil='
        fixedXml = fixedXml.gsub! 'default:',''

        response = client.call(:update_secret, xml: fixedXml)
        return response
      end

      def WhoAmI
        client = Savon.client(wsdl: @wsdl, ssl_verify_mode: :none, ssl_version: :TLSv1)
        response = client.call(:who_am_i, message: {
            token: @token
        })
        return response
      end

      def VersionGet
        client = Savon.client(wsdl: @wsdl, ssl_verify_mode: :none, ssl_version: :TLSv1)
        response = client.call(:version_get, message: {
            token: @token
        })
        return response
      end

    end
  end
end
