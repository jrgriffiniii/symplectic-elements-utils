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
