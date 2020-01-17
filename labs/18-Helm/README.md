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
cp-ksql-server:
  enabled: false
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
datadir-0-my-kafka-cp-kafka-0        Bound    pvc-1d873b6c-43bc-4271-9f4e-ed24681fa9c5   107374182400m   RWO            nfs-dynamic    4m9s
datadir-0-my-kafka-cp-kafka-1        Bound    pvc-e1584bbf-9ca3-4e08-a924-fa7dd81b6512   107374182400m   RWO            nfs-dynamic    4m6s
datadir-my-kafka-cp-zookeeper-0      Bound    pvc-a2b7796b-b5fe-432c-ab7e-1a6d1872307f   107374182400m   RWO            nfs-dynamic    4m9s
datadir-my-kafka-cp-zookeeper-1      Bound    pvc-3ee52593-c45b-4715-8975-8861a4677b6f   107374182400m   RWO            nfs-dynamic    4m1s
datadir-my-kafka-cp-zookeeper-2      Bound    pvc-b4838436-d61f-4ff7-a029-0dd8e094688f   107374182400m   RWO            nfs-dynamic    3m56s
datalogdir-my-kafka-cp-zookeeper-0   Bound    pvc-1cc5930f-5132-4027-be0f-b10df7d3d511   107374182400m   RWO            nfs-dynamic    4m9s
datalogdir-my-kafka-cp-zookeeper-1   Bound    pvc-29a168c3-9d90-484f-96b8-a18873397e3f   107374182400m   RWO            nfs-dynamic    4m1s
datalogdir-my-kafka-cp-zookeeper-2   Bound    pvc-a9e7fa48-15ac-48c2-9c0e-6a3d8fd316f6   107374182400m   RWO            nfs-dynamic    3m56s
```

```console
$ kubectl get pv                                                        
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                        STORAGECLASS   REASON   AGE
pvc-1cc5930f-5132-4027-be0f-b10df7d3d511   107374182400m   RWO            Delete           Bound    default/datalogdir-my-kafka-cp-zookeeper-0   nfs-dynamic             4m20s
pvc-1d873b6c-43bc-4271-9f4e-ed24681fa9c5   107374182400m   RWO            Delete           Bound    default/datadir-0-my-kafka-cp-kafka-0        nfs-dynamic             4m21s
pvc-29a168c3-9d90-484f-96b8-a18873397e3f   107374182400m   RWO            Delete           Bound    default/datalogdir-my-kafka-cp-zookeeper-1   nfs-dynamic             4m12s
pvc-3ee52593-c45b-4715-8975-8861a4677b6f   107374182400m   RWO            Delete           Bound    default/datadir-my-kafka-cp-zookeeper-1      nfs-dynamic             4m12s
pvc-a2b7796b-b5fe-432c-ab7e-1a6d1872307f   107374182400m   RWO            Delete           Bound    default/datadir-my-kafka-cp-zookeeper-0      nfs-dynamic             4m20s
pvc-a9e7fa48-15ac-48c2-9c0e-6a3d8fd316f6   107374182400m   RWO            Delete           Bound    default/datalogdir-my-kafka-cp-zookeeper-2   nfs-dynamic             4m8s
pvc-b4838436-d61f-4ff7-a029-0dd8e094688f   107374182400m   RWO            Delete           Bound    default/datadir-my-kafka-cp-zookeeper-2      nfs-dynamic             4m8s
pvc-e1584bbf-9ca3-4e08-a924-fa7dd81b6512   107374182400m   RWO            Delete           Bound    default/datadir-0-my-kafka-cp-kafka-1        nfs-dynamic             4m18s
```

```console
$ kubectl get po 
NAME                                      READY   STATUS              RESTARTS   AGE
NAME                               READY   STATUS             RESTARTS   AGE
my-kafka-cp-kafka-0                2/2     Running   1          4m52s
my-kafka-cp-kafka-1                2/2     Running   0          4m49s
my-kafka-cp-zookeeper-0            2/2     Running   0          4m52s
my-kafka-cp-zookeeper-1            2/2     Running   0          4m44s
my-kafka-cp-zookeeper-2            2/2     Running   0          4m39s
```

Remove everything:

```console
$ helm uninstall my-kafka
release "my-kafka" deleted
```

```console
$ kubectl delete pvc --all
persistentvolumeclaim "datadir-0-my-kafka-cp-kafka-0" deleted
persistentvolumeclaim "datadir-0-my-kafka-cp-kafka-1" deleted
persistentvolumeclaim "datadir-my-kafka-cp-zookeeper-0" deleted
persistentvolumeclaim "datadir-my-kafka-cp-zookeeper-1" deleted
persistentvolumeclaim "datadir-my-kafka-cp-zookeeper-2" deleted
persistentvolumeclaim "datalogdir-my-kafka-cp-zookeeper-0" deleted
persistentvolumeclaim "datalogdir-my-kafka-cp-zookeeper-1" deleted
persistentvolumeclaim "datalogdir-my-kafka-cp-zookeeper-2" deleted
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


