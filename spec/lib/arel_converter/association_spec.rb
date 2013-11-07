require 'spec_helper'

describe ArelConverter::Association do

  let(:converter) { ArelConverter::Association.new('spec/fixtures/grep_matching.rb') }

  let(:valid_lines) { ["  has_many :posts", "  has_and_belongs_to_many :articles", "  has_one :author", "  belongs_to :blog"] }
  let(:invalid_lines) { ["    has_many = 'Test cases'"] }
  let(:all_lines) { valid_lines + invalid_lines }

  it 'should find all the valid lines from a file' do
    expect(converter.grep_matches_in_file('spec/fixtures/grep_matching.rb')).to eq(all_lines)
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
      expect(ArelConverter::Translator::Association).to receive(:translate).with('my line')
      converter.process_line('my line')
    end
  end

end
