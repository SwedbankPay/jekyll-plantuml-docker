require "commander"
require "spec_logger"
require "jekyll"

describe Jekyll::PlantUml::Commander do
  let(:version) { "0.0.1-test.0" }
  subject(:commander) { Jekyll::PlantUml::Commander.new("development", __dir__, __dir__, "swedbankpay/jekyll-plantuml", version, version) }

  describe "#execute" do
    context "when no args" do
      specify { expect { commander.execute }.to output(/Usage:/).to_stdout }
    end

    ["--help", "-h"].each do |arg|
      context arg do
        specify { expect { commander.execute([arg]) }.to output(/Usage:/).to_stdout }
      end
    end

    context "--version" do
      # TODO: Figure out why --version doesn't work.
      specify { expect { commander.execute("--version") }.to output(/#{version}/).to_stdout }
    end

    context "build" do
      # TODO: This should probably be reset before(:each) somehow.
      let! (:logger) { Jekyll.logger = Jekyll::PlantUml::SpecLogger.new(:info) }

      it {
        commander.execute(["build"])
        expect(logger.message).to match(/Generating...\s+done in/)
      }
    end
  end
end
