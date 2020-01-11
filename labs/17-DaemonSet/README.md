# DaemonSet

## Prerequisites

Before using **kubectl**, please set the **KUBECONFIG** environment variable to point to the right kubeconfig file.

```console
$ export KUBECONFIG=../02-Multi-node_cluster/vagrant/kubeconfig.yaml
```

## Applying DaemonSets

A DaemonSet make sure that all or some kubernetes Nodes run a copy of a Pod. When a new node is added to the cluster, a Pod is added to it to match the rest of the nodes and when a node is removed from the cluster, the Pod is garbage collected. Deleting a DaemonSet will clean up the Pods it created.

```console
$ kubectl apply -f fluentd-daemonset.yaml
serviceaccount/fluentd created
clusterrole.rbac.authorization.k8s.io/fluentd created
clusterrolebinding.rbac.authorization.k8s.io/fluentd created
daemonset.extensions/fluentd created
```

As you can see every node has got its own pod (including master)


```console
$ kubectl get pod -o wide -n kube-system  
...
fluentd-59bhm                    1/1     Running   0          18s   10.244.0.22     master   <none>           <none>
fluentd-ffpqz                    1/1     Running   0          18s   10.244.1.22     node1    <none>           <none>
fluentd-szqnf                    1/1     Running   0          18s   10.244.2.22     node2    <none>           <none>
...
```

DaemonSets are useful to perform some operations on each node of the cluster, in this case Fluentd take logs from nodes and pushes them to a centralized architecture (Elasticsearch).

Don't forget to clean up after you:

```console
$ kubectl delete -f .
serviceaccount "fluentd" deleted
clusterrole.rbac.authorization.k8s.io "fluentd" deleted
clusterrolebinding.rbac.authorization.k8s.io "fluentd" deleted
daemonset.extensions "fluentd" deleted
```