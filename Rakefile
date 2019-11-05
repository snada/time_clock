# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

Rake::Task["yarn:install"].clear
namespace :yarn do
  task :install do
    # Someone decided to install yarn every time asset:precompile is called for some strange reason.
    # It's less then optimal - as it prevents us from doing it in a separate step during deploy with specific options.
    # So we clear the old task and override it with an empty one.
  end
end
