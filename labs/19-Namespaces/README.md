# Namespaces

## Prerequisites

Before using **kubectl**, please set the **KUBECONFIG** environment variable to point to the right kubeconfig file.

```console
$ export KUBECONFIG=../02-Multi-node_cluster/vagrant/kubeconfig.yaml
```

## Functionality of Namespace

Namespace provides an additional qualification to a resource name. This is helpful when multiple teams are using the same cluster and there is a potential of name collision. It can be as a virtual wall between multiple clusters.


Following are some of the important functionalities of a Namespace in Kubernetes

- Namespaces help pod-to-pod communication using the same namespace.
- Namespaces are virtual clusters that can sit on top of the same physical cluster.
- They provide logical separation between the teams and their environments.

## Create a Namespace

Giving the following yaml called **namespace.yaml**

```yaml
apiVersion: v1
kind: Namespace
metadata:
   name: elk
```

This command is used to create a namespace

```console
$ kubectl create –f namespace.yaml
namespace/elk created
```

To get all the namespaces

```console
$ kubectl get namespace                                                                                                      
NAME                   STATUS   AGE
default                Active   42m
elk                    Active   28s
kube-node-lease        Active   42m
kube-public            Active   42m
kube-system            Active   42m
kubernetes-dashboard   Active   42m
```

To get all a single namespace

```console
$ kubectl get namespace elk
NAME   STATUS   AGE
elk    Active   86s
```

To get namespace informations

```console
$ kubectl describe namespace elk
Name:         elk
Labels:       <none>
Annotations:  <none>
Status:       Active

No resource quota.

No resource limits.
```

Namespaces can be specified in resource definitions in order to let the resource belong to specific namespace, for example:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: memory-demo
  namespace: mem-example
...
```

or in a Service

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: memory-demo
  namespace: mem-example
...
```

```console
$ kubectl create -f pod.yaml  
pod/nginx1 created
```

To query for pods in a specific namespace


```console
$ kubectl get pods -n elk
NAME     READY   STATUS    RESTARTS   AGE
nginx1   1/1     Running   0          80s
```

Finally, delete the namespace with all its content (the pod)

```console
$ kubectl delete namespace elk
namespace "elk" deleted
```