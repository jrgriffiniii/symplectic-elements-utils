# frozen_string_literal: true

module Symplectic
  module Elements
    class UserFeed
      def self.per_page_param
        2000
      end

      def initialize(client:, id:)
        @client = client
        @id = id
        @persisted = false
        @xml = nil

        get_response = get
        return if get_response.nil?

        @persisted = true
        @xml = get_response.body
      end

      def persisted?
        @persisted
      end

      def path
        "/user-feeds/#{@id}"
      end

      def get
        @client.get(path, perPage: self.class.per_page_param)
      rescue StandardError
        nil
      end

      def delete
        @client.delete(path)
      end

      def create(xml:)
        @client.post(path, xml, 'Content-Type' => 'text/xml')
        get
      end
    end
  end
end
