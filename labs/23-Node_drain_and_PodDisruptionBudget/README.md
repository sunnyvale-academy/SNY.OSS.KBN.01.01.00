# Node drain and PodDisruptionBudget

## Prerequisites

Before using **kubectl**, please set the **KUBECONFIG** environment variable to point to the right kubeconfig file.

```console
$ export KUBECONFIG=../02-Multi-node_cluster/vagrant/kubeconfig.yaml
```

## The PodDisruptionBudget resource

Pod disruption events include both by actions initiated by the application owner and those initiated by a Cluster Administrator. 

Typical application owner actions include:
- deleting the deployment or other controller that manages the pod
- updating a deployment’s pod template causing a restart
- directly deleting a pod (e.g. by accident)

Cluster Administrator actions include:
- draining a node for repair or upgrade.
- draining a node from a cluster to scale the cluster down.
- removing a pod from a node to permit something else to fit on that node.

An Application Owner can create a **PodDisruptionBudget** object (PDB) for each application. A PDB limits the number of pods of a replicated application that are down simultaneously from voluntary disruptions.

You can specify Pod Disruption Budgets for Pods managed by these built-in Kubernetes controllers:

- Deployment
- ReplicationController
- ReplicaSet
- StatefulSet

## Applying PodDisruptionBudget resource

First, create a **Deployment** with an initial pod replication factor of 1.

```console
$ kubectl apply -f nginx-deployment.yaml 
deployment.apps/nginx-deployment  created
```

```console
$  kubectl get pods -o wide      
NAME                                READY   STATUS    RESTARTS   AGE     IP             NODE    NOMINATED NODE   READINESS GATES
nginx-deployment-68c7f5464c-nxzb5   1/1     Running   0          3m41s   10.244.1.113   node1   <none>           <none>
```

Then we create the PodDisruptionBudget (PDB) resource for the pod, to ensure that **at least** 1 pod replica is up & running at a time.
PDB resource is mapped to the pod/s using labels and selector.

```yaml
apiVersion: policy/v1beta1
kind: PodDisruptionBudget
metadata:
  name: nginx-pdb
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: nginx
```

```console
$ kubectl apply -f pdb.yaml 
poddisruptionbudget.policy/nginx-pdb created
```

```console
$ kubectl get pdb
NAME                           MIN AVAILABLE   MAX UNAVAILABLE   ALLOWED DISRUPTIONS   AGE
nginx-pdb                      1               N/A               0                     14s
```

If you try to drain the node where the pod is running on (node1 in out example), K8S system prevent you to do so since you would violate the PodDisruptionBudget:

```console
$ kubectl drain node1 --ignore-daemonsets --delete-local-data
node/node1 cordoned
WARNING: ignoring DaemonSet-managed Pods: kube-system/kube-flannel-ds-amd64-gp2bs, kube-system/kube-proxy-bsg6c
evicting pod "nginx-deployment-68c7f5464c-nxzb5"
...
```
This command will retry every 5 seconds to drain the node without violating the PodDisruptionBudget. To succeed we have to scale up the deployment.
Using another shell, scale up the deployment with the following command:

```console
$ kubectl scale --replicas=2 deployment/nginx-deployment
deployment.extensions/nginx-deployment scaled
```

As soon as the second pod instance pops up, in the previous terminal the drain command succeed

```console
...
pod/nginx-deployment-68c7f5464c-nxzb5 evicted
node/node1 evicted
```

```console
$ kubectl get pods -o wide        
NAME                                READY   STATUS    RESTARTS   AGE   IP             NODE    NOMINATED NODE   READINESS GATES
nginx-deployment-68c7f5464c-76cn4   1/1     Running   0          72s   10.244.2.142   node2   <none>           <none>
nginx-deployment-68c7f5464c-zh64k   1/1     Running   0          77s   10.244.2.141   node2   <none>           <none>
```

In this way, the two pods have been scheduled on node2 since node1 has been cordoned (SchedulingDisabled) as a result of the drain.

```console
$ kubectl get nodes
NAME     STATUS                     ROLES    AGE     VERSION
master   Ready                      master   2d17h   v1.15.3
node1    Ready,SchedulingDisabled   <none>   2d17h   v1.15.3
node2    Ready                      <none>   2d17h   v1.15.3
```

To uncordon the node1

```console
$ kubectl uncordon node1
node/node1 uncordoned
```




