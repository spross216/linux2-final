#!/bin/bash

function apache(){
  sudo apt install -y apache2
  sudo ufw allow 80
}

function samba(){
  sudo apt install -y samba smbclient cifs-utils
  mv smb.conf /etc/samba/smb.conf 
  sudo mkdir /smb-cookie-jar
  sudo mkdir /smb-cookie-jar/student
  sudo echo "test" >> /smb-cookie-jar/student/test.txt 
  sudo groupadd smbinternal 
  sudo chgroup -R smbinternal /smb-cookie-jar/
  sudo chmod 2770 /smb-cookie-jar/
  sudo usermod -aG smbinternal $USER 
  sudo smbpasswd -e $USER 
  testparm
  sudo systemctl restart smbd 
  sudo ufw allow from 192.168.0.0/24 
}

function postfix(){
  sudo DEBIAN_PRIORITY=low apt install postfix
  sudo postconf -e 'home_mailbox= Maildir/'
  sudo postconf -e 'virtual_alias_maps= hash:/etc/postfix/virtual'
  sudo echo 'student@smbinternal.com student' >> /etc/postfix/virtual 
  sudo postmap /etc/postfix/virtual
  sudo systemctl restart postfix
  echo 'export MAIL=~/Maildir' | sudo tee -a /etc/bash.bashrc | sudo tee -a /etc/profile.d/mail.sh
  source /etc/profile.d/mail.sh
  sudo apt install s-nail
  sudo echo 'set emptystart' >> /etc/s-nail.rc 
  sudo echo 'set folder=Maildir' >> /etc/s-nail.rc 
  sudo echo 'set record=+sent' >> /etc/s-nail.rc 
  echo 'init' | s-nail -s 'init' -Snorecord student
}

apache()
samba()
postfix()
