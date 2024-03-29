# frozen_string_literal: true

require 'logger'

module Spid
  class Configuration # :nodoc:
    attr_accessor :idp_metadata_dir_path
    attr_accessor :entity_id
    attr_accessor :hostname
    attr_accessor :metadata_path
    attr_accessor :login_path
    attr_accessor :logout_path
    attr_accessor :acs_path
    attr_accessor :slo_path
    attr_accessor :signature_method
    attr_accessor :default_relay_state_path
    attr_accessor :organization_name
    attr_accessor :organization_display_name
    attr_accessor :organization_url
    attr_accessor :contact_person_mail
    attr_accessor :acs_binding
    attr_accessor :slo_binding
    attr_accessor :acs
    attr_accessor :slo
    attr_accessor :acs_index
    attr_accessor :slo_index
    attr_accessor :signed_metadata_path
    attr_accessor :attribute_services
    attr_accessor :private_key_pem
    attr_accessor :certificate_pem
    attr_accessor :logging_enabled
    attr_accessor :logger

    def initialize
      @idp_metadata_dir_path     = 'idp_metadata'
      @attribute_services        = []
      @logging_enabled           = true
      @logger                    = ::Logger.new $stdout
      init_endpoint
      init_bindings
      init_dig_sig_methods
      init_openssl_keys
    end

    def init_endpoint
      @hostname = nil
      @entity_id = nil
      @metadata_path             = '/spid/metadata'
      @login_path                = '/spid/login'
      @logout_path               = '/spid/logout'
      @default_relay_state_path  = '/users/auth/spidauth/callback'
      @organization_name = ''
      @organization_display_name = ''
      @organization_url = ''
      @signed_metadata_path = ''
	  @contact_person_mail = ''
    end

    def init_bindings
      @acs_binding              = Spid::BINDINGS_HTTP_REDIRECT
      @slo_binding              = Spid::BINDINGS_HTTP_POST
    end

    def init_dig_sig_methods
      @signature_method         = Spid::RSA_SHA256
    end

    def init_openssl_keys
      @private_key              = nil
      @certificate              = nil
    end

    def certificate
      return nil if certificate_pem.nil?

      @certificate ||= OpenSSL::X509::Certificate.new(certificate_pem)
    end

    def private_key
	  p "private_key_pem"
	  p private_key_pem
      return nil if private_key_pem.nil?

      @private_key ||= OpenSSL::PKey::RSA.new(private_key_pem)
    end

    def service_provider
      @service_provider ||=
        begin
          Spid::Saml2::ServiceProvider.new(
            acs_binding: acs_binding, slo_binding: slo_binding, metadata_path: metadata_path,
            private_key: private_key, certificate: certificate,
            signature_method: signature_method,
            attribute_services: attribute_services, entity_id: entity_id, host: hostname,
            organization_name: organization_name, organization_display_name: organization_display_name, organization_url: organization_url,
            acs: acs, slo: slo, signed_metadata_path: signed_metadata_path, acs_index: acs_index, slo_index: slo_index, contact_person_mail: contact_person_mail
          )
        end
    end
  end
end
