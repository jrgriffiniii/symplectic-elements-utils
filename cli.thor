# frozen_string_literal: true

require_relative 'lib/symplectic'
require 'thor'
require 'yaml'

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
    option :csv_import, aliases: '-i', required: true
    option :xml_export, aliases: '-e', required: true
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
    option :host, aliases: '-h', required: false
    option :port, aliases: '-P', required: false
    option :endpoint, aliases: '-e', required: false
    option :username, aliases: '-u', required: false
    option :password, aliases: '-p', required: false
    option :environment, aliases: '-E', required: false
    option :id, aliases: '-i', required: true
    option :xml_request, aliases: '-x', required: true
    def create
      host = options[:host]
      port = options[:port]
      endpoint = options[:endpoint]

      environment = options[:environment]

      username = options[:username]
      password = options[:password]

      client = if environment == 'production'
                 Symplectic::Elements::Client.production
               elsif environment == 'development'
                 Symplectic::Elements::Client.development
               else
                 Symplectic::Elements::Client.new(host: host, port: port, endpoint: endpoint, username: username, password: password)
               end

      id = options[:id]
      xml_request = options[:xml_request]

      user_feed = client.find_user_feed(id: id)
      user_feed&.delete

      xml = File.read(xml_request)
      user_feed.create(xml: xml)
    end

    desc 'request', 'Use the Symplectic Elements API to request a new User Feed'
    option :host, aliases: '-h', required: false
    option :port, aliases: '-P', required: false
    option :endpoint, aliases: '-e', required: false
    option :username, aliases: '-u', required: false
    option :password, aliases: '-p', required: false
    option :environment, aliases: '-E', required: false
    option :id, aliases: '-i', required: true
    option :xml_output, aliases: '-o', required: true
    def request
      host = options[:host]
      port = options[:port]
      endpoint = options[:endpoint]

      environment = options[:environment]

      username = options[:username]
      password = options[:password]

      client = if environment == 'production'
                 Symplectic::Elements::Client.production
               elsif environment == 'development'
                 Symplectic::Elements::Client.development
               else
                 Symplectic::Elements::Client.new(host: host, port: port, endpoint: endpoint, username: username, password: password)
               end

      id = options[:id]
      xml_output = options[:xml_output]

      user_feed = client.find_user_feed(id: id)
      user_feed.get

      File.open(xml_output, "w") do |f|
        f.write(user_feed.document.to_xml)
      end
    end

    desc 'delete', 'Delete the Symplectic Elements API to delete a given User Feed'
    option :host, aliases: '-h', required: false
    option :port, aliases: '-P', required: false
    option :endpoint, aliases: '-e', required: false
    option :username, aliases: '-u', required: false
    option :password, aliases: '-p', required: false
    option :environment, aliases: '-E', required: false
    option :id, aliases: '-i', required: true
    option :xml_output, aliases: '-o', required: true
    def delete
      host = options[:host]
      port = options[:port]
      endpoint = options[:endpoint]

      environment = options[:environment]

      username = options[:username]
      password = options[:password]

      client = if environment == 'production'
                 Symplectic::Elements::Client.production
               elsif environment == 'development'
                 Symplectic::Elements::Client.development
               else
                 Symplectic::Elements::Client.new(host: host, port: port, endpoint: endpoint, username: username, password: password)
               end

      id = options[:id]
      xml_output = options[:xml_output]

      user_feed = client.find_user_feed(id: id)
      user_feed&.delete

      File.open(xml_output, "w") do |f|
        f.write(user_feed.document.to_xml)
      end
    end
  end
end
