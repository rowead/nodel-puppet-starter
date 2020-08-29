## A quick start project for nodel and puppet

## Quick setup/install guide
- install virtualbox (https://www.virtualbox.org/wiki/Downloads)
- install vagrant (https://www.vagrantup.com/)
- clone repo and run "vagrant up"
- run "vagrant reload" so the kiosk user gets logged in.

### What does this project set up?
After "vagrant up" is run, you should have a basic Ubuntu machine with nodel installed ready to play with.

Features include:
- Vagrant is set up to run a VM with the hostname wam-dev-foyer-wm06. That means it will get its config from code/environments/production/data/wam/dev/foyer/wm06.yaml
but it will also inherit config from the common.yaml files in the parent directories. Have a look at the notes below for an example.
- puppet and a small number of packages needed are installed using the shell/initial-setup.sh, this is run as part of "vagrant up".
- It sets up the "kiosk" user that automatically logs in after 20s.
- nodel is available at http://localhost:8085/nodes/wamdevfoyerwm06local/ on the host computer but you can open chromium in the VM.
    - At the moment nodel links will break, you need to rewrite them to http://localhost... rather than the IP address nodel generates (for opening nodel on the host only)
- many default packages are installed or removed based on experience.
  
## Passwords
- admin user: "vagrant" pass: "vagrant"
- kiosk user: "kiosk" pass: "kiosk"

### Notes:
If you make changes to the puppet config you can "re-run" or "do a puppet run" by using the "vagrant provision" command.

It is highly recommended to use "vagrant reload" after using nodel to power off/restart the machine (vagrant reload does a bunch of other work to make sure
vagrant provision will work again after a restart).
 
The nodel .jar that is installed can be changed and puppet will pick that up and restart the service when you do a "puppet run".

Have a look at code/environments/production/data/wam/dev/foyer/wm06.yaml, change the nodel_jar entry to point to the release download you want and then do a puppet run to activate that change.

There is an older .jar specified in code/environments/production/common.yaml, deleting the entry from wm06.yaml will mean that the value in the
common.yaml file will get used. This is a good example of the inheritance feature of puppet, so you could change the version of nodel
at the Branch, Gallery, or PC level just by editing or creating a common.yaml file in that directory structure.