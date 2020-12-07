# frozen_string_literal: true

require 'includes'

describe GemfileGeneratorExec do
  generated_gemfile_path = File.join(__dir__, 'data', 'Gemfile.generated')
  gemfiles = {
    default: File.join(__dir__, 'data', 'Gemfile.default'),
    user: File.join(__dir__, 'data', 'Gemfile.user'),
    generated: generated_gemfile_path
  }

  describe '#generate' do
    after(:all) do
      File.delete generated_gemfile_path if File.exist? generated_gemfile_path
    end

    context 'existing gemfiles' do
      before(:all) do
        generator = GemfileGeneratorExec.new(gemfiles)
        generator.generate
      end

      subject { File.read(generated_gemfile_path) }

      it {
        expect(File).to exist(generated_gemfile_path)
      }

      it {
        is_expected.not_to be_empty
      }

      it {
        is_expected.to include("gem 'open3'")
      }

      it {
        is_expected.to include("gem 'rouge'")
      }

      it {
        expect(generated_gemfile_path).to be_valid_gemfile
      }
    end

    context 'log level' do
      subject { GemfileGeneratorExec.new(gemfiles, ['build' , "--log-level=#{log_level}"]) }

      [:trace, :debug].each do |severity|
        context severity do
          let(:log_level) { severity }
          specify { expect { subject.generate }.to output(/path: #{generated_gemfile_path}/).to_stdout }
        end
      end

      [:info, :warn, :error, :fatal].each do |severity|
        context severity do
          let(:log_level) { severity }
          specify { expect { subject.generate }.to_not output.to_stdout }
        end
      end
    end
  end
end
