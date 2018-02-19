capistrano-node-deploy
======================

Capistrano recipe for deploying node.js apps.

Features
--------
- Provides `cap deploy` functionality for your node app
- Installs node packages (`yarn`) during deploys, using a shared folder for speed
- Automatically creates upstart scripts for your node apps
- Provides tasks for starting (`cap node:start`) and stopping (`cap node:stop`) your node app
- Forever functionality and remote monitor (`cap node:status`)

Usage
-----

First install the gem:

    sudo gem install capistrano-node-deploy

or add it to your `Gemfile` if you have one:

    gem "capistrano-node-deploy"

Now add the following to your `Capfile`

    require "capistrano/node-deploy"


Full Capfile Example
--------------------

```ruby
require "capistrano/node-deploy"

set :application, "my-node-app-name"
set :repository,  "git@github.com:/loopj/my-node-app-name"
set :user, "deploy"
set :scm, :git
set :deploy_to, "/var/apps/my-app-folder"

role :app, "myserver.com"
```


Overriding Default Settings
---------------------------

```ruby
# Set app command to run (defaults to index.js, or your `main` file from `package.json`)
set :app_command, "my_server.coffee"

# Set additional environment variables for the app
set :app_environment, "PORT=8080"

# Set node binary to run (defaults to /usr/bin/node)
set :node_binary, "/usr/bin/coffee"
    
# Set node environment (defaults to production)
set :node_env, "staging"
    
# Set the user to run node as (defaults to deploy)
set :node_user, "james"

# Set the name of the upstart command (defaults to #{application}-#{node_env})
set :upstart_job_name, "myserver"

#Forever related settings

# set to forever to use forever, defaults to upstart
set :run_method, "forever"

#Time to wait (millis) between launches of a spinning script.
set :spin_sleep_time, "1000"

#Minimum uptime (millis) for a script to not be considered "spinning"
set :min_up_time, "1000"

#Only run the specified script MAX times
set :max_run, "5"

```


Contributing to capistrano-node-deploy
--------------------------------------
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.


Copyright
---------

Copyright (c) 2012 James Smith. See LICENSE.txt for
further details.

