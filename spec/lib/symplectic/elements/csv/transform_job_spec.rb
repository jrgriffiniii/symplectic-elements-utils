# frozen_string_literal: true
require "spec_helper"

describe Symplectic::Elements::CSV::TransformJob do
  describe '.build_csv_file' do
    let(:path) { File.join('spec', 'fixtures', 'test.csv') }
    let(:csv_file) do
      described_class.build_csv_file(path: path)
    end

    it 'parses the CSV file' do
      expect(csv_file).to be_a(CSV::Table)

      rows = csv_file.to_a
      expect(rows.length).to eq(4)
      expect(rows[1]).to eq(["", "AS", "Alice", "Smith", "", "", "user1@Princeton.EDU", "CAS", "user1", "000000001", "English", "TRUE", "TRUE", "FALSE", "", "", "Faculty", "English"])
    end
  end
end
