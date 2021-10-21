# frozen_string_literal: true

require 'nokogiri'

module Symplectic
  module Elements
    class UserFeed
      class Page
        attr_reader :id, :previous
        attr_accessor :tail

        def self.per_page_param
          1000
        end

        def initialize(id:, user_feed:, previous: nil)
          @id = id
          @user_feed = user_feed
          @previous = previous

          request!

          if !tail?
            next_page_id = @id + 1
            @next_page = self.class.new(id: next_page_id, user_feed: user_feed, previous: self)
            @tail = @next_page
            @previous.tail = @tail unless @previous.nil?
          else
            @tail = self
          end
        end

        def head?
          id == first_page_id
        end

        def tail?
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

        def first_page_id
          content = first_page_element['number']
          content.to_i
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

        def self.namespaces
          {
            api: 'http://www.symplectic.co.uk/publications/api',
            atom: "http://www.w3.org/2005/Atom"
          }
        end

        def entry_elements
          document.xpath('//atom:entry', **self.class.namespaces)
        end

        def user_elements
          entry_elements.map do |entry_element|
            entry_element.xpath('./api:user-feed-entry', **self.class.namespaces)
          end
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
          request_params = if @previous.nil?
                             {
                               'per-page' => self.class.per_page_param
                             }
                           else
                             {
                               'page' => @previous.id + 1,
                               'per-page' => self.class.per_page_param
                             }
                           end

          @user_feed.client.get(path, request_params)
        rescue StandardError
          nil
        end
      end

      attr_reader :client, :id, :first_page
      def initialize(client:, id:)
        @client = client
        @id = id
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

      def last_page
        @first_page.tail
      end

      def delete
        @client.delete(path)
      end

      def create(xml:)
        @client.post(path, xml, 'Content-Type' => 'text/xml')
        get
      end

      def pages
        values = [last_page]
        return values if last_page.head?

        # previous_page = @last_page.previous
        values << last_page.previous
        return values.reverse if values.last.head?

        until values.last.head?
          # previous_page = values.last.previous
          values << values.last.previous
        end
        values << values.last.previous

        values.reverse
      end

      def build_document
        built = Nokogiri::XML('<api:import-users-request xmlns:api="http://www.symplectic.co.uk/publications/api"></api:import-users-request>')

        users_element = Nokogiri::XML::Node.new("api:users", built)
        built.root.add_child(users_element)

        pages.each do |page|
          page.user_elements.each do |user_element|
            new_user_element = Nokogiri::XML::Node.new("api:user", built)
            user_element.children.each do |child|
              new_child = Nokogiri::XML::Node.new("api:#{child.name}", built)
              new_child.content = child.content
              new_user_element.add_child(new_child)
            end

            users_element.add_child(new_user_element)
          end
        end

        built
      end

      def document
        @document ||= build_document
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
