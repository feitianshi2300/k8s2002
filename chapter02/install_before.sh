
#!/bin/bash

################# 系统环境配置 #####################

# 关闭 Selinux/firewalld
systemctl stop firewalld && systemctl disable firewalld
setenforce 0
sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config

# 关闭交换分区
swapoff -a
cp /etc/{fstab,fstab.bak}
cat /etc/fstab.bak | grep -v swap > /etc/fstab

# 设置 iptables
echo """
vm.swappiness = 0
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
""" > /etc/sysctl.conf
modprobe br_netfilter
sysctl -p

# 同步时间
yum install -y ntpdate
ntpdate -u ntp.api.bz
