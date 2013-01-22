require "digest/md5"
require "railsless-deploy"
require "multi_json"

UPSTART_TEMPLATE = <<EOD
#!upstart
description "{{application}} node app"
author      "capistrano"

start on (filesystem and net-device-up IFACE=lo)
stop on shutdown

respawn
respawn limit 99 5

script
    cd {{current_path}} NODE_ENV={{node_env}} {{app_environment}} {{node_binary}} {{current_path}}/{{app_command}} 2>> {{shared_path}}/{{node_env}}.err.log 1>> {{shared_path}}/{{node_env}}.out.log
end script
EOD

def remote_file_exists?(full_path)
  'true' ==  capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
end

def remote_file_content_same_as?(full_path, content)
  Digest::MD5.hexdigest(content) == capture("md5sum #{full_path} | awk '{ print $1 }'").strip
end

def remote_file_differs?(full_path, content)
  exists = remote_file_exists?(full_path)
  !exists || exists && !remote_file_content_same_as?(full_path, content)
end

def generate_upstart_config
  UPSTART_TEMPLATE.gsub(/\{\{(.*?)\}\}/) { eval($1) }
end

Capistrano::Configuration.instance(:must_exist).load do |configuration|
  before "deploy", "deploy:create_release_dir"
  before "deploy", "node:check_upstart_config"
  after "deploy:update", "node:install_packages", "node:restart"
  after "deploy:rollback", "node:restart"

  package_json = MultiJson.load(File.open("package.json").read) rescue {}

  set :application, package_json["name"] unless defined? application
  set :app_command, package_json["main"] || "index.js" unless defined? app_command
  set :app_environment, "" unless defined? app_environment

  set :node_binary, "/usr/bin/node" unless defined? node_binary
  set :node_env, "production" unless defined? node_env
  set :node_user, "deploy" unless defined? node_user

  set :upstart_job_name, lambda { "#{application}-#{node_env}" } unless defined? upstart_job_name
  set :upstart_file_path, lambda { "/etc/init/#{upstart_job_name}.conf" } unless defined? upstart_file_path

  namespace :node do
    desc "Check required packages and install if packages are not installed"
    task :install_packages do
      run "mkdir -p #{shared_path}/node_modules"
      run "cp #{release_path}/package.json #{shared_path}"
      run "cd #{shared_path} && npm install #{(node_env == 'production') ? '--production' : ''} --loglevel warn"
      run "ln -s #{shared_path}/node_modules #{release_path}/node_modules"
    end

    task :check_upstart_config do
      create_upstart_config if remote_file_differs?(upstart_file_path, generate_upstart_config)
    end

    desc "Create upstart script for this node app"
    task :create_upstart_config do
      config_file_path = "/etc/init/#{application}.conf"
      temp_config_file_path = "#{shared_path}/#{application}.conf"

      # Generate and upload the upstart script
      put generate_upstart_config, temp_config_file_path

      # Copy the script into place and make executable
      "cp #{temp_config_file_path} #{upstart_file_path}"
    end

    desc "Start the node application"
    task :start do
      "start #{upstart_job_name}"
    end

    desc "Stop the node application"
    task :stop do
      "stop #{upstart_job_name}"
    end

    desc "Restart the node application"
    task :restart do
      "stop #{upstart_job_name}; true"
      "start #{upstart_job_name}"
    end
  end

  namespace :deploy do
    task :create_release_dir, :except => {:no_release => true} do
      mkdir_releases = "mkdir -p #{fetch :releases_path}"
      mkdir_commands = ["log", "pids"].map {|dir| "mkdir -p #{shared_path}/#{dir}"}
      run mkdir_commands.unshift(mkdir_releases).join(" && ")
    end
  end
end
