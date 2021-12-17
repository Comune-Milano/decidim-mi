module Decidim
  module Ws
    module Auriga

      class AurigaGetInformationFile
        def initialize()
          @wsdl = Dir.pwd + '/app/controllers/wsdl/auriga/admin--Auriga-GetMetadataUd2.0.wsdl'
          @ssl_verify_mode = ':none'
          @ssl_version = ':TLSv1'
        end

        def _call_service(info_array, token, codApplicazione, istanzaApplicazione, userName, idUd)

        end

        def do_get_file_information(info_array, token, codApplicazione, istanzaApplicazione, userName, idUd)

          xml_mock = '<?xml version="1.0" encoding="UTF-8"?>
<EstremiXIdentificazioneUD>
  <IdUD>' + idUd.to_s() + '</IdUD>
</EstremiXIdentificazioneUD>'
          hash_xml = Digest::SHA1.base64digest(xml_mock)
          params = {
              "codApplicazione" => codApplicazione,
              "istanzaApplicazione" => istanzaApplicazione,
              "userName" => userName,
              "password" => info_array[2],
              "xml" => xml_mock,
              "hash" => hash_xml.to_s
          }

          #client = Savon.client(wsdl: @wsdl, ssl_verify_mode: :none, ssl_version: :TLSv1)
          client = Savon.client(
              wsdl: @wsdl,
              headers: {'Authorization:' => 'Bearer ' + token},
              log: true,
              log_level: :debug,
              logger: Logger.new('log/auriga.log', 10, 1024000),
              pretty_print_xml: true
          )
          response = client.call(:service_operation, message: params)
          text_encoded = response.attachments[0].body.raw_source
          text_encoded = text_encoded.gsub('&#160;', ' ')
          text_encoded = text_encoded.gsub('encoding="UTF-8"', 'encoding="UTF-8" ?>')
          text_decoded = (HTMLEntities.new.decode(text_encoded))
          doc = Nokogiri::XML(text_decoded)
          protocollo = 0
          doc.children[0].children.each do |current_element|
            if current_element.name == 'IdDocPrimario'
              protocollo = current_element.content
            end
          end
          return protocollo
        end
      end
    end
  end
end