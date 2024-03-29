# frozen_string_literal: true

require 'uri'

module Spid
  module Saml2
    class ServiceProvider # :nodoc:
      attr_reader :host
      attr_reader :entity_id
      attr_reader :acs_binding
      attr_reader :slo_binding
      attr_reader :metadata_path
      attr_reader :private_key
      attr_reader :certificate
      attr_reader :signature_method
      attr_reader :attribute_services
      attr_reader :organization_name
      attr_reader :organization_display_name
      attr_reader :organization_url
      attr_reader :contact_person_mail
      attr_reader :slo
      attr_reader :acs
      attr_reader :signed_metadata_path
      attr_reader :acs_index
      attr_reader :slo_index

      def initialize(
        host:,
        entity_id:,
        acs_binding:,
        slo_binding:,
        metadata_path:,
        private_key:,
        certificate:,
        signature_method:,
        attribute_services:,
        organization_name:,
        organization_display_name:,
        organization_url:,
		contact_person_mail:,
        acs:,
        slo:,
        signed_metadata_path:,
        acs_index:,
        slo_index:
      )
        @host = host
        @entity_id = entity_id
        @acs_binding            = acs_binding
        @slo_binding            = slo_binding
        @metadata_path          = metadata_path
        @private_key            = private_key
        @certificate            = certificate
        @signature_method       = signature_method
        @attribute_services     = attribute_services
        @organization_name      = organization_name
        @organization_display_name = organization_display_name
        @organization_url = organization_url
		@contact_person_mail	= contact_person_mail
        @acs          = acs
        @slo          = slo
        @signed_metadata_path = signed_metadata_path
        @acs_index         = acs_index
        @slo_index         = slo_index
        validate_digest_methods
        validate_attributes
        validate_private_key
        validate_certificate
      end

      def acs_url
        @acs_url ||= @acs[@acs_index][:acs_url]
      end

      def slo_url
        @slo_url ||= @slo[@slo_index][:slo_url]
      end

      def metadata_url
        @metadata_url ||= URI.join(host, metadata_path).to_s
      end

      private

      def validate_attributes
        if attribute_services.empty?
          raise MissingAttributeServicesError,
                'Provide at least one attribute service'
        elsif attribute_services.any? { |as| !validate_attribute_service(as) }
          raise UnknownAttributeFieldError,
                'Provided attribute in services are not valid:' \
                " use only fields in #{ATTRIBUTES.join(', ')}"
        end
      end

      def validate_attribute_service(attribute_service)
        return false unless attribute_service.key?(:name)
        return false unless attribute_service.key?(:fields)

        not_valid_fields = attribute_service[:fields].map(&:to_sym) - ATTRIBUTES
        not_valid_fields.empty?
      end

      def validate_digest_methods
        unless SIGNATURE_METHODS.include?(signature_method)
          raise UnknownSignatureMethodError,
                'Provided digest method is not valid:' \
                " use one of #{SIGNATURE_METHODS.join(', ')}"
        end
      end

      def validate_private_key
        return true if private_key.n.num_bits >= 1024

        raise PrivateKeyTooShortError,
              'Private key is too short: provide at least a ' \
              ' private key with 1024 bits'
      end

      def validate_certificate
        return true if certificate.verify(private_key)

        raise CertificateNotBelongsToPKeyError,
              'Provided a certificate signed with current private key'
      end
    end
  end
end
