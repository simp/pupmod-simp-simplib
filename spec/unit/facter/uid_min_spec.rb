require 'spec_helper'

describe 'uid_min', type: :fact do
  subject(:fact) { Facter.fact(:uid_min) }

  before(:each) do
    Facter.clear

    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:read).and_call_original
  end

  context 'when /etc/login.defs does not exist' do
    before(:each) do
      allow(File).to receive(:exist?).with('/etc/login.defs').and_return(false)
    end

    it 'returns nil' do
      expect(fact.value).to be_nil
    end
  end

  context 'when /etc/login.defs exists' do
    before(:each) do
      allow(File).to receive(:exist?).with('/etc/login.defs').and_return(true)
    end

    context 'when /etc/login.defs is empty' do
      before(:each) do
        allow(File).to receive(:read).with('/etc/login.defs').and_return('')
      end

      it 'returns default value' do
        expect(fact.value).to eq('1000')
      end
    end

    context 'when /etc/login.defs has matching lines' do
      let(:login_defs_content) do
        <<~EOM
          #UID_MIN ???
          # UID_MIN 500
           UID_MIN         10000
        EOM
      end

      before(:each) do
        allow(File).to receive(:read).with('/etc/login.defs').and_return(login_defs_content)
      end

      it 'returns expected value' do
        expect(fact.value).to eq('10000')
      end
    end
  end
end
