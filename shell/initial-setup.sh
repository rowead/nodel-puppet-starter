#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

if [[ ! -d /usr/local/wam-puppet/locks ]]; then
  mkdir -p /usr/local/wam-puppet/locks
fi

if [[ ! -f /usr/local/wam-puppet/locks/proxy-settings-update ]]; then
  if [[ -f /etc/puppet/shell/proxy-conf ]]; then
    if [[ ! -n "${http_proxy}" ]]; then
      # @TODO: Change into setting these temporarily and get puppet to set permanently
      echo 'Updating Proxy settings for WAM networks'
      cat /etc/puppet/shell/proxy-conf >> /etc/environment
      for line in $( cat /etc/puppet/shell/proxy-conf ) ; do export $line ; done

      #change following to /etc/apt/apt.conf.d/
      cat /etc/puppet/shell/apt-proxy-conf >> /etc/apt/apt.conf
      echo 'Finished Updating Proxy settings for WAM networks'
    fi

    touch /usr/local/wam-puppet/locks/proxy-settings-update
  fi
fi

i=0
tput sc
while sudo fuser /var/{lib/{dpkg,apt/lists},cache/apt/archives}/lock >/dev/null 2>&1; do
  case $(($i % 4)) in
      0 ) j="-" ;;
      1 ) j="\\" ;;
      2 ) j="|" ;;
      3 ) j="/" ;;
  esac
  tput rc
  echo -en "\r[$j] Waiting for other software managers to finish CTRL-C to abort..."
  sleep 0.5
  ((i=i+1))
done

if [[ ! -f /usr/local/wam-puppet/locks/ubuntu-required-packages ]]; then
  echo 'Installing basic packages'
  apt update && apt install -y openssh-server curl git
  echo 'Finished installing basic packages'

  touch /usr/local/wam-puppet/locks/ubuntu-required-packages
fi

if [[ ! -f /usr/local/wam-puppet/locks/update-puppet ]]; then
  echo "Downloading https://apt.puppetlabs.com/puppetlabs-release-pc1-$(lsb_release -cs).deb"
  mkdir -p /usr/local/wam-puppet/deb
  if [ $(lsb_release -cs) == 'xenial' ]; then
    wget --quiet --tries=5 --timeout=10 https://apt.puppetlabs.com/puppetlabs-release-pc1-$(lsb_release -cs).deb \
      -O /usr/local/wam-puppet/deb/puppet.deb
    echo "Finished downloading https://apt.puppetlabs.com/puppetlabs-release-pc1-$(lsb_release -cs).deb"
  else # bionic
    wget --quiet --tries=5 --timeout=10 https://apt.puppetlabs.com/puppet5-release-$(lsb_release -cs).deb \
      -O /usr/local/wam-puppet/deb/puppet.deb
    echo "Finished downloading https://apt.puppetlabs.com/puppetlabs5-release-$(lsb_release -cs).deb"
  fi

  dpkg -i /usr/local/wam-puppet/deb/puppet.deb >/dev/null

  echo "Running update-puppet apt update"
  apt update #&& apt upgrade -yq >/dev/null
  echo "Finished running update-puppet apt update"

  echo "Updating Puppet to latest version"
  apt  -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install puppet-agent
  echo "Sym-linking puppet executables into /usr/local/bin"
  ln -s /opt/puppetlabs/bin/puppet /usr/local/bin/puppet
  ln -s /opt/puppetlabs/bin/hiera /usr/local/bin/hiera
  ln -s /opt/puppetlabs/bin/facter /usr/local/bin/facter
  ln -s /opt/puppetlabs/bin/mco /usr/local/bin/mco
  PUPPET_VERSION=$(puppet help | grep 'Puppet v')
  echo "Finished updating puppet to latest version: $PUPPET_VERSION"

  /opt/puppetlabs/puppet/bin/gem install hiera-eyaml
  /opt/puppetlabs/puppet/bin/gem install lookup_http

  if [[ ! -f /etc/puppetlabs/pdk-$(lsb_release -cs).deb ]]; then
    echo "downloading Puppet Development Kit for module development"
    wget --quiet "https://pm.puppet.com/cgi-bin/pdk_download.cgi?dist=ubuntu&rel=$(lsb_release -rs)&arch=amd64&ver=latest" \
      -O /etc/puppetlabs/pdk-$(lsb_release -cs).deb
  fi
  dpkg -i /etc/puppetlabs/pdk-$(lsb_release -cs).deb

  touch /usr/local/wam-puppet/locks/update-puppet
  echo "Created empty file /usr/local/wam_puppet/update-puppet"
fi

echo "Changing permissions on vagrant sudo file to allow puppet sudo to work"
chmod 0440 /etc/sudoers.d/vagrant

#echo "Running puppet apply"
puppet apply /etc/puppetlabs/code/environments/production/manifests/sites.pp
echo "Install complete, please got to http://localhost:8085/nodes/wamdevfoyerwm06local/ for nodel"
echo "Please note that you'll need to rewrite urls from nodel to use localhost as the IP address will result in incorrect links"