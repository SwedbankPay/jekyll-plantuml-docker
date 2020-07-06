# frozen_string_literal: true

require 'argument_parser'
require 'bundler'
require 'commander'
require 'commands/deployer'
require 'commands/jekyll_builder'
require 'commands/jekyll_server'
require 'commands/verifier'
require 'diffy'
require 'docker_image'
require 'entrypoint'
require 'errors/directory_not_found_error'
require 'errors/file_not_found_error'
require 'errors/command_line_argument_error'
require 'context'
require 'fileutils'
require 'gemfile_differ'
require 'gemfile_generator_exec'
require 'gemfile_generator'
require 'helpers/spec_jekyll_build'
require 'helpers/spec_jekyll_builder'
require 'helpers/spec_logger'
require 'helpers/spec_verifier'
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
Context ||= Jekyll::PlantUml::Context
FileNotFoundError ||= Jekyll::PlantUml::FileNotFoundError
GemfileDiffer ||= Jekyll::PlantUml::GemfileDiffer
GemfileGenerator ||= Jekyll::PlantUml::GemfileGenerator
GemfileGeneratorExec ||= Jekyll::PlantUml::GemfileGeneratorExec
JekyllBuilder ||= Jekyll::PlantUml::Commands::JekyllBuilder
JekyllConfigProvider ||= Jekyll::PlantUml::JekyllConfigProvider
JekyllServe ||= Jekyll::Commands::Serve
JekyllServer ||= Jekyll::PlantUml::Commands::JekyllServer
SpecJekyllBuild ||= Jekyll::PlantUml::Specs::Helpers::SpecJekyllBuild
SpecJekyllBuilder ||= Jekyll::PlantUml::Specs::Helpers::SpecJekyllBuilder
SpecLogger ||= Jekyll::PlantUml::Specs::Helpers::SpecLogger
SpecVerifier ||= Jekyll::PlantUml::Specs::Helpers::SpecVerifier
Verifier ||= Jekyll::PlantUml::Commands::Verifier
