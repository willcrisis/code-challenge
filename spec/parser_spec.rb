require 'rspec'
require 'json'
require_relative '../lib/parsers/parser'

RSpec.describe Parsers::Parser do
  subject { described_class.new(content).results }

  RSpec.shared_examples 'parse HTML content' do
    it 'has the expected structure' do
      first_element = subject['artworks'].first
      expect(first_element.keys).to eq(%w[name link image extensions])
    end

    it 'allows non-existing images' do
      expect(subject['artworks'][9]['image']).to be_nil
    end

    it 'contains the expected elements' do
      expect(subject['artworks']).to eq(expected_result['artworks'])
    end

    context 'when the provider is not implemented' do
      it 'raises an error' do
        expect { described_class.new(content, 'bing') }.to raise_error('Provider not implemented')
      end
    end
  end

  describe 'Van Gogh paintings' do
    context 'when it is an old Google Search page' do
      let(:expected_result) { JSON.parse(File.read('./files/expected-array.json')) }  
      let(:content) { File.read('./files/van-gogh-paintings.html') }
      
      it 'contains all elements from the HTML page' do
        expect(subject['artworks'].size).to eq(51)
      end

      it 'allows non-existing extensions' do
        expect(subject['artworks'][2]['extensions']).to be_nil
      end
      
      it_behaves_like 'parse HTML content'
    end

    context 'when it is a new Google Search page' do
      let(:expected_result) { JSON.parse(File.read('./files/new-expected-array.json')) }  
      let(:content) { File.read('./files/van-gogh-paintings-new.html') }
      
      it 'contains all elements from the HTML page' do
        expect(subject['artworks'].size).to eq(47)
      end

      it 'allows non-existing extensions' do
        expect(subject['artworks'][10]['extensions']).to be_nil
      end
      
      it_behaves_like 'parse HTML content'
    end
  end

  describe 'Da Vinci paintings' do
    let(:expected_result) { JSON.parse(File.read('./files/leonardo-expected-array.json')) }  
    let(:content) { File.read('./files/leonardo-da-vinci-paintings.html') }

    it 'contains all elements from the HTML page' do
      expect(subject['artworks'].size).to eq(47)
    end

    it 'allows non-existing extensions' do
      expect(subject['artworks'][2]['extensions']).to be_nil
    end
    
    it_behaves_like 'parse HTML content'
  end
end