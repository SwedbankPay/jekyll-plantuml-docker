# frozen_string_literal: true

require 'commands/verifier'
require 'errors/directory_not_found_error'

describe Jekyll::PlantUml::Commands::Verifier do
  describe '#initialize' do
    context 'nil config' do
      it do
        expect do
          Jekyll::PlantUml::Commands::Verifier.new(nil)
        end.to raise_error(ArgumentError, 'Value cannot be nil')
      end
    end

    context 'empty config' do
      it do
        expect do
          Jekyll::PlantUml::Commands::Verifier.new({})
        end.to raise_error(ArgumentError, 'Hash cannot be empty')
      end
    end

    context 'non-hash config' do
      it do
        expect do
          Jekyll::PlantUml::Commands::Verifier.new([])
        end.to raise_error(ArgumentError, 'Array is not a Hash')
      end
    end

    context 'missing :destination' do
      it do
        expect do
          Jekyll::PlantUml::Commands::Verifier.new({ a: 'b' })
        end.to raise_error(ArgumentError, "No 'destination' key found in the hash")
      end
    end

    context 'non-existing :destination' do
      it do
        expect do
          Jekyll::PlantUml::Commands::Verifier.new({ 'destination' => 'abc' })
        end.to raise_error(Jekyll::PlantUml::DirectoryNotFoundError, 'abc does not exist')
      end
    end
  end

  describe '#verify' do
    data_dir = File.join(__dir__, '..', '..', '..', 'tests', 'minimal')
    site_dir = File.join(data_dir, '_site')

    before(:all) do
      jekyll_config_provider = Jekyll::PlantUml::JekyllConfigProvider.new(data_dir)
      jekyll_config = jekyll_config_provider.provide('build')
      jekyll_commander = Jekyll::PlantUml::Commands::JekyllCommander.new(jekyll_config)
      jekyll_commander.execute('build')
    end

    subject { Jekyll::PlantUml::Commands::Verifier.new({ level: :warn, 'destination' => site_dir }) }

    it 'ignores urls' do
      ignore_urls = [ 'http://www.wikipedia.org', %r{[/.]?page1} ]
      subject.verify(ignore_urls)
    end
  end
end
