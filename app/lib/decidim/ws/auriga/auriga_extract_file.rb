module Decidim
  module Ws
    module Auriga

      class AurigaExtractFile
        def initialize()
          @wsdl = Dir.pwd + '/app/controllers/wsdl/auriga/admin--Auriga-ExtractMulti2.0.wsdl'
          @ssl_verify_mode = ':none'
          @ssl_version = ':TLSv1'
        end

        def _call_service(info_array, token, codApplicazione, istanzaApplicazione, userName, idUd)
          begin
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
            return response
          rescue
            raise
          end
        end

        def do_get_file_information(info_array, token, codApplicazione, istanzaApplicazione, userName, idUd)
          begin
            response = _call_service(info_array, token, codApplicazione, istanzaApplicazione, userName, idUd)
            text_encoded = response.attachments[0].body.raw_source
            text_encoded = text_encoded.gsub('&#160;', ' ')
            text_encoded = text_encoded.gsub('?&#062;', '')
            text_decoded = (HTMLEntities.new.decode(text_encoded))
            doc = Nokogiri::XML(text_decoded)
            protocollo = 0
            doc.children[0].children.each do |current_element|
              if current_element.name == 'IdDoc'
                protocollo = current_element.content
              end
            end
            return protocollo
          rescue
            raise
          end
        end

        def do_extract_file(info_array, token, codApplicazione, istanzaApplicazione, userName, idUd)
          begin
            response = _call_service(info_array, token, codApplicazione, istanzaApplicazione, userName, idUd)
            file_content = Base64.decode64(response.attachments[1].body.raw_source)
            return file_content
          rescue
            raise
          end
        end
      end
    end
  end
end