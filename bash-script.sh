#!/bin/bash
echo Looking for /root/.bash_profile
GIT_USER=rvanorman
VAULT_SERVER="vault-server.hashicorp.com"

git_func () {
if [[ -e '/root/.bash_profile' ]]; then
	if grep -Fxq "GITUSER=${GIT_USER}" /root/.bash_profile; then
		echo Git User Variable Exists
	else
		echo Appending GITUSER Environment Variable to Existing .bash_profile
    	echo GITUSER=${GIT_USER} >> /root/.bash_profile
	fi
	if grep -Fq "git config --global user.name" /root/.bash_profile; then
		echo Forcing Overwrite
		sed -i "s|git config --global user.name.*|git config --global user.name \$GITUSER|g" /root/.bash_profile
	else
		echo Appending to Git User Config to Existing .bash_profile
    	echo 'git config --global user.name $GITUSER' >> /root/.bash_profile
	fi
else
	echo Creating .bash_profile with Desired Startup
	touch /root/.bash_profile
	echo GITUSER=${GIT_USER} > /root/.bash_profile
	echo 'git config --global user.name $GITUSER' >> /root/.bash_profile
fi
echo Setting the Environment Variables And Git User to $GIT_USER
source /root/.bash_profile
}

config_func () {
echo Checking for Vault Config File config.hcl
if [[ -d '/etc/vault/' ]]; then
	if [[ -e '/etc/vault/config.hcl' ]]; then
		echo Vault Config File Exists, Exiting
	else
		echo Creating Vault Config File
		touch /etc/vault/config.hcl
		echo -e 'cluster_addr  = "https://<HOSTNAME>:8201"\napi_addr      = "https://<HOSTNAME>:8200"\ndisable_mlock = true' > /etc/vault/config.hcl
		echo Updating Hostname Variable with Actual Hostname
		sed -i "s|<HOSTNAME>|${VAULT_SERVER}|" /etc/vault/config.hcl
	fi
else
	echo Creating Vault Directory and Config File
	mkdir /etc/vault
	touch /etc/vault/config.hcl
	echo -e 'cluster_addr  = "https://<HOSTNAME>:8201"\napi_addr      = "https://<HOSTNAME>:8200"\ndisable_mlock = true' > /etc/vault/config.hcl
	echo Updating Hostname Variable with Actual Hostname
	sed -i "s|<HOSTNAME>|${VAULT_SERVER}|" /etc/vault/config.hcl
fi
}

git_func
config_func
