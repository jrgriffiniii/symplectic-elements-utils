# frozen_string_literal: true

require_relative 'lib/symplectic'
require 'thor'

module Elements
  class Cli < Thor
    no_commands do
      def self.exit_on_failure?
        true
      end

      def self.csv_transform_job
        Symplectic::Elements::CSV::TransformJob
      end
    end
  end

  class Csv < Cli
    desc 'transform', 'generate the XML from the CSV'
    option :csv_import, aliases: :i, required: true
    option :xml_export, aliases: :e, required: true
    def transform
      csv_path = options[:csv_import]
      xml_path = options[:xml_export]

      xml_document = self.class.csv_transform_job.perform(csv_path: csv_path, xml_path: xml_path)

      File.open(xml_path, "w") do |f|
        f.write(xml_document.to_xml)
      end

      raise(StandardError, "XML Document was invalid, please see #{xml_path}") unless xml_document.valid?
    end
  end
end
