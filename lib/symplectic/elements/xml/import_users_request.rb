# frozen_string_literal: true

module Symplectic
  module Elements
    module XML
      class ImportUsersRequest
        def self.schema_path
          Pathname.new('xsd/import_users_request.xsd')
        end

        def self.schema_file
          File.read(schema_path)
        end

        def self.schema_document
          Nokogiri::XML::Schema(schema_file)
        end

        def self.xml_path
          Pathname.new('xml/import_users_request.xml')
        end

        def self.xml_file
          File.read(xml_path)
        end

        def self.build
          Nokogiri::XML(xml_file)
        end

        def self.namespaces
          {
            xs: 'http://www.w3.org/2001/XMLSchema',
            api: 'http://www.symplectic.co.uk/publications/api'
          }
        end

        attr_reader :document

        def initialize
          @document = self.class.build
        end

        def users
          @users ||= Users.new(parent: self)
        end

        def validation_errors
          @validation_errors ||= self.class.schema_document.validate(@document)
        end

        def valid?
          validation_errors.empty?
        end

        def to_xml
          @document.to_xml
        end
      end
    end
  end
end
