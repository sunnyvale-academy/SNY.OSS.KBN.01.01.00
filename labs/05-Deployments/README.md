# Deployments

Before using **kubectl**, please set the **KUBECONFIG** environment variable to point to the right kubeconfig file.

```
$ export KUBECONFIG=../02-Multi-node_cluster/vagrant/kubeconfig.yaml
```

A deployment is a supervisor for pods, giving you fine-grained control over how and when a new pod version is rolled out as well as rolled back to a previous state.

Let’s create a deployment with a single container based on nginx:1.7.9 image, that supervises two replicas of a pod as well as a replica set:

```
$ kubectl apply -f nginx1.7.9-deployment.yaml
deployment.apps/nginx-deployment created
```

You can have a look at the deployment, as well as the the replica set and the pods the deployment looks after like so:

```
$ kubectl get deployments 
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   2/2     3            3           49s

$ kubectl get rs
NAME                          DESIRED   CURRENT   READY   AGE
nginx-deployment-5754944d6c   2         2         2       3m28s

$kubectl get pods
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-5754944d6c-8f669   1/1     Running   0          3m54s
nginx-deployment-5754944d6c-g46jw   1/1     Running   0          3m54s
```

Let's update the deployment with a container based on nginx:latest image.

```
$ kubectl apply -f nginx_latest-deployment.yaml
deployment.apps/nginx-deployment configured
```

If you type get pods, you may see the old deployment instances still running while the new deployment is creating the container
```
$ kubectl 
NAME                                READY   STATUS              RESTARTS   AGE
nginx-deployment-5754944d6c-g46jw   1/1     Running             0          10m
nginx-deployment-698c64b949-6pbgq   1/1     Running             0          11s
nginx-deployment-698c64b949-vl29q   0/1     ContainerCreating   0          10s
```

After a while, old pod instances are terminating, the new onces are already running
```
$ kubectl get pods
NAME                                READY   STATUS        RESTARTS   AGE
nginx-deployment-5754944d6c-g46jw   0/1     Terminating   0          11m
nginx-deployment-698c64b949-6pbgq   1/1     Running       0          45s
nginx-deployment-698c64b949-vl29q   1/1     Running       0          44s
```

At the end, pod instances stay running, the old ones are not deployed anymore
```
$ kubectl get pods
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-698c64b949-6pbgq   1/1     Running   0          72s
nginx-deployment-698c64b949-vl29q   1/1     Running   0          71s
```

Also, a new replica set has been created by the deployment:

```
$ kubectl get rs
NAME                          DESIRED   CURRENT   READY   AGE
nginx-deployment-5754944d6c   0         0         0       17m
nginx-deployment-698c64b949   2         2         2       7m23s
```

Note that during the deployment you can check the progress using **kubectl rollout status deploy/nginx-deployment**

```
$ kubectl rollout status deploy/nginx-deployment
deployment "nginx-deployment" successfully rolled out
```

A history of all deployments is available via:

```
$ kubectl rollout history deploy/nginx-deployment
deployment.extensions/nginx-deployment 
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
```

If there are problems in the deployment Kubernetes will automatically roll back to the previous version, however you can also explicitly roll back to a specific revision, as in our case to revision 1 (the original pod version):

```
$ kubectl rollout undo deploy/nginx-deployment --to-revision=1
deployment.extensions/nginx-deployment rolled back

$ kubectl rollout history deploy/nginx-deployment
deployment.extensions/nginx-deployment 
REVISION  CHANGE-CAUSE
2         <none>
3         <none>
```

At this point in time we’re back at where we started

What if we want to manually scale this deployment with replica = 10?

```
$ kubectl scale --replicas=10 deployment/nginx-deployment
deployment.extensions/nginx-deployment scaled
```

Verify the pods scaling

```
$ kubectl get pods
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-5754944d6c-2hrtr   1/1     Running   0          19s
nginx-deployment-5754944d6c-5c8sk   1/1     Running   0          19s
nginx-deployment-5754944d6c-5msgp   1/1     Running   0          4m33s
nginx-deployment-5754944d6c-d5qw2   1/1     Running   0          19s
nginx-deployment-5754944d6c-fp6rb   1/1     Running   0          19s
nginx-deployment-5754944d6c-grfgc   1/1     Running   0          19s
nginx-deployment-5754944d6c-kpkbb   1/1     Running   0          19s
nginx-deployment-5754944d6c-mgdp5   1/1     Running   0          4m31s
nginx-deployment-5754944d6c-rjv8h   1/1     Running   0          19s
nginx-deployment-5754944d6c-rzn2j   1/1     Running   0          19s
```


Let's verify how pods have been balanced between nodes

```
$ kubectl get pods -o wide
NAME                                READY   STATUS    RESTARTS   AGE   IP            NODE    NOMINATED NODE   READINESS GATES
nginx-deployment-5754944d6c-298qd   1/1     Running   0          12s   10.244.1.15   node1   <none>           <none>
nginx-deployment-5754944d6c-4tv4w   1/1     Running   0          7s    10.244.1.18   node1   <none>           <none>
nginx-deployment-5754944d6c-86tnb   1/1     Running   0          7s    10.244.1.19   node1   <none>           <none>
nginx-deployment-5754944d6c-czzq5   1/1     Running   0          12s   10.244.2.13   node2   <none>           <none>
nginx-deployment-5754944d6c-gjv4j   1/1     Running   0          7s    10.244.2.17   node2   <none>           <none>
nginx-deployment-5754944d6c-hbqbt   1/1     Running   0          7s    10.244.1.17   node1   <none>           <none>
nginx-deployment-5754944d6c-hrzct   1/1     Running   0          7s    10.244.2.16   node2   <none>           <none>
nginx-deployment-5754944d6c-k9cdl   1/1     Running   0          7s    10.244.1.16   node1   <none>           <none>
nginx-deployment-5754944d6c-wm5dk   1/1     Running   0          7s    10.244.2.15   node2   <none>           <none>
nginx-deployment-5754944d6c-xkqjg   1/1     Running   0          7s    10.244.2.14   node2   <none>           <none>
```

Finally, to clean up, we remove the deployment and with it the replica sets and pods it supervises:

```
$ kubectl delete deploy nginx-deployment
deployment.extensions "nginx-deployment" deleted

$ kubectl get pods
No resources found.
```