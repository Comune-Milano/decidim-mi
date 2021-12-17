require "decidim/ws/auriga/auriga_extract_file.rb"
require "decidim/ws/auriga/auriga_get_information_file.rb"
require "decidim/ws/auriga/auriga_login.rb"
require "decidim/ws/auriga/auriga_upload_file.rb"

module AurigaHelper
  def protocolla_auriga_file (pdf_signed_id, file_name)
    token = Rails.configuration.token_autenticazione_servizi
    codApplicazione = "PARTECIPAZIONI"
    istanzaApplicazione = "TEST"
    userName = "user-partecipazioni"
    password = ""

    auriga_login = Decidim::Ws::Auriga::AurigaLogin.new()
    begin
      info_array = auriga_login.do_login(token,codApplicazione,istanzaApplicazione,userName, password)

      auriga_upload_file = Decidim::Ws::Auriga::AurigaUploadFile.new()
      id_ud = auriga_upload_file.do_upload_file(info_array, token,codApplicazione,istanzaApplicazione,userName, pdf_signed_id, file_name)

      auriga_extract_file = Decidim::Ws::Auriga::AurigaGetInformationFile.new()
      protocollo_id = auriga_extract_file.do_get_file_information(info_array, token,codApplicazione,istanzaApplicazione,userName, id_ud)
      return ['id_ud' => id_ud, 'protocollo_id' => protocollo_id]
    rescue
      raise
    end
  end

  def scarica_auriga_file (id_ud)
    token = Rails.configuration.token_autenticazione_servizi
    codApplicazione = "PARTECIPAZIONI"
    istanzaApplicazione = "TEST"
    userName = "user-partecipazioni"
    password = ""

    begin
      auriga_login = Decidim::Ws::Auriga::AurigaLogin.new()
      info_array = auriga_login.do_login(token,codApplicazione,istanzaApplicazione,userName, password)

      auriga_extract_file = Decidim::Ws::Auriga::AurigaExtractFile.new()
      content_stream = auriga_extract_file.do_extract_file(info_array, token,codApplicazione,istanzaApplicazione,userName, id_ud)
      return content_stream
    rescue
      raise
    end
  end
end
