module Decidim
  module Ws
    module Auriga
      class AurigaUploadFile
        def initialize()
          @wsdl=Dir.pwd + '/app/controllers/wsdl/auriga/admin--Auriga-AddUd2.0.wsdl'
          @ssl_verify_mode=':none'
          @ssl_version=':TLSv1'
        end

        def do_upload_file(info_array, token, codApplicazione, istanzaApplicazione, userName, pdf_signed_id, file_name)
          begin
            xml_mock = '<?xml version="1.0" encoding="UTF-8"?>
  <NewUD>
  <VersioneElettronica>
  <NroAttachmentAssociato>1</NroAttachmentAssociato>
  <NomeFile>'+ file_name.to_s() +'</NomeFile>
  </VersioneElettronica>
  <NroAllegati>1</NroAllegati>
  </NewUD>'
            hash_xml = Digest::SHA1.base64digest(xml_mock)
            params = {
                "codApplicazione" => codApplicazione,
                "istanzaApplicazione" => istanzaApplicazione,
                "userName" => userName,
                "password" => info_array[2],
                "xml" => xml_mock,
                "hash" => hash_xml.to_s
            }

            pdf = Dir.pwd + '/public' + file_name.to_s()
            client = Savon.client(
                wsdl: @wsdl,
                headers: { 'Authorization:' => 'Bearer ' + token },
                log: true,
                log_level: :debug,
                logger: Logger.new('log/auriga_addud.log', 10, 1024000),
                pretty_print_xml: true
            )
            response = client.call(:service_operation, message: params,
                                   multipart: true ,
                                   attachments: [pdf])
            text_encoded = response.attachments[0].body.raw_source
            text_encoded = text_encoded.gsub('&#160;', ' ')
            text_encoded = text_encoded.gsub('?&#062;', '')
            text_decoded = (HTMLEntities.new.decode(text_encoded))
            doc = Nokogiri::XML(text_decoded)
            id_ud = doc.children[0].children.to_s()
            return id_ud
          rescue
            raise
          end
        end
      end
    end
  end
end