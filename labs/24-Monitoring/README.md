# Monitoring

## Prerequisites

Before using **kubectl**, please set the **KUBECONFIG** environment variable to point to the right kubeconfig file.

```console
$ export KUBECONFIG=../02-Multi-node_cluster/vagrant/kubeconfig.yaml
```

Other than `kubectl`, you need `helm` installed on your computer in order to deploy the Prometheus stack, download here: https://helm.sh/docs/intro/install/


## The Prometheus stack

**kube-prometheus-stack** is a collection of Kubernetes manifests including the follow

Prometheus operator
Prometheus
Alertmanager
Prometheus node-exporter
Prometheus Adapter
kube-state-metrics
Grafana
pre-configured to collect metrics from all Kubernetes component
delivers a default set of dashboards and alerting rules

Just before to install **kube-prometheus-stack**, create a dedicated namespace:

```console
$ kubectl create ns monitoring
namespace/monitoring created
```

Now add the **kube-prometheus-stack** Helm repo

```console
$ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
"prometheus-community" has been added to your repositories
```

Update the Helm repositories index

```console
$ helm repo update
Hang tight while we grab the latest from your chart repositories..
...Successfully got an update from the "prometheus-community" chart repository
Update Complete. ⎈Happy Helming!⎈
``` 

Finally, install **kube-prometheus-stack** 

```console
$ helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring
```

Don't forget to clean up after you

```console
$ kubectl delete -f .
```


