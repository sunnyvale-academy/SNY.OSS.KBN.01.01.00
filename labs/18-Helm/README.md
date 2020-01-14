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
datadir-0-my-kafka-cp-kafka-0        Bound    pvc-d6cdc406-7916-4b75-9660-a24f9bc7c9c1   5Gi        RWO            nfs-dynamic    5m19s
datadir-0-my-kafka-cp-kafka-1        Bound    pvc-0feecc14-258a-443e-aa7f-41d2d465cd2a   5Gi        RWO            nfs-dynamic    88s
datadir-0-my-kafka-cp-kafka-2        Bound    pvc-eae8bee3-5d51-4fda-b5db-44e2f7149634   5Gi        RWO            nfs-dynamic    45s
datadir-my-kafka-cp-zookeeper-0      Bound    pvc-ca846262-e727-421e-a908-8ee74be79d95   5Gi        RWO            nfs-dynamic    5m19s
datadir-my-kafka-cp-zookeeper-1      Bound    pvc-266f08ce-f178-4e8d-b426-c51eca49a4a5   5Gi        RWO            nfs-dynamic    79s
datadir-my-kafka-cp-zookeeper-2      Bound    pvc-3add7ae9-1cce-4dae-8dcf-fe4ac38d89c5   5Gi        RWO            nfs-dynamic    38s
datalogdir-my-kafka-cp-zookeeper-0   Bound    pvc-5444a6dd-59a6-4c41-a185-bac75e10cd4f   5Gi        RWO            nfs-dynamic    5m19s
datalogdir-my-kafka-cp-zookeeper-1   Bound    pvc-33d925c3-4598-4078-a626-dc1408b9a983   5Gi        RWO            nfs-dynamic    79s
datalogdir-my-kafka-cp-zookeeper-2   Bound    pvc-b954cacf-84c8-4a54-9d85-c70407692790   5Gi        RWO            nfs-dynamic    38s
```

```console
$ kubectl get pv                                                        
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                        STORAGECLASS   REASON   AGE
pvc-0feecc14-258a-443e-aa7f-41d2d465cd2a   5Gi        RWO            Delete           Bound    default/datadir-0-my-kafka-cp-kafka-1        nfs-dynamic             2m51s
pvc-266f08ce-f178-4e8d-b426-c51eca49a4a5   5Gi        RWO            Delete           Bound    default/datadir-my-kafka-cp-zookeeper-1      nfs-dynamic             2m41s
pvc-33d925c3-4598-4078-a626-dc1408b9a983   5Gi        RWO            Delete           Bound    default/datalogdir-my-kafka-cp-zookeeper-1   nfs-dynamic             2m40s
pvc-3add7ae9-1cce-4dae-8dcf-fe4ac38d89c5   5Gi        RWO            Delete           Bound    default/datadir-my-kafka-cp-zookeeper-2      nfs-dynamic             119s
pvc-5444a6dd-59a6-4c41-a185-bac75e10cd4f   5Gi        RWO            Delete           Bound    default/datalogdir-my-kafka-cp-zookeeper-0   nfs-dynamic             6m38s
pvc-b954cacf-84c8-4a54-9d85-c70407692790   5Gi        RWO            Delete           Bound    default/datalogdir-my-kafka-cp-zookeeper-2   nfs-dynamic             119s
pvc-ca846262-e727-421e-a908-8ee74be79d95   5Gi        RWO            Delete           Bound    default/datadir-my-kafka-cp-zookeeper-0      nfs-dynamic             6m39s
pvc-d6cdc406-7916-4b75-9660-a24f9bc7c9c1   5Gi        RWO            Delete           Bound    default/datadir-0-my-kafka-cp-kafka-0        nfs-dynamic             6m40s
pvc-eae8bee3-5d51-4fda-b5db-44e2f7149634   5Gi        RWO            Delete           Bound    default/datadir-0-my-kafka-cp-kafka-2        nfs-dynamic             2m8s
```

```console
$ kubectl get po 
NAME                                      READY   STATUS              RESTARTS   AGE
NAME                               READY   STATUS             RESTARTS   AGE
my-kafka-cp-kafka-0                2/2     Running            3          7m33s
my-kafka-cp-kafka-1                2/2     Running            2          3m42s
my-kafka-cp-kafka-2                2/2     Running            2          2m59s
my-kafka-cp-zookeeper-0            2/2     Running            0          7m33s
my-kafka-cp-zookeeper-1            2/2     Running            0          3m33s
my-kafka-cp-zookeeper-2            2/2     Running            0          2m52s
nfs-provisioner-77bb4bd457-g6z2x   1/1     Running            0          9m26s
```

Remove everything:

```console
$ helm uninstall my-kafka
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


