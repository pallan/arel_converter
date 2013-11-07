require 'spec_helper'

describe ArelConverter::ActiveRecordFinder do

  let(:converter) { ArelConverter::ActiveRecordFinder.new('spec/fixtures/grep_matching.rb') }

  let(:valid_lines) { ["    Model.find(:all)", "    Model.find(:all, :conditions => {:active => true})", "    Model.find(:first)", "    Model.find(:all, :conditions => {:active => true})", "    Model.all(:conditions => {:active => false})", "    Model.first(:conditions => {:active => false})"] }

  it 'should find all the valid lines from a file' do
    expect(converter.grep_matches_in_file('spec/fixtures/grep_matching.rb')).to eq(valid_lines)
  end

  describe '#process_lines' do
    it 'should pass of translation to the ActiveRecordFinder translator' do
      expect(ArelConverter::Translator::Finder).to receive(:translate).with('MyModel.find(:all)').and_return('scope(:active)')
      converter.process_line('MyModel.find(:all)')
    end

    it 'should remove surrounding brackets for clarity' do
      allow(ArelConverter::Translator::Finder).to receive(:translate).and_return('translated line')
      expect(converter.process_line('MyModel.find(:all)')).to eq('translated line')
    end
  end

end

