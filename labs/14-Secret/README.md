# Secret

Before using **kubectl**, please set the **KUBECONFIG** environment variable to point to the right kubeconfig file.

```console
$ export KUBECONFIG=../02-Multi-node_cluster/vagrant/kubeconfig.yaml
```

You don’t want sensitive information such as a database password or an API key kept around in clear text. Secrets provide you with a mechanism to use such information in a safe and reliable way with the following properties:

- Secrets are namespaced objects, that is, exist in the context of a namespace
- You can access them via a volume or an environment variable from a container running in a pod
- The secret data on nodes is stored in tmpfs volumes
- A per-secret size limit of 1MB exists
- The API server stores secrets as plaintext in etcd

Let’s create a file apikey that holds a (made-up) API key:

```console
$ echo -n "A19fh68B001j" > ./apikey.txt
```

This file can be used to create a Kubernetes Secret

```console
$ kubectl create secret generic apikey --from-file=./apikey.txt
secret/apikey created
```

Inspect the secret

```console
$ kubectl describe secrets/apikey
Name:         apikey
Namespace:    default
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
apikey.txt:  12 bytes
```

Now let’s use the secret in a pod via a volume:


```console
$ kubectl apply -f pod-secretvolume.yaml
pod/pod-secretvolume created
```

If we now exec into the container we see the secret mounted at /tmp/apikey:

```console
$  kubectl exec -it pod-secretvolume -c shell -- bash
[root@pod-secretvolume /]# mount | grep apikey
tmpfs on /tmp/apikey type tmpfs (ro,relatime)
[root@pod-secretvolume /]# cat /tmp/apikey/apikey.txt
A19fh68B001j
[root@pod-secretvolume /]# exit
```


You can remove both the pod and the secret with:

```console
$  kubectl delete pod/pod-secretvolume secret/apikey
pod "pod-secretvolume" deleted
secret "apikey" deleted
```
