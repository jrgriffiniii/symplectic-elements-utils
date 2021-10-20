# frozen_string_literal: true

require 'faraday'

module Symplectic
  module Elements
    class Client
      # rubocop:disable Metrics/ParameterLists
      def initialize(host:, port:, username:, password:, endpoint:, protocol: 'https')
        @protocol = protocol
        @host = host
        @port = port
        @endpoint = endpoint
        @username = username
        @password = password
      end
      # rubocop:enable Metrics/ParameterLists

      def self.development_config_path
        File.join('config', 'development.yml')
      end

      def self.development_config_file
        File.read(development_config_path)
      end

      def self.development_config_yaml
        YAML.safe_load(development_config_file)
      end

      def self.development_config
        OpenStruct.new(development_config_yaml)
      end

      def self.development
        new(
          host: development_config.host,
          port: development_config.port,
          username: development_config.username,
          password: development_config.password,
          endpoint: development_config.endpoint,
          protocol: development_config.protocol
        )
      end

      def self.production_config
        OpenStruct.new(development_config_yaml)
      end

      def self.production
        new(
          host: production_config.host,
          port: production_config.port,
          username: production_config.username,
          password: production_config.password,
          endpoint: production_config.endpoint,
          protocol: production_config.protocol
        )
      end

      def find_user_feed(id:)
        UserFeed.new(client: self, id: id)
      end

      def create_user_feed(id:, xml:)
        user_feed = UserFeed.new(client: self, id: id)
        user_feed.post(xml: xml)
        user_feed
      end

      def url
        "#{@protocol}://#{@host}:#{@port}/#{@endpoint}"
      end

      def connection
        Faraday.new(url) do |conn|
          conn.request(:basic_auth, @username, @password)
        end
      end

      def build_url(path)
        File.join(url, path)
      end

      # @return [Faraday::Response]
      def get(path, params = nil, headers = nil)
        get_url = build_url(path)
        response = connection.get(get_url, params, headers)

        raise(StandardError, "Request for #{get_url}: #{response.status}") unless response.success?
        response
      end

      # @return [Faraday::Response]
      def delete(path, params = nil, headers = nil)
        delete_url = build_url(path)
        response = connection.delete(delete_url, params, headers)

        raise(StandardError, "Request for #{delete_url}: #{response.status}") unless response.success?
        response
      end

      # @return [Faraday::Response]
      def post(path, body = nil, headers = nil)
        post_url = build_url(path)
        response = connection.post(post_url, body, headers)

        raise(StandardError, "Request for #{post_url}: #{response.status}") unless response.success?
        response
      end
    end
  end
end
