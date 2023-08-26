#!/bin/bash

# 安装软件可能需要的依赖关系
yum install -y yum-utils device-mapper-persistent-data lvm2

# 配置使用阿里云仓库，安装Kubernetes工具
cat > /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
EOF


# 执行安装kubeadm, kubelet, kubectl工具
yum -y install kubeadm-1.17.0 kubectl-1.17.0 kubelet-1.17.0

# 配置防火墙
sed -i "13i ExecStartPost=/usr/sbin/iptables -P FORWARD ACCEPT" /usr/lib/systemd/system/docker.service

# 创建文件夹
if [ ! -d "/etc/docker" ];then
    mkdir -p /etc/docker
fi

# 配置 docker 启动参数
cat > /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": ["https://av0eyibf.mirror.aliyuncs.com"],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
  "max-size": "100m"
  },
    "storage-driver": "overlay2"
  }
EOF


# 配置开启自启
systemctl enable docker && systemctl enable kubelet
systemctl daemon-reload
systemctl restart docker
