# frozen_string_literal: true

require 'jekyll'
require 'commands/deployer'
require 'helpers/spec_jekyll_build'
require 'matchers/invoke_matcher'

describe Jekyll::PlantUml::Commands::Deployer do
  Deployer = Jekyll::PlantUml::Commands::Deployer
  SpecJekyllBuild = Jekyll::PlantUml::Specs::Helpers::SpecJekyllBuild

  subject(:deployer) do
    data_dir = File.join(__dir__, 'data')
    Deployer.new(data_dir, data_dir)
  end

  describe '#deploy' do
    subject! { deployer.jekyll_build = SpecJekyllBuild.new }
    it { expect { deployer.deploy(false, false) }.to invoke(:process).on(subject).at_least(1).times }
  end
end
