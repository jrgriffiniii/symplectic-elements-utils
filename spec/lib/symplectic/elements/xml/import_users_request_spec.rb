# frozen_string_literal: true
require "spec_helper"

describe Symplectic::Elements::XML::ImportUsersRequest do
  subject(:import_users_request) { described_class.new }

  describe '#document' do
    it 'accesses the XML Document for the REST request' do
      document = import_users_request.document
      expect(document).to be_a(Nokogiri::XML::Document)
      expect(document.to_xml).to include('<api:import-users-request xmlns:api="http://www.symplectic.co.uk/publications/api">')
      expect(document.to_xml).to include('</api:import-users-request>')
    end
  end

  describe '#to_xml' do
    it 'accesses the string-serialized XML Document' do
      expect(import_users_request.to_xml).to include('<api:import-users-request xmlns:api="http://www.symplectic.co.uk/publications/api">')
      expect(import_users_request.to_xml).to include('</api:import-users-request>')
    end
  end
end
