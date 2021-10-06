# frozen_string_literal: true

module Symplectic
  module Elements
    module XML
      def self.root_path
        File.dirname(__FILE__)
      end

      autoload(:User, File.join(root_path, 'xml', 'user'))
      autoload(:Users, File.join(root_path, 'xml', 'users'))
      autoload(:ImportUsersRequest, File.join(root_path, 'xml', 'import_users_request'))
    end
  end
end
