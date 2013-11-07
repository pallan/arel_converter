require 'spec_helper'

describe ArelConverter::Replacement do
  let(:r) { ArelConverter::Replacement.new('old', 'new') }

  it 'should initialize correctly' do
    expect(r.old_content).to eq('old')
    expect(r.new_content).to eq('new')
  end

  it 'should be valid if error is nil' do
    r.error = nil
    expect(r).to be_valid
  end

  it 'should be invalid if error is set' do
    r.error = 'Some Random Error'
    expect(r).not_to be_valid
  end
end


