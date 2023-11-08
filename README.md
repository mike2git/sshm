# sshmp
  
sshmp - mount or umount filesystem over ssh on /home/seror/user@host  
sshmp [command] [user@host[:mount_path]] [options]  
  
arguments:  
command - the command to execute, mount / m or unmount / u  
user@host:mount_path - the user, the host and the path on the remote server to mount  
  
options:  
-h, --help show brief help  
-m, --mountpoint MOUNT_POINT the local mount point  
-p, --password MOUNT_PASSWORD the password for the ssh login  
-o, --options MOUNT_OPTIONS the options string to pass to fusermount  

Examples :  
sshmp m r_pse@cbs_app_dev:/home/r_pse  
sshmp u r_pse@cbs_app_dev  
  
NOTE: 
This command requires the fuse-sshfs package.  
The 'allow_other' option string value will require the /etc/fuse.conf option of 'user_allow_other'.  
