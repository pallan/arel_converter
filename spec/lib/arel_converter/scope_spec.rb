require 'spec_helper'

describe ArelConverter::Scope do
  
  let(:converter) { ArelConverter::Scope.new('spec/fixtures/grep_matching.rb') }

  let(:valid_lines) { ["  scope :active"] }
  let(:invalid_lines) { ["    scope = 'Test cases'"] }

  it 'should find all the valid lines from a file' do
    expect(converter.grep_matches_in_file('spec/fixtures/grep_matching.rb')).to eq(valid_lines)
  end

  describe 'verify lines' do
    it 'should know of valid lines' do
      valid_lines.each do |l|
        expect(converter.verify_line(l)).to be_true
      end
    end

    it 'should know of invalid lines' do
      invalid_lines.each do |l|
        expect(converter.verify_line(l)).to be_false
      end
    end
  end

  describe '#process_lines' do
    it 'should pass of translation to the Association translator' do
      expect(ArelConverter::Translator::Scope).to receive(:translate).with('scope :active').and_return('scope(:active)')
      converter.process_line('scope :active')
    end

    it 'should remove surrounding brackets for clarity' do
      allow(ArelConverter::Translator::Scope).to receive(:translate).and_return('scope(:active)')
      expect(converter.process_line('scope :active')).to eq('scope :active')
    end
  end

end
