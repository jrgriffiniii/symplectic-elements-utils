# frozen_string_literal: true
require "spec_helper"

describe Symplectic::Elements::XML::Users do
  subject(:users) { described_class.new(parent: parent) }

  let(:xml_fixture_path) { 'spec/fixtures/test.xml' }
  let(:xml_fixture_file) { File.read(xml_fixture_path) }
  let(:document) { Nokogiri::XML(xml_fixture_file) }
  let(:parent_class) do
    class_double(Symplectic::Elements::XML::ImportUsersRequest).as_stubbed_const(transfer_nested_constants: true)
  end
  let(:parent) { instance_double(Symplectic::Elements::XML::ImportUsersRequest) }
  let(:namespaces) do
    {
      api: "http://www.symplectic.co.uk/publications/api"
    }
  end
  let(:parent_element) { document.at_xpath('./api:import-users-request', **namespaces) }

  before do
    allow(parent).to receive(:document).and_return(document)
    allow(parent_class).to receive(:namespaces).and_return(namespaces)

    allow(parent).to receive(:class).and_return(parent_class)
  end

  describe '#element' do
    it 'accesses the XML Element node in the request XML Document' do
      expect(users.element).to be_a(Nokogiri::XML::Element)
      expect(users.element.to_xml).to include('<api:users>')
      expect(users.element.to_xml).to include('</api:users>')
    end
  end
end
