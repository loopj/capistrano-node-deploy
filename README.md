capistrano-node-deploy
======================

Capistrano recipe for deploying node.js apps.

Features
--------
- Provides `cap deploy` functionality for your node app
- Installs node packages (`npm install`) during deploys, using a shared folder for speed
- Automatically creates upstart scripts for your node apps
- Provides tasks for starting (`cap node:start`) and stopping (`cap node:stop`) your node app


Usage
-----

First install the gem:

    sudo gem install capistrano-node-deploy

or add it to your `Gemfile` if you have one:

    gem "capistrano-rails-deploy", "~> 1.0.0"

Now add the following to your `Capfile`

    require "capistrano/node-deploy"


Full Capfile Example
--------------------

    require "capistrano/node-deploy"

    set :application, "my-node-app-name"
    set :repository,  "git@github.com:/loopj/my-node-app-name"
    set :user, "deploy"
    set :scm, :git
    set :deploy_to, "/var/apps/my-app-folder"

    role :app, "myserver.com"


Overriding Default Settings
---------------------------

    # Override your node binary path
    set :node_binary, "/usr/bin/coffee"

    # Override your app command
    set :app_command, "index.coffee --environment production"


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

