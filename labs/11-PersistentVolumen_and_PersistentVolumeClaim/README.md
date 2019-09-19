# PersistentVolume and PersistentVolumeClaim

A persistent volume (PV) is a cluster-wide resource that you can use to store data in a way that it persists beyond the lifetime of a pod. The PV is not backed by locally-attached storage on a worker node but by networked storage system such as EBS or NFS or a distributed filesystem like Ceph.

Type the following to create the PV.

```
$ kubectl create -f nfs-volume.yaml
persistentvolume/pv0001 created
```

Let's check to see if it is available

```
$ kubectl get pv
NAME     CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
pv0001   5Gi        RWO            Retain           Available                                   52s
```

In order to use a PV you need to claim it first, using a persistent volume claim (PVC). The PVC requests a PV with your desired specification (size, speed, etc.) from Kubernetes and binds it then to a pod where you can mount it as a volume. 


```
$ kubectl create -f pvc.yaml
persistentvolumeclaim/nfs-pvc created
```

The Pod we are going to create is made of an nginx container, mounting the volume as the nginx document root

```
$ kubectl create -f pod.yaml
pod/hello-nfs-pod created
```

Verify that the pod was created:

```
$ kubectl get pods
```