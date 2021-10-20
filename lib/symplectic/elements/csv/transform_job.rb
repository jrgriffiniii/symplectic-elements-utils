# frozen_string_literal: true

require 'csv'
require 'nokogiri'

module Symplectic
  module Elements
    module CSV
      class TransformJob
        # @param [String] path
        # @returns [CSV::Table]
        def self.build_csv_file(path:)
          result = nil
          File.open(path, "r:bom|utf-8") do |f|
            result = ::CSV.parse(f.read, headers: true)
          end
          result
        end

        def self.schema_path
          Pathname.new('xsd/symplectic-api.xsd')
        end

        def self.schema_file
          File.read(schema_path)
        end

        def self.schema_document
          Nokogiri::XML::Schema(schema_file)
        end

        def self.build_request_document
          Symplectic::Elements::XML::ImportUsersRequest.new
        end

        def self.transform(csv_file, xml_document)
          xml_document.title = csv_file[0]
          xml_document.initials = csv_file[1]
          xml_document.first_name = csv_file[2]
          xml_document.last_name = csv_file[3]
          xml_document.known_as = csv_file[4]
          xml_document.suffix = csv_file[5]
          xml_document.email = csv_file[6]
          xml_document.authenticating_authority = csv_file[7]
          xml_document.username = csv_file[8]
          xml_document.proprietary_id = csv_file[9]
          xml_document.primary_group_descriptor = csv_file[10]

          xml_document.is_academic = csv_file[11]
          xml_document.is_current_staff = csv_file[12]
          xml_document.is_login_allowed = csv_file[13]

          unless xml_document.arrive_date_element.nil?
            if csv_file[14].blank?
              xml_document.arrive_date_element.remove
            else
              xml_document.arrive_date = csv_file[14]
            end
          end

          unless xml_document.leave_date_element.nil?
            if csv_file[15].blank?
              xml_document.leave_date_element.remove
            else
              xml_document.leave_date = csv_file[15]
            end
          end

          xml_document.position = csv_file[16]
          xml_document.department = csv_file[17]

          xml_document
        end

        def self.perform(csv_path:)
          csv_table = build_csv_file(path: csv_path)

          request_document = build_request_document
          users = request_document.users

          csv_rows = csv_table.to_a[1..]
          csv_rows.each_with_index do |csv_row, index|
            user = if index.positive?
                     users.append_user
                   else
                     users.last
                   end

            transform(csv_row, user)
          end

          request_document
        end
      end
    end
  end
end
