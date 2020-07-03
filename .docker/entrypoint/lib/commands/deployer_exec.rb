# frozen_string_literal: false

require 'jekyll'

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::Commands module contains the implementations of the
    # various commands that Jekyll PlantUML supports.
    module Commands
      # The Jekyll::PlantUml::DeployerExec executes the `deploy.sh` script with
      # the provided arguments.
      class DeployerExec
        attr_writer :logger

        def initialize(jekyll_var_dir)
          @jekyll_var_dir = jekyll_var_dir
        end

        def execute(dry_run)
          deploy_script_path = File.join(@jekyll_var_dir, 'deploy.sh')

          deploy_cmd = deploy_script_path
          deploy_cmd << ' --dry-run' if dry_run
          deploy_cmd << ' --verbose'

          log(:debug, deploy_cmd)

          system(deploy_cmd)
        end

        private

        def log(severity, message)
          (@logger ||= Jekyll.logger).public_send(
            severity,
            "   jekyll-plantuml: #{message}"
          )
        end
      end
    end
  end
end
