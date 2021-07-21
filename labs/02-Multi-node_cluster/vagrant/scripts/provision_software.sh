apt-get remove -y docker.io kubelet kubeadm kubectl kubernetes-cni
apt-get autoremove -y
systemctl daemon-reload
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

echo "KUBELET_EXTRA_ARGS=--cgroup-driver=systemd" > /etc/default/kubelet

apt-get update
apt-get install -y containerd=1.2.6-0ubuntu1~16.04.4 docker.io=18.09.7-0ubuntu1~16.04.6 kubelet=1.18.0-00 kubeadm=1.18.0-00 kubectl=1.18.0-00 kubernetes-cni
systemctl enable kubelet && systemctl start kubelet

cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "storage-driver": "overlay2"
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

sudo chmod 777 /var/run/docker.sock

# Restart docker.
sudo systemctl restart docker 
sudo systemctl daemon-reload
sudo systemctl enable docker && sudo systemctl start docker

docker info | grep overlay
docker info | grep systemd


exit 0