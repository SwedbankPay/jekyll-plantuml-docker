require "jekyll"

JEKYLL_VAR_DIR = ENV.fetch("JEKYLL_VAR_DIR")
JEKYLL_ENV = ENV.fetch("JEKYLL_ENV", "production")

unless File.file?(File.join(Dir.pwd, "Gemfile"))
  default_gemfile_path = File.join(JEKYLL_VAR_DIR, "Gemfile")
  puts "No Gemfile found. Using default: #{default_gemfile_path}"
  ENV["BUNDLE_GEMFILE"] = default_gemfile_path
end

config_file_path = File.join(Dir.pwd, "_config.yml")

jekyll_config = {
  "host" => "0.0.0.0",
  "port" => "4000",
  "livereload" => true,
  "incremental" => true,
  "force_polling" => true,
  "watch" => true,
  "config" => config_file_path,
}

unless File.file?(File.join(Dir.pwd, "_config.yml"))
  default_config_file_path = File.join(JEKYLL_VAR_DIR, "_config.default.yml")
  puts "No _config.yml found. Using default: #{default_config_file_path}"
  jekyll_config["config"] = default_config_file_path
end

if ARGV.length == 0
  puts "Running default command 'jekyll serve' (JEKYLL_ENV: #{JEKYLL_ENV})..."
  Jekyll::Commands::Serve.process(jekyll_config)
elsif ARGV[0] == "deploy"
  puts "Deploying..."
  Jekyll::Commands::Build.process(jekyll_config)
  exec("/usr/jekyll/bin/deploy.sh --verbose")
elsif ARGV[0] == "jekyll"
  requested_jekyll_command = ARGV[1]
  all_jekyll_commands = Jekyll::Commands.constants.select { |c| Jekyll::Commands.const_get(c).is_a? Class }
  matching_jekyll_command = all_jekyll_commands.find { |c| c.to_s.casecmp(requested_jekyll_command) == 0 }

  unless matching_jekyll_command
    raise "Jekyll command '#{requested_jekyll_command}' not understood."
  end

  puts "Running Jekyll command '#{requested_jekyll_command}' (JEKYLL_ENV: #{JEKYLL_ENV})..."

  Jekyll::Commands.const_get(matching_jekyll_command).process(jekyll_config)

  # If the default_config_file is assigned and the jekyll command supports '--config',
  # apply the default config by performing some positional argument magic.
  # if default_config_file_path #" ] && bundle exec jekyll "$2" --help | grep '\-\-config' > /dev/null; then
  #   exec("bundle exec jekyll $2 --config $default_config_file ${@:3}")
  # else
  #   exec("bundle exec jekyll ${@:2}")
  # end
else
  puts "Running '$*' (JEKYLL_ENV: ${JEKYLL_ENV})..."
  exec "$@"
end
