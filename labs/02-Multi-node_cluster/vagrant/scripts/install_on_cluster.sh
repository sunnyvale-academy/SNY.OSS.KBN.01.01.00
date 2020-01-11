export KUBECONFIG=/vagrant/kubeconfig.yaml 

# Metrics server
kubectl delete -f /vagrant/metrics-server/deploy/1.8+/ 2> /dev/null
kubectl apply -f /vagrant/metrics-server/deploy/1.8+/

cp /etc/kubernetes/pki/ca.* /usr/src/git_repo/labs/20-RBAC