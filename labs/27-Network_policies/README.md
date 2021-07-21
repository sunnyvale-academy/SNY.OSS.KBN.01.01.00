# Network policies

If you want to control traffic flow at the IP address or port level (OSI layer 3 or 4), then you might consider using Kubernetes NetworkPolicies for particular applications in your cluster. NetworkPolicies are an application-centric construct which allow you to specify how a pod is allowed to communicate with various network "entities" (we use the word "entity" here to avoid overloading the more common terms such as "endpoints" and "services", which have specific Kubernetes connotations) over the network.

The entities that a Pod can communicate with are identified through a combination of the following 3 identifiers:

Other pods that are allowed (exception: a pod cannot block access to itself)
Namespaces that are allowed
IP blocks (exception: traffic to and from the node where a Pod is running is always allowed, regardless of the IP address of the Pod or the node)
When defining a pod- or namespace- based NetworkPolicy, you use a selector to specify what traffic is allowed to and from the Pod(s) that match the selector.

Meanwhile, when IP based NetworkPolicies are created, we define policies based on IP blocks (CIDR ranges).

## Prerequisites

### Setup tools

Before using **kubectl**, please set the **KUBECONFIG** environment variable to point to the right kubeconfig file.

```console
$ export KUBECONFIG=../02-Multi-node_cluster/vagrant/kubeconfig.yaml
```

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

Now, let’s enable access to the nginx service using a NetworkPolicy. This will allow incoming connections from our access pod, but not from anywhere else.

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