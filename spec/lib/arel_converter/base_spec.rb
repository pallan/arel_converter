require 'spec_helper'

describe ArelConverter::Base do

  describe 'executes against the proper type' do
    it 'should execute against a single file' do
      base = ArelConverter::Base.new('spec/fixtures/my/files/source.rb')
      expect(base).to receive(:parse_file).with('spec/fixtures/my/files/source.rb')
      expect(base).not_to receive(:parse_directory)
      base.run!
    end

    it 'should execute against a directory' do
      base = ArelConverter::Base.new('spec/fixtures/my/files')
      expect(base).to receive(:parse_directory).with('spec/fixtures/my/files')
      base.run!
    end
  end



end
