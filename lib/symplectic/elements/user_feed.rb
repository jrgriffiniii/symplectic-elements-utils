# frozen_string_literal: true

require 'nokogiri'

module Symplectic
  module Elements
    class UserFeed
      def self.per_page_param
        1000
      end

      class Page
        attr_reader :id

        def self.per_page_param
          1000
        end

        def initialize(id:, user_feed:, last_page: nil)
          @id = id
          @user_feed = user_feed
          @last_page = last_page

          request!

          if !last_page?
            next_page_id = @id + 1
            @next_page = self.class.new(id: next_page_id, user_feed: user_feed, last_page: self)
          end
        end

        def last_page?
          id == last_page_id
        end

        def path
          "/user-feeds/#{@user_feed.id}"
        end

        def document
          Nokogiri::XML(@xml)
        end

        def first_page_element
          document.at_xpath('//api:pagination/api:page[@position="first"]', api: 'http://www.symplectic.co.uk/publications/api', atom: "http://www.w3.org/2005/Atom")
        end

        def last_page_element
          document.at_xpath('//api:pagination/api:page[@position="last"]', api: 'http://www.symplectic.co.uk/publications/api', atom: "http://www.w3.org/2005/Atom")
        end

        def last_page_id
          content = last_page_element['number']
          content.to_i
        end

        def page_element
          document.at_xpath('//api:pagination/api:page[@position="this"]', api: 'http://www.symplectic.co.uk/publications/api', atom: "http://www.w3.org/2005/Atom")
        end

        def page_id
          content = page_element['number']
          content.to_i
        end

        def request!
          response = get
          return if response.nil?

          @response = response

          @persisted = true
          @xml = @response.body
          @id = page_id

          @response
        end

        def get
          request_params = if @last_page.nil?
                            {
                              'per-page' => self.class.per_page_param
                            }
                          else
                            {
                              'page' => @last_page.id + 1,
                              'per-page' => self.class.per_page_param
                            }
                          end

          @user_feed.client.get(path, request_params)
        rescue StandardError => error
          nil
        end
      end

      attr_reader :client, :id
      def initialize(client:, id:, last_page: nil)
        @client = client
        @id = id
        # Remove this
        @last_page = last_page
      end

      def persisted?
        @persisted
      end

      def path
        "/user-feeds/#{@id}"
      end

      def get
        @first_page = Page.new(id: 1, user_feed: self)
      end

      def delete
        @client.delete(path)
      end

      def create(xml:)
        @client.post(path, xml, 'Content-Type' => 'text/xml')
        get
      end

      def document

        binding.pry
        #return unless @xml

        #Nokogiri::XML(@xml)
      end

      def entry_elements
        return unless document

        document.xpath('//api:entry', api: 'http://www.symplectic.co.uk/publications/api')
      end

      def entries
        entry_elements.map do |entry_element|
          entry_element
        end
      end
    end
  end
end
