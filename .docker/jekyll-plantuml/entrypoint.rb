require "jekyll"

JEKYLL_VAR_DIR = ENV.fetch("JEKYLL_VAR_DIR")
JEKYLL_ENV = ENV.fetch("JEKYLL_ENV", "production")

def get_config(command)
  config_file_path = File.join(Dir.pwd, "_config.yml")

  jekyll_config = {
    "config" => config_file_path,
    "incremental" => true,
  }

  unless File.file?(config_file_path)
    default_config_file_path = File.join(JEKYLL_VAR_DIR, "_config.default.yml")
    puts "No _config.yml found. Using default: #{default_config_file_path}"
    jekyll_config["config"] = default_config_file_path
  end

  if command == "serve"
    jekyll_config.merge({
      "host" => "0.0.0.0",
      "port" => "4000",
      "livereload" => true,
      "force_polling" => true,
      "watch" => true,
    })
  end

  jekyll_config
end

if ARGV.length == 0
  puts "Running default command 'jekyll serve' (JEKYLL_ENV: #{JEKYLL_ENV})..."
  jekyll_config = get_config("serve")
  Jekyll::Commands::Serve.process(jekyll_config)
elsif ARGV[0] == "deploy"
  puts "Deploying..."
  jekyll_config = get_config("deploy")
  Jekyll::Commands::Build.process(jekyll_config)
  exec("/usr/jekyll/bin/deploy.sh --verbose")
elsif ARGV[0] == "jekyll"
  requested_jekyll_command = ARGV[1]

  if requested_jekyll_command.empty?
    raise "No jekyll command provided."
  end

  requested_jekyll_command = requested_jekyll_command.downcase
  jekyll_config = get_config(requested_jekyll_command)

  case requested_jekyll_command.downcase
  when "build"
    Jekyll::Commands::Build.process(jekyll_config)
  when "serve"
    Jekyll::Commands::Serve.process(jekyll_config)
  end

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
