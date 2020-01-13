# Helm

## Prerequisites

Before using **kubectl**, please set the **KUBECONFIG** environment variable to point to the right kubeconfig file.

```console
$ export KUBECONFIG=../02-Multi-node_cluster/vagrant/kubeconfig.yaml
```

This lab works form Helm version 3 onwards.

To check the Helm version type:

```console
$ helm version
version.BuildInfo{Version:"v3.0.1", GitCommit:"7c22ef9ce89e0ebeb7125ba2ebf7d421f3e82ffa", GitTreeState:"clean", GoVersion:"go1.13.4"}
```


## Helm (CLI) installation

On *nix

```console
$ curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
```

On MacOS (using Homebrew)

```console
$ brew install kubernetes-helm
```

On Windows (using Chocolatey)

```console
$ choco install kubernetes-helm
```

## Deployment prerequisites

We are going to install a Kafka cluster (3 pods for Kafka + 3 pods for Zookeeper) to show how Helm simplifies complex architecture  installation.

Since Kafka needs a StorageClass, please apply everything in the lab 12 with the following command:

```console
$ kubectl apply -f ../12-StorageClass/.
service/nfs-provisioner created
serviceaccount/nfs-provisioner created
deployment.apps/nfs-provisioner created
storageclass.storage.k8s.io/nfs-dynamic created
persistentvolumeclaim/nfs created
clusterrole.rbac.authorization.k8s.io/nfs-provisioner-runner created
clusterrolebinding.rbac.authorization.k8s.io/run-nfs-provisioner created
role.rbac.authorization.k8s.io/leader-locking-nfs-provisioner created
rolebinding.rbac.authorization.k8s.io/leader-locking-nfs-provisioner created
```


## Deploy a sample app using Helm

Let's inspect the initial repo/s configured on Helm.

```console
$ helm repo list
NAME            URL                                             
stable          https://kubernetes-charts.storage.googleapis.com
```

Sometimes, Charts are available on repos not known by default by Helm, so we have to add a new one:

```console
$ helm repo add confluentinc https://confluentinc.github.io/cp-helm-charts/ 
"confluentinc" has been added to your repositories
```

Update the repos

```console
$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "confluentinc" chart repository
...Successfully got an update from the "stable" chart repository
Update Complete.
```

I provided to you a [values.yaml](values.yaml) file with some variable overrides:

```yaml
cp-schema-registry:
  enabled: false
cp-kafka-rest:
  enabled: false
cp-kafka-connect:
  enabled: false
cp-zookeeper:
  enabled: true
  servers: 3
  persistence:
    enabled: true
    dataDirStorageClass: "nfs-dynamic"
    dataLogDirStorageClass: "nfs-dynamic"
cp-kafka:
  enabled: true
  brokers: 3
  persistence:
    enabled: true
    storageClass: "nfs-dynamic"
```

This values.yaml file will be used when installing the chart.

```console
$ helm install my-kafka --values=values.yaml confluentinc/cp-helm-charts
NAME: my-kafka
LAST DEPLOYED: Mon Jan 13 23:43:44 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
...
```

```console
$ helm list
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
my-kafka        default         1               2020-01-13 23:43:44.841543 +0100 CET    deployed        cp-helm-charts-0.1.0    1.0     
```

```console
$ kubectl get pvc                                                        
NAME                                 STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
datadir-0-my-kafka-cp-kafka-0        Bound    pvc-6815cc63-b045-49ba-9506-ef8fb206f137   5Gi        RWO            nfs-dynamic    4m8s
datadir-0-my-kafka-cp-kafka-1        Bound    pvc-54222ab3-c38c-49e1-9f94-1b0f1fae6e33   5Gi        RWO            nfs-dynamic    32s
datadir-my-kafka-cp-zookeeper-0      Bound    pvc-3def2ae4-5d6b-45c7-8bbc-6665c07e0a7f   5Gi        RWO            nfs-dynamic    4m8s
datalogdir-my-kafka-cp-zookeeper-0   Bound    pvc-c16c394d-1fb9-4fa7-a1a8-8cd559722555   5Gi        RWO            nfs-dynamic    4m8s
nfs 
```

```console
$ kubectl get po 
NAME                                      READY   STATUS              RESTARTS   AGE
my-kafka-cp-kafka-0                       2/2     Running             1          4m39s
my-kafka-cp-kafka-1                       2/2     Running             0          63s
my-kafka-cp-kafka-2                       0/2     ContainerCreating   0          1s
my-kafka-cp-ksql-server-7f9cb89b4-sqb6p   2/2     Running             1          4m39s
my-kafka-cp-zookeeper-0                   2/2     Running             0          4m39s
my-kafka-cp-zookeeper-1                   0/2     ContainerCreating   0          31s
nfs-provisioner-77bb4bd457-zknsq          1/1     Running             0          5m52s
```

Remove everything:

```console
$ helm delete --purge my-kafka
release "my-kafka" deleted
```


```console
$ kubectl delete -f ../12-StorageClass/.
service "nfs-provisioner" deleted
serviceaccount "nfs-provisioner" deleted
deployment.apps "nfs-provisioner" deleted
storageclass.storage.k8s.io "nfs-dynamic" deleted
persistentvolumeclaim "nfs" deleted
clusterrole.rbac.authorization.k8s.io "nfs-provisioner-runner" deleted
clusterrolebinding.rbac.authorization.k8s.io "run-nfs-provisioner" deleted
role.rbac.authorization.k8s.io "leader-locking-nfs-provisioner" deleted
rolebinding.rbac.authorization.k8s.io "leader-locking-nfs-provisioner" deleted

```


