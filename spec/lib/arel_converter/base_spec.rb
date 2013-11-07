require 'spec_helper'

describe ArelConverter::Base do


  let(:converter) { ArelConverter::Base.new('.') }
  let(:file_converter) { ArelConverter::Base.new('spec/fixtures/my/files/source.rb') }
  let(:dir_converter)  { ArelConverter::Base.new('spec/fixtures/my') }

  let(:replacement_good) { ArelConverter::Replacement.new('Good Line', 'PROCESSED') }
  let(:replacemetn_bad) { ArelConverter::Replacement.new('Pretty Line', 'PROCESSED') }
  let(:replacement_error) { 
    r = ArelConverter::Replacement.new('Invalid Line')
    r.error = "This is no good!"
    r
  }
  let(:replacements) { [replacement_good, replacemetn_bad] }
  let(:replacements_with_errors) { [replacement_good, replacement_error, replacemetn_bad] }

  describe 'executes against the proper type' do
    it 'should execute against a single file' do
      expect(file_converter).to receive(:parse_file).with('spec/fixtures/my/files/source.rb')
      expect(file_converter).not_to receive(:parse_directory)
      file_converter.run!
    end

    it 'should execute against a directory' do
      expect(dir_converter).to receive(:parse_directory).with('spec/fixtures/my')
      dir_converter.run!
    end
  end

  describe 'executing against a directory' do
    let(:files) { Dir['spec/fixtures/my/**/*.rb'].map {|file| file } }

    it 'should execute against all ruby files in the supplied directory' do
      files.each do |f|
        expect(dir_converter).to receive(:parse_file).with(f)
      end
      dir_converter.run!
    end
  end

  describe 'parsing a file' do

    let(:matched_lines) { ['a','b'] }
    let(:results) { ['result 1', 'result 2'] }

    before do
      file_converter.stub(:update_file)
      allow(file_converter).to receive(:grep_matches_in_file).and_return(matched_lines)
      allow(file_converter).to receive(:process_lines).with(matched_lines).and_return(results)
      allow(ArelConverter::Formatter).to receive(:alert)
    end

    it "should grep the file for matches and do nothing if there are none" do
      expect(file_converter).to receive(:grep_matches_in_file).and_return([])
      expect(file_converter).to_not receive(:process_lines)
      file_converter.run!
    end

    it 'should process any lines that are found' do
      expect(file_converter).to receive(:grep_matches_in_file).and_return(matched_lines)
      expect(file_converter).to receive(:process_lines).with(matched_lines).and_return([])
      file_converter.run!
    end

    it 'should pass to the formatter any results' do
      expect(ArelConverter::Formatter).to receive(:alert).with('spec/fixtures/my/files/source.rb',results)
      file_converter.run!
    end

    it 'should update the file' do
      allow(file_converter).to receive(:process_lines).with(matched_lines).and_return(results)
      expect(file_converter).to receive(:update_file).with('spec/fixtures/my/files/source.rb',results)
      file_converter.run!
    end

    it 'should not update the files if configured not to' do
      allow(file_converter).to receive(:process_lines).with(matched_lines).and_return(results)
      expect(ArelConverter::Formatter).to receive(:alert)
      expect(file_converter).to_not receive(:update_file)
      file_converter.options[:dry_run] = true
      file_converter.run!
    end

    it 'should not output or update if there are no results' do
      allow(file_converter).to receive(:process_lines).and_return([])
      expect(ArelConverter::Formatter).to_not receive(:alert)
      expect(file_converter).to_not receive(:update_file)
      file_converter.run!
    end

  end

  describe 'processing lines' do
    let(:lines) { ['Good Line', 'Invalid Line', 'Pretty Line'] }

    before do
      allow(converter).to receive(:process_line).and_return('PROCESSED')
    end

    it 'should return only lines that are valid ' do
      allow(converter).to receive(:verify_line).and_return(true, false, true)
      expect(converter.process_lines(lines)).to eq(replacements)
    end

    it 'should return only lines that do not raise a SyntaxError' do
      allow(converter).to receive(:process_line).with('Invalid Line').and_raise(SyntaxError)
      expect(converter.process_lines(lines)).to eq(replacements_with_errors)
    end

    it 'should only return lines that do not raise other exceptions' do
      allow(converter).to receive(:process_line).with('Invalid Line').and_raise(RuntimeError)
      expect(converter.process_lines(lines)).to eq(replacements_with_errors)
    end
  end

  describe 'updating files' do

    it 'should do replacement on the proper lines' do
      file_handle = double
      allow(File).to receive(:read).and_return("Good Line\n\nNext Line\n\nThird Line\n\nPretty Line")
      expect(File).to receive(:open).and_yield(file_handle)
      expect(file_handle).to receive(:puts).with("PROCESSED\n\nNext Line\n\nThird Line\n\nPROCESSED")
      converter.update_file('my/file.rb', replacements_with_errors)
    end

  end
end
