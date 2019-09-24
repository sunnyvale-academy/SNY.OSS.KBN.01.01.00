# StorageClass

Before using **kubectl**, please set the **KUBECONFIG** environment variable to point to the right kubeconfig file.

```console
$ export KUBECONFIG=../02-Multi-node_cluster/vagrant/kubeconfig.yaml
```

For a Kubernetes cluster with multiple worker nodes, the cluster admin needs to create persistent volumes that are mountable by containers running on any node and matching the capacity and access requirements in each persistent volume claim. Cloud provider managed Kubernetes clusters from IBM, Google, AWS, and others support dynamic volume provisioning. As a developer you can request a dynamic persistent volume from these services by including a storage class in your persistent volume claim.

In this tutorial, you will see how to add a dynamic NFS provisioner that runs as a container for a local Kubernetes cluster.

