# Monitoring

## Prerequisites

Before using **kubectl**, please set the **KUBECONFIG** environment variable to point to the right kubeconfig file.

```console
$ export KUBECONFIG=../02-Multi-node_cluster/vagrant/kubeconfig.yaml
```

Other than `kubectl`, you need `helm` installed on your computer in order to deploy the Prometheus stack, download here: https://helm.sh/docs/intro/install/


## The Prometheus stack

**kube-prometheus-stack** is a collection of Kubernetes manifests including the following:

- Prometheus operator
- Prometheus
- Alertmanager
- Prometheus node-exporter
- Prometheus Adapter
- kube-state-metrics
- Grafana

pre-configured to collect metrics from all Kubernetes component
delivers a default set of dashboards and alerting rules.

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
NAME: prometheus
LAST DEPLOYED: Wed May  5 13:29:17 2021
NAMESPACE: monitoring
STATUS: deployed
REVISION: 1
NOTES:
kube-prometheus-stack has been installed. Check its status by running:
  kubectl --namespace monitoring get pods -l "release=prometheus"

Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator.
```

You should see a lot of pods in the newly created **moniitoring** namespace

```console
$ kubectl get pods -n monitoring
NAME                                                     READY   STATUS    RESTARTS   AGE
alertmanager-prometheus-kube-prometheus-alertmanager-0   2/2     Running   0          34s
prometheus-grafana-55766c6774-6szvl                      2/2     Running   0          47s
prometheus-kube-prometheus-operator-57dd45c455-57f9b     1/1     Running   0          46s
prometheus-kube-state-metrics-577cdff758-xlngj           1/1     Running   0          46s
prometheus-prometheus-kube-prometheus-prometheus-0       2/2     Running   1          34s
prometheus-prometheus-node-exporter-bldmn                1/1     Running   0          47s
prometheus-prometheus-node-exporter-c5lkc                1/1     Running   0          47s
prometheus-prometheus-node-exporter-k5959                1/1     Running   0          47s
```



Don't forget to clean up after you

```console
$ kubectl delete -f .
```


