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

      xml_document = self.class.csv_transform_job.perform(csv_path: csv_path)

      File.open(xml_path, "w") do |f|
        f.write(xml_document.to_xml)
      end

      raise(StandardError, "XML Document was invalid, please see #{xml_path}") unless xml_document.valid?
    end
  end

  class UserFeeds < Cli
    desc 'create', 'Use the Symplectic Elements API to create a new User Feed'
    option :host, aliases: :h, required: true
    option :port, aliases: :P, required: true
    option :endpoint, aliases: :e, required: true
    option :username, aliases: :u, required: true
    option :password, aliases: :p, required: true
    option :id, aliases: :i, required: true
    option :xml_request, aliases: :x, required: true
    def create
      host = options[:host]
      port = options[:port]
      endpoint = options[:endpoint]

      username = options[:username]
      password = options[:password]

      id = options[:id]
      xml_request = options[:xml_request]

      client = Symplectic::Elements::Client.new(host: host, port: port, endpoint: endpoint, username: username, password: password)

      user_feed = client.find_user_feed(id: id)
      user_feed&.delete

      xml = File.read(xml_request)
      user_feed.create(xml: xml)
    end
  end
end
