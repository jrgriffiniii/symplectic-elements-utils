# frozen_string_literal: true

module Symplectic
  module Elements
    module CSV
      def self.root_path
        File.dirname(__FILE__)
      end

      autoload(:TransformJob, File.join(root_path, 'csv', 'transform_job'))
    end
  end
end
