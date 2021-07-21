# Network policies

If you want to control traffic flow at the IP address or port level (OSI layer 3 or 4), then you might consider using Kubernetes NetworkPolicies for particular applications in your cluster. NetworkPolicies are an application-centric construct which allow you to specify how a pod is allowed to communicate with various network "entities" (we use the word "entity" here to avoid overloading the more common terms such as "endpoints" and "services", which have specific Kubernetes connotations) over the network.

The entities that a Pod can communicate with are identified through a combination of the following 3 identifiers:

Other pods that are allowed (exception: a pod cannot block access to itself)
Namespaces that are allowed
IP blocks (exception: traffic to and from the node where a Pod is running is always allowed, regardless of the IP address of the Pod or the node)
When defining a pod- or namespace- based NetworkPolicy, you use a selector to specify what traffic is allowed to and from the Pod(s) that match the selector.

The Network Policy resource is part of the API group networking.k8s.io. Currently, it is in version v1.

The spec of the resource mainly consists of three parts:

- **podSelector**: Use labels to select the group of pods for which the rules will be applied.
- **policyTypes**: Which could be Ingress, Egress or both. This field will determine if the rules will be applied to incoming and/or outgoing traffic. If it is not defined, then Ingress will be enabled by default and Egress only when there are rules defined.
-**ingress/egress**: these sections allow a list of **from** (Ingress) or **to** (Egress) and ports blocks. Each **from/to** block contains a range of IPs (**ipBlock**) and/or a list of namespaces selected by label (**namespaceSelector**) and/or a list of pods by label (**podSelector**). That select which IPs, namespaces or pods can talk to our target pod or to which IPs, namespaces or pod our target can talk to. The ports block defines which ports are affected by this the rule.

## Prerequisites

### Setup tools

Before using **kubectl**, please set the **KUBECONFIG** environment variable to point to the right kubeconfig file.

```console
$ export KUBECONFIG=../02-Multi-node_cluster/vagrant/kubeconfig.yaml
```

In order for the network policy to function properly, a network policy-capable CNI diver must be installed on your K8s cluster (ie: Calico)

## Test Network policies

By default, pods are non-isolated; they accept traffic from any source.

Pods become isolated by having a NetworkPolicy that selects them. Once there is any NetworkPolicy in a namespace selecting a particular pod, that pod will reject any connections that are not allowed by any NetworkPolicy. (Other pods in the namespace that are not selected by any NetworkPolicy will continue to accept all traffic.)

Network policies do not conflict; they are additive. If any policy or policies select a pod, the pod is restricted to what is allowed by the union of those policies' ingress/egress rules. Thus, order of evaluation does not affect the policy result.

For a network flow between two pods to be allowed, both the egress policy on the source pod and the ingress policy on the destination pod need to allow the traffic. If either the egress policy on the source, or the ingress policy on the destination denies the traffic, the traffic will be denied.

We start the lab by deploying an Nginx webserver and its service.

```console
$ kubectl apply -f nginx_latest-deployment.yaml
deployment.apps/nginx-deployment created
service/nginx-svc created
```

By default, this Pod is reachable from another Pod

```console
$ kubectl run -ti --rm testing --image=busybox --restart=Never -- wget -qO- nginx-svc:80
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
pod "testing" deleted
```

### Blocking/allowing ingress traffic to a pod using podSelector

Before proceeding, make sure that there's not any others network policies in place.

```console
$ kubectl delete networkpolicies --all
No resources found
```

Let’s turn on isolation in our default namespace. Calico will then prevent connections to pods in this namespace.

Running the following command creates a NetworkPolicy which implements a default deny behavior for all pods in the default namespace.

```console
$ kubectl apply -f np_deny_default_ns.yaml 
networkpolicy.networking.k8s.io/default-deny created
```

Now we test the isolation:

```console
$ kubectl run -ti --rm testing --image=busybox --restart=Never -- wget -qO- nginx-svc:80
If you don't see a command prompt, try pressing enter.



wget: can't connect to remote host (10.108.98.237): Connection timed out
pod "testing" deleted
pod default/testing terminated (Error)
```

The nginx pod is now unreachable from another pod in the same namespace.

Now, let’s enable access to the nginx service using a NetworkPolicy. This will allow incoming connections from our testing pod, but not from anywhere else.

```console
$ kubectl apply -f np_allow_testing_default_ns.yaml
networkpolicy.networking.k8s.io/access-nginx created
```

We should now be able to access the service from the testing pod.

```console
$ kubectl run -ti --rm testing --image=busybox --restart=Never -- wget -qO- nginx-svc:80
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
pod "testing" deleted
```

What if we try to access Nginx from "another-pod"?

```console
$ kubectl run -ti --rm another-pod --image=busybox --restart=Never -- wget -qO- nginx-svc:80



wget: can't connect to remote host (10.108.98.237): Connection timed out
pod "testing" deleted
pod default/testing terminated (Error)
```

### Blocking/allowing ingress traffic between namespaces

Before proceeding, make sure that there's not any others network policies in place.

```console
$ kubectl delete networkpolicies --all
No resources found
```

We are now creating two namespaces **ns1** and **ns2**, each of them containing one pod (nginx) exposed via service.

```console
$  kubectl apply -f one_pod_per_ns.yaml 
namespace/ns1 created
deployment.apps/nginx-deployment-1 created
service/nginx-svc-1 created
namespace/ns2 created
deployment.apps/nginx-deployment-2 created
service/nginx-svc-2 created
```

This is the situation we have so far:

```console
$ kubectl get all -n ns1
NAME                                      READY   STATUS    RESTARTS   AGE
pod/nginx-deployment-1-79cbf6c9f5-qn4zh   1/1     Running   0          4m26s

NAME                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
service/nginx-svc-1   ClusterIP   10.107.153.219   <none>        80/TCP    3m59s

NAME                                 READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx-deployment-1   1/1     1            1           4m26s

NAME                                            DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-deployment-1-79cbf6c9f5   1         1         1       4m26s
```

```console
$ kubectl get all -n ns2
NAME                                     READY   STATUS    RESTARTS   AGE
pod/nginx-deployment-2-d66cdd5c8-9n57m   1/1     Running   0          4m15s

NAME                  TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/nginx-svc-2   ClusterIP   10.108.41.112   <none>        80/TCP    4m16s

NAME                                 READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx-deployment-2   1/1     1            1           4m16s

NAME                                           DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-deployment-2-d66cdd5c8   1         1         1       4m16s
```

We prove now that pod in ns2 reach the one in ns1 on its service port (80)

```console
$ kubectl exec -n ns2 -ti $(kubectl get pods -n ns2 | grep -v NAME | cut -d " " -f 1) -- curl nginx-svc-1.ns1.svc.cluster.local 
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

By applying the policy contained into **namespace_network_isolation_policy.yaml**, each pod will be reachable exclusively from the same namespace, thus not cross-namespace communication will be allowed anymore.

```console
$ kubectl apply -f namespace_network_isolation_policies.yaml
networkpolicy.networking.k8s.io/default-deny-ns1 created
networkpolicy.networking.k8s.io/default-deny-ns2 created
networkpolicy.networking.k8s.io/allow-ns1 created
networkpolicy.networking.k8s.io/allow-ns2 created
```

You wont be able anymore to reach the pod in **ns1** from a pod in **ns2**

```console
$ kubectl exec -n ns2 -ti $(kubectl get pods -n ns2 | grep -v NAME | cut -d " " -f 1) -- curl nginx-svc-1.ns1.svc.cluster.local 
curl: (7) Failed to connect to nginx-svc-1.ns1.svc.cluster.local port 80: Connection timed out
command terminated with exit code 7
```

But you are still able to reach the pod in **ns1** from **ns1**

```console
$ kubectl run -ti --rm testing -n ns1 --image=busybox --restart=Never -- wget -qO- nginx-svc-1.ns1.svc.cluster.local:80
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
pod "testing" deleted
```