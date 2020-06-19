require "commander"

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

    ["--version", "-v"].each do |arg|
      context arg do
        # TODO: Figure out why --version doesn't work.
        # specify { expect { commander.execute([arg]) }.to output(version).to_stdout }
      end
    end

    context "build" do
      specify { expect { commander.execute(["build"]) }.to output(/Generating...\s+done in/).to_stdout }
    end
  end
end
