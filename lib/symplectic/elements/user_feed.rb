# frozen_string_literal: true

require 'nokogiri'

module Symplectic
  module Elements
    class UserFeed
      def self.per_page_param
        1000
      end

      class Page
        attr_reader :response

        def self.per_page_param
          1000
        end

        #def initialize(id:, user_feed:, client:, last_page: nil)
        def initialize(id:, user_feed:, last_page: nil)
          @id = id
          #@client = client
          @last_page = last_page
          @after_id = nil

          @user_feed = user_feed

          request!

          binding.pry
          @after_id = @id.to_i + 1
          @next_page = self.class.new(id: @after_id, user_feed: user_feed, last_page: self)
        end

        def path
          "/user-feeds/#{@user_feed.id}"
        end

        def document
          Nokogiri::XML(@xml)
        end

        def entry_elements
          document.at_xpath('//', api: 'http://www.symplectic.co.uk/publications/api', atom: "http://www.w3.org/2005/Atom")
        end

        def pagination_elements
          document.xpath('//api:pagination/api:page', api: 'http://www.symplectic.co.uk/publications/api', atom: "http://www.w3.org/2005/Atom")
        end

        def page_element
          document.at_xpath('//api:pagination/api:page', api: 'http://www.symplectic.co.uk/publications/api', atom: "http://www.w3.org/2005/Atom")
        end

        def request!
          response = get
          return if response.nil?

          @response = response

          @persisted = true
          @xml = @response.body
          #@document = Nokogiri::XML(@xml)
          @id = page_element['number']

          @response
        end

        def get
          #@client.get(path, perPage: self.class.per_page_param)
          #@client.get(path, 'per-page': self.class.per_page_param)

          request_params = if @last_page.nil?
                            {
                              'per-page' => self.class.per_page_param
                            }
                          else
                            {
                              'per-page' => self.class.per_page_param,
                              'after-id' => @last_page.id
                            }
                          end

          #@after_id = nil

          @user_feed.client.get(path, **request_params)
        rescue StandardError => error
          binding.pry
          nil
        end
      end

      attr_reader :client, :id
      def initialize(client:, id:, last_page: nil)
        @client = client
        @id = id
        # Remove this
        @last_page = last_page

        #@pages = if last_page.nil?
        #           []
        #         else
        #           last_pages.pages + last_page
        #         end

        #@persisted = false
        #@xml = nil

        #get_response = get
        #return if get_response.nil?

        #@persisted = true
        @first_page = Page.new(id: 0, user_feed: self)

        #@xml = @first_page.response.body
      end

      def persisted?
        @persisted
      end

      def path
        "/user-feeds/#{@id}"
      end

      def get
        #@client.get(path, perPage: self.class.per_page_param)
        #@client.get(path, 'per-page': self.class.per_page_param)

        request_params = if @last_page.nil?
                           {
                             'per-page' => self.class.per_page_param
                           }
                         else
                           {
                             'per-page' => self.class.per_page_param,
                             'after-id' => @last_page.id
                           }
                         end

        @client.get(path, **request_params)
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

      def document
        return unless @xml

        Nokogiri::XML(@xml)
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
