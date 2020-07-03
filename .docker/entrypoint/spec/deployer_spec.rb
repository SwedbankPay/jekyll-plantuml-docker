# frozen_string_literal: true

load 'includes.rb'

describe Jekyll::PlantUml::Commands::Deployer do
  subject(:deployer) do
    data_dir = File.join(__dir__, 'data')
    Deployer.new({ a:'b' }, data_dir)
  end

  describe '#deploy' do
    subject! { deployer.jekyll_build = SpecJekyllBuild.new }
    it { expect { deployer.deploy(false, false) }.to invoke(:process).on(subject).at_least(1).times }
  end
end
