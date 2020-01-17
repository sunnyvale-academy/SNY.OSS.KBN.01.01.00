export KUBECONFIG=/vagrant/kubeconfig.yaml 

# Metrics server
kubectl delete -f /vagrant/metrics-server/deploy/1.8+/ 2> /dev/null
kubectl apply -f /vagrant/metrics-server/deploy/1.8+/

cp /etc/kubernetes/pki/ca.* /usr/src/git_repo/labs/21-RBAC

# Operator Lifecycle Manager (OLM)
curl -sL https://github.com/operator-framework/operator-lifecycle-manager/releases/download/0.13.0/install.sh | bash -s 0.13.0