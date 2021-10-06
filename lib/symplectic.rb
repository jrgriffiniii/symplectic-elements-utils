# frozen_string_literal: true

require 'pry-byebug'

module Symplectic
  def self.root_path
    File.dirname(__FILE__)
  end

  autoload(:Elements, File.join(root_path, 'symplectic', 'elements'))
end
