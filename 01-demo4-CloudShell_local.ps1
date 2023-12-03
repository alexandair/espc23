<#
A goal is to mount Azure Cloud Shell Cloud Drive to locally running Cloud Shell container
Start an Ubuntu WSL

# https://docs.microsoft.com/en-us/azure/storage/files/storage-how-to-use-files-linux?tabs=smb311
To mount a Cloud Shell file share you first need to install cifs-utils

sudo apt update
sudo apt install cifs-utils

# Following commands are coming from the Connect tab for the Cloud Shell file share in the Azure portal

if [ ! -d "/mnt/demoshell2023share" ]; then
sudo mkdir /mnt/demoshell2023share
fi
if [ ! -d "/etc/smbcredentials" ]; then
sudo mkdir /etc/smbcredentials
fi
if [ ! -f "/etc/smbcredentials/demoshell2023sa.cred" ]; then
    sudo bash -c 'echo "username=demoshell2023sa" >> /etc/smbcredentials/demoshell2023sa.cred'
    sudo bash -c 'echo "password=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" >> /etc/smbcredentials/demoshell2023sa.cred'
fi
sudo chmod 600 /etc/smbcredentials/demoshell2023sa.cred

sudo bash -c 'echo "//demoshell2023sa.file.core.windows.net/demoshell2023share /mnt/demoshell2023share cifs nofail,credentials=/etc/smbcredentials/demoshell2023sa.cred,dir_mode=0777,file_mode=0777,serverino,nosharesock,actimeo=30" >> /etc/fstab'
sudo mount -t cifs //demoshell2023sa.file.core.windows.net/demoshell2023share /mnt/demoshell2023share -o credentials=/etc/smbcredentials/demoshell2023sa.cred,dir_mode=0777,file_mode=0777,serverino,nosharesock,actimeo=30

# Mount it as a clouddrive in your Cloud Shell container
docker run -v /mnt/demoshell2023share:/root/clouddrive -it --rm mcr.microsoft.com/azure-cloudshell bash
docker run -v /mnt/demoshell2023share:/root/clouddrive -it --rm mcr.microsoft.com/azure-cloudshell pwsh
#>

curl 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fmanagement.azure.com%2F' -H Metadata:true