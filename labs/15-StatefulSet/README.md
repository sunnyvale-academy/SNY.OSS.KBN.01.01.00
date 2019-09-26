# StatefulSet

Before using **kubectl**, please set the **KUBECONFIG** environment variable to point to the right kubeconfig file.

```console
$ export KUBECONFIG=../02-Multi-node_cluster/vagrant/kubeconfig.yaml
```

If you have a stateless app you want to use a deployment. However, for a stateful app you might want to use a StatefulSet. Unlike a deployment, the StatefulSet provides certain guarantees about the identity of the pods it is managing (that is, predictable names) and about the startup order. Two more things that are different compared to a deployment: for network communication you need to create a headless services and for persistency the StatefulSet manages a persistent volume per pod.

In order to see how this all plays together, we will be using an educational Kubernetes-native NoSQL datastore.

As a prerequisite for this lab, we need to install a provisioner for the StorageClass used by our StatefulSet, we can use the same explained in lab [12-StorageClass](../12-StatefulSet/README.md), let's create it with all its dependencies using the following command:

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

The provisioner pod will be responsible to create PV dynamically on behalf of the StatefulSet.


```console
$ kubectl apply -f statefulset.yaml      
statefulset.apps/mehdb created
```

After a few minutes, let's verify if everything went smootlhy so far.


```console
$ kubectl get pods -o wide
NAME                               READY   STATUS    RESTARTS   AGE     IP           NODE     NOMINATED NODE   READINESS GATES
mehdb-0                            1/1     Running   0          2m49s   10.244.1.2   node1    <none>           <none>
mehdb-1                            1/1     Running   0          89s     10.244.2.2   node2    <none>           <none>
nfs-provisioner-77bb4bd457-whlbj   1/1     Running   0          23m     10.244.0.6   master   <none>           <none>
```

We now have the PV provisioner pod and two pods created by the StatefulSet. Please note that the latters have a more predictable name  ending with - and a sequential number, compared to if they were created by a Deployment object.

Also, every mehdb pod has been scheduled on different node.

If you take a look of PVs, you can see that every mehdb pod claimed its own instead of sharing one, and theire staus is **Bound** (thus PV provisioner pod worked as expected). 

```console
$ kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                  STORAGECLASS   REASON   AGE
pvc-60309b5b-039c-44ae-96a1-37782ba2e26f   1Gi        RWX            Delete           Bound    default/data-mehdb-1   nfs-dynamic             9m17s
pvc-d2d553fd-fec0-4f02-b97b-c4c7bf76dc45   1Gi        RWX            Delete           Bound    default/data-mehdb-0   nfs-dynamic             10m
```

This behaviour is caused by the StatefulSet's **volumeClaimTemplates** element:

```yaml
...
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: [ "ReadWriteMany" ]
      storageClassName: "nfs-dynamic"
      resources:
        requests:
          storage: 1Gi
```

storageClassName **nfs-dynamic** must match the one configured in [../12-StorageClass/nfs-storageclass.yaml](../12-StorageClass/nfs-storageclass.yaml) so as to link the correct provisioner.

Before testing our stateful application, we need to create the corresponding headless Service. 

A headless Service is a service without a cluster IP so instead of load-balancing it will return the IPs of the associated Pods. This allows us to interact directly with the pods instead of the cluster IP.

To create an headless Service you need to specify `None` as a value for `.spec.clusterIP`.

Let's create the headless Service with the following command:

```console
$ kubectl apply -f headless-service.yaml
service/mehdb created
```

To see if it worked:

```console
$ kubectl get svc
NAME              TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                              AGE
...
mehdb             ClusterIP   None             <none>        9876/TCP                             42s
...
```

Note the **None** value under **ClusterIP** header.

Now we can check if the stateful app is working properly. To do this, we use the /status endpoint of the headless service mehdb:9876 and since we haven’t put any data yet into the datastore, we’d expect that 0 keys are reported:

```console
$ kubectl run -i --rm --tty busybox --image=busybox --restart=Never -- wget -qO- "mehdb:9876/status?level=full"
0
pod "busybox" deleted
```

And indeed we see 0 keys being available, reported above.


Don't forget to clean up after you:

```console
$ kubectl delete -f .
service "mehdb" deleted
statefulset.apps "mehdb" deleted

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
