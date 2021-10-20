# frozen_string_literal: true

module Symplectic
  module Elements
    module XML
      class Users
        attr_reader :document

        def initialize(parent:)
          @parent = parent
          @document = @parent.document

          built = User.new(parent: self)
          @users = [built]
        end

        def namespaces
          @parent.class.namespaces
        end

        def element
          # <api:user-feed-entry>
          @element ||= @document.root.at_xpath('//api:users', **namespaces) || @document.root.at_xpath('//api:user-feed-entry', **namespaces)
        end

        def children_elements
          element.children.select { |c| c.is_a?(Nokogiri::XML::Element) }
        end

        def last
          @users.last
        end

        def append_user
          new_user_element = children_elements.last.clone
          element.add_child(new_user_element)

          built = User.new(parent: self)
          @users << built
          built
        end
      end
    end
  end
end
