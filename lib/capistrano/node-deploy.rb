require "railsless-deploy"
require "multi_json"

UPSTART_TEMPLATE = <<EOD
#!upstart
description "{{application}} node app"
author      "capistrano"

start on startup
stop on shutdown

respawn
respawn limit 99 5

script
    exec sudo -u {{user}} {{node_binary}} {{current_path}}/{{app_command}} 2>&1 >> {{shared_path}}/{{application}}.log
end script
EOD

def remote_file_exists?(full_path)
  'true' ==  capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
end

Capistrano::Configuration.instance(:must_exist).load do |configuration|
  before "deploy", "node:create_upstart_config"
  after "deploy:symlink", "node:install_packages"
  after "deploy:symlink", "node:restart"

  package_json = MultiJson.load(File.open("package.json").read) rescue {}

  set :application, package_json["name"] unless defined? application
  set :app_command, package_json["main"] || "index.js" unless defined? app_command
  set :node_binary, "/usr/bin/node" unless defined? node_binary

  namespace :node do
    desc "Check required packages and install if packages are not installed"
    task :install_packages do
      run "mkdir -p #{shared_path}/node_modules"
      run "cp #{current_path}/package.json #{shared_path}"
      run "cd #{shared_path}/node_modules && npm install"
      run "ln -s #{shared_path}/node_modules #{current_path}/node_modules"
    end

    desc "Create upstart script for this node app"
    task :create_upstart_config do
      config_file_path = "/etc/init/#{application}.conf"
      unless remote_file_exists?(config_file_path)
        temp_config_file_path = "#{shared_path}/#{application}.conf"

        # Generate and upload the upstart script
        put UPSTART_TEMPLATE.gsub(/\{\{(.*?)\}\}/) { eval($1) }, temp_config_file_path

        # Copy the script into place and make executable
        sudo "cp #{temp_config_file_path} #{config_file_path}"
        sudo "chmod +x #{config_file_path}"
      end
    end

    desc "Start the node application"
    task :start do
      sudo "start #{application}"
    end

    desc "Stop the node application"
    task :stop do
      sudo "stop #{application}"
    end

    desc "Restart the node application"
    task :restart do
      sudo "restart #{application} || sudo start #{application}"
    end
  end
end