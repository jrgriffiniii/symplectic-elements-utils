# frozen_string_literal: true
require "spec_helper"

describe Symplectic::Elements::XML::User do
  subject(:user) { described_class.new(parent: parent) }

  let(:xml_fixture_path) { 'spec/fixtures/test.xml' }
  let(:xml_fixture_file) { File.read(xml_fixture_path) }
  let(:document) { Nokogiri::XML(xml_fixture_file) }
  let(:parent) { instance_double(Symplectic::Elements::XML::Users) }
  let(:namespaces) do
    {
      api: "http://www.symplectic.co.uk/publications/api"
    }
  end
  let(:parent_element) { document.at_xpath('./api:import-users-request/api:users', **namespaces) }

  before do
    allow(parent).to receive(:document).and_return(document)
    allow(parent).to receive(:namespaces).and_return(namespaces)
    allow(parent).to receive(:element).and_return(parent_element)
  end

  describe '#element' do
    it 'accesses the XML Element node in the request XML Document' do
      expect(user.element).to be_a(Nokogiri::XML::Element)
      expect(user.element.name).to include('user')
      expect(user.element.namespaces).to include(
        "xmlns:api" => "http://www.symplectic.co.uk/publications/api"
      )
    end
  end
end
