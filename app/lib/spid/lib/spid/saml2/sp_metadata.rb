# frozen_string_literal: true

module Spid
  module Saml2
    class SPMetadata # :nodoc:
      attr_reader :document
      attr_reader :settings

      def initialize(settings:)
        @document = REXML::Document.new
        @settings = settings
      end

      def unsigned_document
        document.add_element(entity_descriptor)
        document.to_s
      end

      def signed_document
        signed_document = File.read(settings.signed_metadata_path) if File.file?(settings.signed_metadata_path)
        signed_document.nil? ? unsigned_document : signed_document
      end

      def to_saml
        signed_document
      end

      def entity_descriptor
        @entity_descriptor ||=
          begin
            element = REXML::Element.new('md:EntityDescriptor')
            element.add_attributes(entity_descriptor_attributes)
            element.add_element sp_sso_descriptor
            element.add_element organization
            element.add_element contact_person
            element
          end
      end

      def entity_descriptor_attributes
        @entity_descriptor_attributes ||= {
          'xmlns:ds' => 'http://www.w3.org/2000/09/xmldsig#',
          'xmlns:md' => 'urn:oasis:names:tc:SAML:2.0:metadata',
		  'xmlns:spid' => 'https://spid.gov.it/saml-extensions',
          'entityID' => settings.sp_entity_id,
          'ID' => entity_descriptor_id
        }
      end

      def sp_sso_descriptor
        @sp_sso_descriptor ||=
          begin
            element = REXML::Element.new('md:SPSSODescriptor')
            element.add_attributes(sp_sso_descriptor_attributes)
            element.add_element key_descriptor

            slo_services ||= settings.slo.map do |slo|
              binding = slo[:slo_binding]
              location = slo[:slo_url]
              response_location = slo[:response_location]
              element.add_element slo_service(
                binding, location, response_location
              )
            end
            @slo_service ||= slo_services[settings.slo_index]

            ac_services ||= settings.acs.map.with_index do |acs, index|
              binding = acs[:acs_binding]
              location = acs[:acs_url]
              element.add_element ac_service(
                binding, location, index
              )
            end
            @ac_service ||= ac_services[settings.acs_index]

            settings.sp_attribute_services.each.with_index do |service, index|
              name = service[:name]
              fields = service[:fields]
              element.add_element attribute_consuming_service(
                index, name, fields
              )
            end

            element
          end
      end

      def organization
        @organization ||=
          element = REXML::Element.new('md:Organization')
        element.add_element organization_name
        element.add_element organization_display_name
        element.add_element organization_url
        element
      end

      def contact_person		
        @contact_person ||=
          element = REXML::Element.new('md:ContactPerson')
		element.add_attributes({"contactType"=>"other"})
        element.add_element contact_person_extensions
        element.add_element contact_person_company
        element.add_element contact_person_mail
        element.add_element contact_person_telephone_number
        element
      end

      def signature
        @signature ||= ::Spid::Saml2::XmlSignature.new(
          settings: settings,
          sign_reference: entity_descriptor_id
        ).signature
      end

      def service_name(name)
        element = REXML::Element.new('md:ServiceName')
        element.add_attributes('xml:lang' => 'it')
        element.text = name
        element
      end

      def requested_attribute(name)
        element = REXML::Element.new('md:RequestedAttribute')
        element.add_attributes('Name' => ATTRIBUTES_MAP[name])
        element
      end

      def sp_sso_descriptor_attributes
        @sp_sso_descriptor_attributes ||= {
          'protocolSupportEnumeration' =>
            'urn:oasis:names:tc:SAML:2.0:protocol',
          'AuthnRequestsSigned' => true,
		  'WantAssertionsSigned' => true
        }
      end

      def ac_service(binding, location, index)
        element = REXML::Element.new('md:AssertionConsumerService')
        element.add_attributes(ac_service_attributes(binding, location, index))
        element
      end

      def attribute_consuming_service(index, name, fields)
        element = REXML::Element.new('md:AttributeConsumingService')
        element.add_attributes('index' => index)
        element.add_element service_name(name)
        fields.each do |field|
          element.add_element requested_attribute(field)
        end
        element
      end

      def ac_service_attributes(binding, location, index)
        acs_attr = {
          'Binding' => binding,
          'Location' => location,
          'index' => index
        }
        acs_attr['isDefault'] = 'true' if index.zero?
        acs_attr
      end

      def slo_service(binding, location, response_location)
        element = REXML::Element.new('md:SingleLogoutService')
        element.add_attributes(slo_attributes(binding, location, response_location))
        element
      end

      def slo_attributes(binding, location, response_location)
        slo_attr = {
          'Binding' => binding,
          'Location' => location
        }
        slo_attr['ResponseLocation'] = response_location if response_location
        slo_attr
      end

      def key_descriptor
        @key_descriptor ||=
          begin
            kd = REXML::Element.new('md:KeyDescriptor')
            kd.add_attributes('use' => 'signing')
            ki = kd.add_element 'ds:KeyInfo'
            data = ki.add_element 'ds:X509Data'
            certificate = data.add_element 'ds:X509Certificate'
            certificate.text = settings.x509_certificate_der
            kd
          end
      end

      private

      def entity_descriptor_id
        @entity_descriptor_id ||=
          begin
            "_#{Digest::MD5.hexdigest(settings.sp_entity_id)}"
          end
      end

      def organization_name
        @organization_name ||=
          begin
            element = REXML::Element.new('md:OrganizationName')
            element.add_attributes('xml:lang' => 'it')
            element.text = settings.organization_name
            element
          end
      end

      def organization_display_name
        @organization_display_name ||=
          begin
            element = REXML::Element.new('md:OrganizationDisplayName')
            element.add_attributes('xml:lang' => 'it')
            element.text = settings.organization_display_name
            element
          end
      end

      def organization_url
        @organization_url ||=
          begin
            element = REXML::Element.new('md:OrganizationURL')
            element.add_attributes('xml:lang' => 'it')
            element.text = settings.organization_url
            element
          end
      end
	  
      def contact_person_extensions
        @contact_person_extensions ||=
          begin
            element = REXML::Element.new('md:Extensions')
			element.add_element contact_person_extensions_fiscal_code
            element
          end
      end

      def contact_person_extensions_fiscal_code
        @contact_person_extensions_fiscal_code ||=
          begin
            element = REXML::Element.new('spid:FiscalCode')
			element.text = 'SBTMRA80L25H501B'
            element
          end
      end

      def contact_person_company
        @contact_person_company ||=
          begin
            element = REXML::Element.new('md:Company')
            element
          end
      end

      def contact_person_mail
        @contact_person_mail ||=
          begin
            element = REXML::Element.new('md:EmailAddress')
            element.text = settings.contact_person_mail
            element
          end
      end

      def contact_person_telephone_number
        @contact_person_telephone_number ||=
          begin
            element = REXML::Element.new('md:TelephoneNumber')
            element
          end
      end

    end
  end
end
