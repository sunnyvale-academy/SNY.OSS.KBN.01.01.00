# StorageClass

Before using **kubectl**, please set the **KUBECONFIG** environment variable to point to the right kubeconfig file.

```console
$ export KUBECONFIG=../02-Multi-node_cluster/vagrant/kubeconfig.yaml
```

For a Kubernetes cluster with multiple worker nodes, the cluster admin needs to create persistent volumes that are mountable by containers running on any node and matching the capacity and access requirements in each persistent volume claim. Cloud provider managed Kubernetes clusters from IBM, Google, AWS, and others support dynamic volume provisioning. As a developer you can request a dynamic persistent volume from these services by including a storage class in your persistent volume claim.

In this tutorial, you will see how to add a dynamic NFS provisioner that runs as a container for a local Kubernetes cluster.


## Create the storage path

On the node where you will be providing the backing storage (in this case the master node), open a shell and create a directory for use by the nfs provisioner pod.

```console
$ vagrant ssh master
vagrant@master:~$ sudo mkdir -p /storage/dynamic
vagrant@master:~$ exit
```

## Configure and deploy nfs provisioner pod

In this step, you’ll set up the nfs-provisioner deployment so that the pod starts on the intended node. In some cases, this can be as simple as providing a specific nodeSelector in the deployment.

In Kubernetes, nodes can be tagged with special characteristics, called taints. These taints control workload selection for the node. For example the master node has a taint to prevent scheduling.

To start the nfs-provisioner on the master node, a toleration is added to the deployment file.

In this file, the spec from lines 35 to 41 provide a toleration for the taints on the master node and then node selector for the master:

```yaml
tolerations:
  - key: "node-role.kubernetes.io/master"
    operator: "Exists"
    effect: "NoSchedule"
nodeSelector:
  role: master
```

Create the provisioner pod and its associated service.

```console
$ kubectl create -f nfs-provisioner.yaml
service "nfs-provisioner" created
serviceaccount/nfs-provisioner created
deployment "nfs-provisioner" created
```

Now verify if the provisioner pod is running. 

```console
$ kubectl get pods
NAME                               READY   STATUS    RESTARTS   AGE
nfs-provisioner-5dc8995f89-qm4d4   1/1     Running   0          4m
```
If its status remains **Pending** probably it can't be scheduled on the master node. Please use the command  `kubectl describe pod <POD NAME>` to get informations about the problem.

Create ClusterRole, ClusterRoleBinding, Role and RoleBinding (this is necessary if you use RBAC authorization on your cluster, which is the default for newer kubernetes versions).

```
$ kubectl create -f rbac.yaml
clusterrole.rbac.authorization.k8s.io/nfs-provisioner-runner created
clusterrolebinding.rbac.authorization.k8s.io/run-nfs-provisioner created
role.rbac.authorization.k8s.io/leader-locking-nfs-provisioner created
rolebinding.rbac.authorization.k8s.io/leader-locking-nfs-provisioner created
```


## Define storage class


```console
$ kubectl create -f nfs-storageclass.yaml
storageclass.storage.k8s.io/nfs-dynamic created
```


## Test the Class with a Persistent Volume Claim

```console
$ kubectl create -f nfs-testclass-pvc.yaml 
persistentvolumeclaim/nfs created
```

Check the pvc status that must be **Bound**

```console
$ kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM         STORAGECLASS   REASON   AGE
pvc-263e84a0-0ac3-4a4a-8ee3-d53f4360c3a3   1Mi        RWX            Delete           Bound    default/nfs   nfs-dynamic             105s
```

Deleting the PersistentVolumeClaim will cause the provisioner to delete the PersistentVolume and its data.

```console
$ kubectl delete -f nfs-testclass-pvc.yaml 
persistentvolumeclaim "nfs" deleted
```

```console
$ kubectl get pv
No resources found.
```

Don't forget to clean up after you:

```console
$ kubectl delete -f .
service "nfs-provisioner" deleted
serviceaccount "nfs-provisioner" deleted
deployment.apps "nfs-provisioner" deleted
storageclass.storage.k8s.io "nfs-dynamic" deleted
clusterrole.rbac.authorization.k8s.io "nfs-provisioner-runner" deleted
clusterrolebinding.rbac.authorization.k8s.io "run-nfs-provisioner" deleted
role.rbac.authorization.k8s.io "leader-locking-nfs-provisioner" deleted
rolebinding.rbac.authorization.k8s.io "leader-locking-nfs-provisioner" deleted
```


