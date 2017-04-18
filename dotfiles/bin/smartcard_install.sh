#!/bin/bash

preinstall() {
    sudo rm /etc/ssh/*key* moduli 
    sudo dpkg-reconfigure openssh-client 
    sudo dpkg-reconfigure openssh-server 
}
troubleshoot() {
    #systemctl status pcscd # Must be turned on
    killall ssh-agent gpg-agent
    unset GPG_AGENT_INFO SSH_AGENT_PID SSH_AUTH_SOCK
    eval $(gpg-agent --daemon --enable-ssh-support)
    ssh-add -l
}
install_smartcard() {
    sudo apt update
    preinstall
    echo "Installing Smartcard"
    sudo apt install -y libccid pcscd pcsc-tools gnupg-agent scdaemon
    sudo systemctl enable pcscd
    gpg --list-keys
    echo "use-agent" >> ~/.gnupg/gpg.conf
    echo "enable-ssh-support" >> ~/.gnupg/gpg-agent.conf
    mkdir -p ~/.config/autostart
    #Fix gnome-keyring hijacking pinentry
    echo 'X-GNOME-Autostart-enabled=false' | cat /etc/xdg/autostart/gnome-keyring-gpg.desktop - > ~/.config/autostart/gnome-keyring-gpg.desktop
    cp /etc/xdg/autostart/gnome-keyring-ssh.desktop ~/.config/autostart/
    echo 'Hidden=true' >> ~/.config/autostart/gnome-keyring-ssh.desktop 
    touch ~/.bashrc ~/.zshrc
    echo "eval \$(gpg-agent --daemon --enable-ssh-support)" | tee -a ~/.bashrc ~/.zshrc # Important to run at login
    troubleshoot
    # $ ssh-add -l # to test
}

install_smartcard
#troubleshoot
