# StatefulSet

Before using **kubectl**, please set the **KUBECONFIG** environment variable to point to the right kubeconfig file.

```console
$ export KUBECONFIG=../02-Multi-node_cluster/vagrant/kubeconfig.yaml
```

If you have a stateless app you want to use a deployment. However, for a stateful app you might want to use a StatefulSet. Unlike a deployment, the StatefulSet provides certain guarantees about the identity of the pods it is managing (that is, predictable names) and about the startup order. Two more things that are different compared to a deployment: for network communication you need to create a headless services and for persistency the StatefulSet manages a persistent volume per pod.

In order to see how this all plays together, we will be using an educational Kubernetes-native NoSQL datastore.