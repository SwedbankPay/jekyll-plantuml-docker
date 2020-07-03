# frozen_string_literal: true

load 'includes.rb'

describe Jekyll::PlantUml::Commander do
  let(:version) { '0.0.1-test.0' }
  subject(:commander) do
    data_dir = File.join(__dir__, 'data')
    Commander.new(
      ExecEnv.new('development', data_dir, data_dir, :level),
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
      let!(:logger) { commander.logger = SpecLogger.new(:info) }

      it {
        commander.execute(['build'])
        expect(logger.message).to match(/Generating...\s+done in/)
      }

      it do
        jekyll_builder_class = SpecJekyllBuilder
        jekyll_builder = jekyll_builder_class.new('xyz', :info)
        allow(jekyll_builder_class).to receive(:new).and_return(jekyll_builder)
        expect(jekyll_builder).to receive(:execute)
        commander.commands.builder = jekyll_builder_class
        commander.execute(['build'])
      end

      context '--verify' do
        it do
          verifier_class = SpecVerifier
          verifier = verifier_class.new('xyz', :info)
          allow(verifier_class).to receive(:new).and_return(verifier)
          expect(verifier).to receive(:verify)
          commander.commands.verifier = verifier_class
          commander.execute(['build', '--verify'])
        end
      end
    end

    context 'deploy' do
      # TODO: This should probably be reset before(:each) somehow.
      let!(:logger) { commander.logger = SpecLogger.new(:info, :debug) }

      it {
        commander.execute(['deploy'])
        expect(logger.message).to match(/Deploying/)
      }

      context '--dry-run' do
        it {
          commander.execute(['deploy', '--dry-run'])
          expect(logger.message).to match(/Deploying, dry-run/)
          expect(logger.message).to match(/deploy.sh --dry-run/)
        }
      end

      context '--verify' do
        it {
          commander.commands.verifier = SpecVerifier
          commander.execute(['deploy', '--verify'])
          expect(logger.message).to match(/Deploying, verified/)
        }
      end

      context '--dry-run --verify' do
        it {
          commander.commands.verifier = SpecVerifier
          commander.execute(['deploy', '--dry-run', '--verify'])
          expect(logger.message).to match(/Deploying, dry-run, verified/)
          expect(logger.message).to match(/deploy.sh --dry-run/)
        }
      end
    end
  end
end
