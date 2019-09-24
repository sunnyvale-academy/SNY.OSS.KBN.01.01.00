# Ingress

Before using **kubectl**, please set the **KUBECONFIG** environment variable to point to the right kubeconfig file.

```console
$ export KUBECONFIG=../02-Multi-node_cluster/vagrant/kubeconfig.yaml
```

## Configure security needed for the Ingress Controller to work

We first need to grant some permissions to Traefik to access Pods, Endpoints, and Services running in your cluster. To this end, we will be using a ServiceAccount, ClusterRole and a ClusterRoleBinding resources.

Let's start from ServiceAccount

```console
$ kubectl create -f traefik-service-acc.yaml
serviceaccount/traefik-ingress created
```

Next, let’s create a ClusterRole with a set of permissions which will be applied to the Traefik ServiceAccount. The ClusterRole will allow Traefik to manage and watch such resources as Services, Endpoints, Secrets, and Ingresses across all namespaces in your cluster.

```console
$ kubectl create -f traefik-cr.yaml
clusterrole.rbac.authorization.k8s.io/traefik-ingress created
```

Finally, to enable these permissions, we should bind the ClusterRole to the Traefik ServiceAccount. This can be done using the ClusterRoleBinding resource:

```console
$ kubectl create -f traefik-crb.yaml 
clusterrolebinding.rbac.authorization.k8s.io/traefik-ingress created
```

## Deploy the backends we want to access through the Ingress


First we create a **Deployment** based on nginx Docker image

```console
$ kubectl apply -f nginx-deployment.yaml 
deployment.apps/nginx-deployment created
```

And we expose with a **ClusterIP** service the nginx Pod

```console
$ kubectl apply -f nginx-svc.yaml        
service/nginx-service created  
```

Then we create a **Deployment** based on containous/whoami Docker image

```console
$ kubectl apply -f whoami-deployment.yaml 
deployment.apps/whoami-deployment created
```

And we expose with a **ClusterIP** service the containous/whoami Pod as well

```console
$ kubectl apply -f whoami-svc.yaml        
service/whoami-service created  
```

## Deploy Traefik

Next, we will deploy Traefik to your Kubernetes cluster. The official Traefik documentation for Kubernetes supports three types of deployments: using a Deployment object, using a DaemonSet object, or using the Helm chart.

In this tutorial, we’ll be using the Deployment manifest. Deployments have a number of advantages over other options. For example, they secure better scalability (up and down scaling) and come with good support for rolling updates.

This Deployment will create one Traefik replica in the default namespace. The Traefik container will be using ports 80 exposed with a NodePort Service.

```console
$ kubectl create -f traefik-deployment.yaml 
deployment.extensions "traefik-ingress" created
```

Now, let’s check to see if the Traefik Pods were successfully created:

```console
$ kubectl get pods
...
traefik-ingress-7468c9c598-57m6c   1/1     Running   0          8s
...
```

As you can see, the Deployment Controller launched one Traefik Pod replica, and it is currently running. Awesome!


## Create NodePorts for External Access

```console
$ kubectl create -f traefik-svc.yaml 
service/traefik-ingress-service created
```

```console
$ kubectl describe svc traefik-ingress-service
Name:                     traefik-ingress-service
Namespace:                default
Labels:                   <none>
Annotations:              kubectl.kubernetes.io/last-applied-configuration:
                            {"apiVersion":"v1","kind":"Service","metadata":{"annotations":{},"name":"traefik-ingress-service","namespace":"default"},"spec":{"ports":[...
Selector:                 k8s-app=traefik-ingress-lb
Type:                     NodePort
IP:                       10.101.129.195
Port:                     web  80/TCP
TargetPort:               80/TCP
NodePort:                 web  30592/TCP
Endpoints:                10.244.1.40:80
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>
```

As you see, now we have one NodePort (“web”) that route to the 80 container port of the Traefik Ingress controller. 


## Adding Ingress resourse to the Cluster

Now we have Traefik as the Ingress Controller in the Kubernetes cluster. However, we still need to define the Ingress resource

```console
$ kubectl create -f traefik-ingress.yaml
ingress.extensions/traefik-web-ui created
```
Based on the routing defined into the `traefik-ingress.yaml`file, we should get this output (you can use your browser too)
Be aware that you have to use the NodePort showed by the `kubectl describe svc traefik-ingress-service` command.

```console
$ curl -H "Host: 192-168-26-11.nip.io" http://192-168-26-11.nip.io:30592/whoami 
Hostname: whoami-deployment-547545f65d-zjbgf
IP: 127.0.0.1
IP: 10.244.1.42
RemoteAddr: 10.244.1.41:38634
GET /whoami HTTP/1.1
Host: 192-168-26-11.nip.io
User-Agent: curl/7.45.0
Accept: */*
Accept-Encoding: gzip
X-Forwarded-For: 10.244.1.1
X-Forwarded-Host: 192-168-26-11.nip.io
X-Forwarded-Port: 80
X-Forwarded-Proto: http
X-Forwarded-Server: traefik-ingress-5f65985cc7-h4nsj
X-Real-Ip: 10.244.1.1
```

This was the whoami home page.

```console
$ curl -H "Host: 192-168-26-11.nip.io" http://192-168-26-11.nip.io:30592/                                                                      
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

This was the nginx home page.

To discover how the ingress routing works, please refer to the `traefik-ingress.yaml` file.

As expected, if you point to the other node, the command doesn't work.

```console
$ curl -H "Host: 192-168-26-12.nip.io" http://192-168-26-12.nip.io:30592/whoami
404 page not found
```

Can you guess why?

Finally, clen up resources:

```console
$ kubectl delete -f .
deployment.apps "nginx-deployment" deleted
service "nginx-service" deleted
clusterrole.rbac.authorization.k8s.io "traefik-ingress" deleted
clusterrolebinding.rbac.authorization.k8s.io "traefik-ingress" deleted
deployment.extensions "traefik-ingress" deleted
ingress.extensions "traefik-ingress" deleted
serviceaccount "traefik-ingress" deleted
service "traefik-ingress-service" deleted
deployment.apps "whoami-deployment" deleted
service "whoami-service" deleted
```

