# Replication Controller

The Replication Controller is the original form of replication in Kubernetes.  It’s being replaced by Replica Sets.

A Replication Controller is a structure that enables you to easily create multiple pods, then make sure that that number of pods always exists. If a pod does crash, the Replication Controller replaces it.

If there are too many pods, the ReplicationController terminates the extra pods. If there are too few, the ReplicationController starts more pods. Unlike manually created pods, the pods maintained by a ReplicationController are automatically replaced if they fail, are deleted, or are terminated. 

Create the RC

```
$ kubectl create -f nginx-rc.yaml
replicationcontroller/nginx created
```

Get informations about the RC

```
$ kubectl get rc                                                       
NAME    DESIRED   CURRENT   READY   AGE
nginx   2         2         0       69s
```

Describe the RC

```
$ kubectl describe rc/nginx
Name:         nginx
Namespace:    default
Selector:     app=nginx
Labels:       app=nginx
Annotations:  <none>
Replicas:     2 current / 2 desired
Pods Status:  0 Running / 2 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  app=nginx
  Containers:
   nginx:
    Image:        nginx
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Events:
  Type    Reason            Age   From                    Message
  ----    ------            ----  ----                    -------
  Normal  SuccessfulCreate  24s   replication-controller  Created pod: nginx-cs7z4
  Normal  SuccessfulCreate  24s   replication-controller  Created pod: nginx-cbvxg
```

Finally, delete the RC

```
$ kubectl delete -f nginx-rc.yaml
replicationcontroller "nginx" deleted
```

As you can see, when you delete the Replication Controller, you also delete all of the pods that it created.

```
$ kubectl get pods                                                     
No resources found.
```

