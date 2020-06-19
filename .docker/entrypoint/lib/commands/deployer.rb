require "jekyll"

module Jekyll::PlantUml
  class Deployer
    def initialize(jekyll_config, jekyll_var_dir)
      @jekyll_config = jekyll_config
      @jekyll_var_dir = jekyll_var_dir
    end

    def deploy(dry_run, verify)
      message = "Deploying"
      deploy_script_path = File.join(@jekyll_var_dir, "deploy.sh")
      deploy_cmd = "#{deploy_script_path} --verbose"

      if dry_run
        message << ", dry-run"
        deploy_cmd << " --dry-run"
      end

      if verify
        message << ", verified"
        deploy_cmd << " --verify"
      end

      message << "…"

      puts message

      Jekyll::Commands::Build.process(@jekyll_config)
      exec(deploy_cmd)
    end
  end
end
