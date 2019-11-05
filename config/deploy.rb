require 'dotenv'
Dotenv.load

# config valid for current version and patch releases of Capistrano
lock '~> 3.11.2'

set :application, 'time_clock'
set :repo_url, 'git@github.com:snada/time_clock.git'

# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, ENV['SERVER_DEPLOY_FOLDER']

# Default value for :format is :airbrussh.
# set :format, :airbrussh

set :rvm_ruby_version, proc { `cat .ruby-version`.chomp }

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, 'config/database.yml', 'config/master.key'

# Default value for linked_dirs is []
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system'

set :nvm_type, :user
set :nvm_node, proc { 'v' + `cat .nvmrc`.chomp }
set :nvm_map_bins, %w{node yarn}

# Default value for default_env is {}
# set :default_env, { path: '/opt/ruby/bin:$PATH' }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
set :keep_releases, 3

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

namespace :yarn do
  task :install do
    execute :yarn, 'install'
  end
end

namespace :deploy do
  before :compile_assets, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      within release_path do
        execute :yarn, "install"
      end
    end
  end
end
