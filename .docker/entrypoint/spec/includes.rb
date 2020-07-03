# frozen_string_literal: true

require 'argument_parser'
require 'bundler'
require 'commander'
require 'commands/deployer'
require 'commands/jekyll_commander'
require 'commands/verifier'
require 'diffy'
require 'docker_image'
require 'entrypoint'
require 'errors/directory_not_found_error'
require 'errors/file_not_found_error'
require 'exec_env'
require 'fileutils'
require 'gemfile_differ'
require 'gemfile_generator_exec'
require 'gemfile_generator'
require 'helpers/spec_jekyll_build'
require 'helpers/spec_jekyll_commander'
require 'helpers/spec_logger'
require 'jekyll_config_provider'
require 'jekyll'
require 'matchers/be_valid_gemfile_matcher'
require 'matchers/invoke_matcher'
require 'securerandom'

ArgumentParser ||= Jekyll::PlantUml::ArgumentParser
Commander ||= Jekyll::PlantUml::Commander
Deployer ||= Jekyll::PlantUml::Commands::Deployer
Diff ||= Diffy::Diff
DirectoryNotFoundError ||= Jekyll::PlantUml::DirectoryNotFoundError
DockerImage ||= Jekyll::PlantUml::DockerImage
Entrypoint ||= Jekyll::PlantUml::Entrypoint
ExecEnv ||= Jekyll::PlantUml::ExecEnv
FileNotFoundError ||= Jekyll::PlantUml::FileNotFoundError
GemfileDiffer ||= Jekyll::PlantUml::GemfileDiffer
GemfileGenerator ||= Jekyll::PlantUml::GemfileGenerator
GemfileGeneratorExec ||= Jekyll::PlantUml::GemfileGeneratorExec
JekyllCommander ||= Jekyll::PlantUml::Commands::JekyllCommander
JekyllConfigProvider ||= Jekyll::PlantUml::JekyllConfigProvider
SpecJekyllBuild ||= Jekyll::PlantUml::Specs::Helpers::SpecJekyllBuild
SpecJekyllCommander ||= Jekyll::PlantUml::Specs::Helpers::SpecJekyllCommander
SpecLogger ||= Jekyll::PlantUml::Specs::Helpers::SpecLogger
Verifier ||= Jekyll::PlantUml::Commands::Verifier
