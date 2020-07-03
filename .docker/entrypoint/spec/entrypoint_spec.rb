# frozen_string_literal: true

load 'includes.rb'

describe Jekyll::PlantUml::Entrypoint do
  subject(:entrypoint) do
    data_dir = File.join(__dir__, 'data')
    Entrypoint.new(
      ExecEnv.new('dev', data_dir, data_dir),
      DockerImage.new('jekyll-plantuml', 'latest', '1.2.3')
    )
  end

  it {
    is_expected.not_to be_nil
  }

  describe '#execute' do
    it { expect { entrypoint.execute }.to_not raise_error }
  end
end
