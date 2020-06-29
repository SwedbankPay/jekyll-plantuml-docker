# frozen_string_literal: true

require 'commander'
require 'helpers/spec_logger'
require 'jekyll'
require 'docker_image'
require 'jekyll_environment'

describe Jekyll::PlantUml::Commander do
  let(:version) { '0.0.1-test.0' }
  subject(:commander) do
    data_dir = File.join(__dir__, 'data')
    Jekyll::PlantUml::Commander.new(
      Jekyll::PlantUml::JekyllEnvironment.new('development', data_dir, data_dir),
      Jekyll::PlantUml::DockerImage.new('swedbankpay/jekyll-plantuml', version, version)
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
      let!(:logger) { Jekyll.logger = Jekyll::PlantUml::SpecLogger.new(:info) }

      it {
        commander.execute(['build'])
        expect(logger.message).to match(/Generating...\s+done in/)
      }
    end
  end
end
