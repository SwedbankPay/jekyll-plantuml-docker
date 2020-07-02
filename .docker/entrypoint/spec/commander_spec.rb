# frozen_string_literal: true

require 'commander'
require 'jekyll'
require 'docker_image'
require 'jekyll_environment'
require 'helpers/spec_jekyll_commander'
require 'helpers/spec_logger'

Commander = Jekyll::PlantUml::Commander
DockerImage = Jekyll::PlantUml::DockerImage
JekyllEnvironment = Jekyll::PlantUml::JekyllEnvironment
SpecLogger = Jekyll::PlantUml::Specs::Helpers::SpecLogger
SpecJekyllCommander = Jekyll::PlantUml::Specs::Helpers::SpecJekyllCommander

describe Commander do
  let(:version) { '0.0.1-test.0' }
  subject(:commander) do
    data_dir = File.join(__dir__, 'data')
    Commander.new(
      JekyllEnvironment.new('development', data_dir, data_dir, :level),
      DockerImage.new('swedbankpay/jekyll-plantuml', version, version)
    )
  end

  describe '#execute' do
    context 'when no args' do
      specify { expect { commander.execute }.to output(/Usage:/).to_stdout }
    end

    ['--help', '-h'].each do |arg|
      context arg do
        specify { expect { commander.execute([arg]) }.to output(/Usage:/).to_stdout }
      end
    end

    context '--version' do
      specify { expect { commander.execute('--version') }.to output(/#{version}/).to_stdout }
    end

    context 'build' do
      # TODO: This should probably be reset before(:each) somehow.
      let!(:logger) { Jekyll.logger = SpecLogger.new(:info) }

      it {
        commander.execute(['build'])
        expect(logger.message).to match(/Generating...\s+done in/)
      }

      it do
        jekyll_commander_class = SpecJekyllCommander
        jekyll_commander = jekyll_commander_class.new('xyz', :info)
        allow(jekyll_commander_class).to receive(:new).and_return(jekyll_commander)
        expect(jekyll_commander).to receive(:execute).with('build')
        commander.commands[:build] = jekyll_commander_class
        commander.execute(['build'])
      end
    end
  end
end
