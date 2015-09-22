# Puppet Control Repo

## Overview

This is an all-in-one repo that is a skeleton to use in a production environment, but also can be used to share and test Puppet infrastructure.

The idea is that this environment controls all of your environments (dev, qa, production) but also holds the ability to spin up Vagrant VMs to test your code before committing.

## Files/Directories

### Vagrantfile

Dictates basics of how Vagrant will spin up VM. Please do not edit this file unless you *really* know what you're doing.

### Puppetfile
r10k needs this file to figure out what component modules you want from the Forge. The result is a modules directory containing all the modules specified in this file, for each environment/branch. The modules directory is listed in environment.conf's modulepath.

### environment.conf
Controls puppet's directory environment settings.

[Config Files: environment.conf](https://docs.puppetlabs.com/puppet/latest/reference/config_file_environment.html)

### hieradata
Contains your hiera data files.

### manifests
Contains site.pp

### site
Contains your organization-specific roles and profiles (wrapper modules for Forge component modules)

This directory is specified as a modulepath in environment.conf

[The origins of roles and profiles](http://www.craigdunn.org/2012/05/239/)

### hooks/
Git hooks for checking your Puppet code. There is a pre-commit you can copy to your .git/hooks repo directory. There is also a pre-receive for your git server (you also need to copy the commit_hooks subdirectory to your git server). You must install puppet and puppet-lint (locally for pre-commit, on the git server for pre-receive) to use these hooks.

To use the pre-receive hook on your Git server, copy the hook and the commit_hooks directory to the puppet-control.git directory in your repositories directory.

### provision/

Contains the scripts and files that are used to spin up the Vagrant VM. This is different from the Vagrantfile in that these are more specific to what you want to happen with the specific instance. The pe/ directory contains answer files, and, after you spin up PE for the first time, will contain PE installation media, which are in .gitignore.

If you want to avoid having to wait for PE to download during the provisioning process and you have the Puppet Enterprise tarball lying around, just copy it over to provision/pe and that step will be skipped.

The provision/provision.sh script contains the PE version that will be installed. You'll need to change it to downgrade/upgrade as needed.

### reference/
Reference materials for Puppet workflow.

### vagrant.yml

Gives instructions to Vagrantfile regarding what Vagrant box you want to use, and what virtual machines are available for provisioning, and what their options should be. By default I'm using centos 6.6, but if you want to use another box, you'd change that here.

## How to use it

There's two systems in this environment:

| Name    | Description                  | Address        | PE Console URL                                                  |
| ------- | ---------------------------- | -------------- | -------------------------------------------------------- |
| xmaster | The PE Master                | 192.168.137.10 | [https://192.168.137.10](https://192.168.137.10)         |
| xagent  | Example agent (unclassified) | 192.168.137.14 |                                                          |

The default credentials for the PE Master Console are:

Username: `admin`

Password: `password`

### Summary of procedure

1. Bring up instances
2. Push local control repository to Git server
3. Experiment

**Bring up all the nodes in the Vagrant environment:**

```
vagrant up
```

This will take some time to provision.

Ensure that the PE master is up and provisioned before attempting to start
another system.

Stuff included:

* Puppet Environments (control repository)
* Roles and Profiles
* Hiera
* Git workflow
* Optionally, [hiera-eyaml](https://github.com/TomPoulton/hiera-eyaml)
* [r10k](https://github.com/adrienthebo/r10k)

Once everything is provisioned as you need it, you can ssh into the instance:

```
vagrant ssh xmaster
```

You will be logged in as user vagrant. Please sudo to root if you need to run puppet.


### 1. Install Virtualbox

This vagrant setup requires one of the following versions: 4.0, 4.1, 4.2. The latest Virtualbox version is 4.3

### 2. Install Vagrant

Latest version, 1.5.6 when this repo was created, will work fine.


### Provisioning Summary

The Vagrant provisioning will install Puppet Enterprise with the appropriate
configuration for each system.  The Puppet Master will be configured and manged
using Puppet - you can look at the `role::puppet::master` to see what's going
on.  Basically, Puppet is configured for environments, r10k is installed and
configured, and Hiera is installed and configured.  During provisioning, the
provided control repository is cloned to the PE master and a local `puppet apply`
is done for the role.


Classification for vagrant nodes are done via the
environment-specific `site.pp`

#### Vagrant usage

r10k on the vagrant xmaster uses the /vagrant mount as the remote. During the course of your testing, if you need to edit your files, you'll need to add and commit your changes (but don't push!) then use r10k to sync your code on your vagrant xmaster:

r10k deploy environmnet -p <environment> --verbose

## Bootstrapping your Puppet Master

Now that you have your basic puppet code all ready to go and you want to launch this on your live master...

### 1. rm -rf .git

This removes the reference to this repository. But now you'll need to get this into *your* repo.

### 2. Create your puppet-control git repo

Best practice is to create a "puppet" group where all of your puppet-related code will reside. Then create a puppet-control repo in that group. If you're using gitlab/stash/github, it'll give you instructions on how to complete getting the code to your new repo.

### 3. Make production your default branch

We're using r10k here to convert branches to environments on your Puppet master. So instead of master, it's production. There are many methods to make production your default branch, so I leave that up to the user and their proficiency with google.

### 4. Replace the repo URL for r10k remote

You'll have an URL like "git@github.com:terrimonster/puppet-control.git". Paste that in two places:

provision/bootstrap_r10k.sh
site/profile/manifests/puppet/params.pp

For both, you'll be replacing the git URL for this repo, in the default case statement. The first script bootstraps r10k for vagrant and your live Puppet master. The second is to correct configuration drift for the long-term.

### 5. Deploy keys or ssh keys

You'll need to give your puppet master permission to access your repository. Use either deploy keys or ssh keys, whatever is easiest for you.

### 6. Copy the bootstrap_r10k.sh script to your Master

After you've installed puppet on your puppet master, scp the script, copy and paste, however you want to do it. I recommend putting it in the /tmp directory. Then just run the script to bootstrap r10k and sync production.

That's it! Now you have a full vagrant test environment that mirrors what you have in your live infrastructure!

## Other

This makes use of Greg Sarjeant's [data-driven-vagrantfile](https://github.com/gsarjeant/data-driven-vagrantfile)

No Vagrant plugins are required.
