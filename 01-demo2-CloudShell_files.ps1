# How Azure Cloud Shell stores your files

gcm *clouddrive*
clouddrive mount -h
Get-CloudDrive


# There are several mount points
# Your 'cloud drive', which is your Azure File Share mounted as a CIFS filesystem as /usr/csuser/clouddrive. 
df -H

# There’s a symlink set up so that ~/clouddrive goes to the same location.
ls /home/mas/clouddrive -al 
dir /home/mas/cl*
find ~  -type l -ls | grep clouddrive 

# Your home directory /home/<username> is different.
# You can see that is a mount point for /dev/loop0, which is a loopback filesystem.
# A loopback filesystem allows you to create a filesystem inside a file. 
# Where is that file? Inside your cloud drive file share, as a regular file .cloudconsole/acc_<username>.img

ls -l ~/clouddrive/.cloudconsole/acc_mas.img
5368709120/1GB

# Could you mount an Azure Cloud Shell file share as a network share?

Get-PSDrive
cd Z:
code . -n