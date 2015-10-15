##### proxy.sh begin
cat << '_EOF_' > /root/proxy.sh
# # # # # proxy.sh # # # # #
_EOF_
##### proxy.sh end
chmod 777 /root/proxy.sh

##### setup_network.sh begin
cat << '_EOF_' > /root/setup_network.sh
# # # # # setup_network.sh # # # # #
_EOF_
##### setup_network.sh end
chmod 777 /root/setup_network.sh

echo "##### SOURCE PROXY.SH #####"
source /root/proxy.sh
# add proxy setting from profile
echo "source /root/proxy.sh" >> /etc/profile

echo "##### PATH SETUP #####"
sed -i -e '/secure_path/c\Defaults env_keep += "PATH"' /etc/sudoers
sed -i -e '/HTTP_PROXY/c\' /etc/sudoers
echo 'Defaults env_keep+="HTTP_PROXY  HTTPS_PROXY http_proxy  https_proxy"' >> /etc/sudoers

echo "##### UPDATE YUM #####"
yum -y update

echo "##### INSTALL NETWORKING TOOLS #####"
yum -y groupinstall "Networking Tools"
yum -y install net-tools bridge-utils
yum -y install tcpdump traceroute
yum -y install wget

echo "##### INSTALL DEVELOPMENT TOOLS #####"
yum -y groupinstall "Development Tools"
yum -y install gcc gcc-c++ make automake autoconf
yum -y install vim
yum -y install git

echo "##### INSTALL X10 #####"
yum -y groupinstall "X Window System"
yum -y groups install fonts
yum -y install libcanberra libcanberra-devel

# erase proxy setting from profile
sed -i '/proxy.sh/c\' /etc/profile
