# Requests and Limits

## Prerequisites

Before using **kubectl**, please set the **KUBECONFIG** environment variable to point to the right kubeconfig file.

```console
$ export KUBECONFIG=../02-Multi-node_cluster/vagrant/kubeconfig.yaml
```

## Applying resource requests and limits

Within the pod configuration file cpu and memory are each a resource type for which constraints can be set at the container level. A resource type has a base unit. CPU is specified in units of cores, and memory is specified in units of bytes. Two types of constraints can be set for each resource type: requests and limits.

A **request** is the amount of that resources that the system will guarantee for the container, and Kubernetes will use this value to decide on which node to place the pod. A **limit** is the maximum amount of resources that Kubernetes will allow the container to use. In the case that request is not set for a container, it defaults to limit. If limit is not set, then if defaults to 0 (unbounded). Setting request < limits allows some over-subscription of resources as long as there is spare capacity. This is part of the intelligence built into the Kubernetes scheduler.

![Requests and Limits](img/container-resource-1.png)

Below is an example of a pod configuration file with requests and limits set for CPU and memory of two containers in a pod. CPU values are specified in “millicpu” and memory in MiB.

```yaml
kind: Pod
metadata:
  name: java-resource-tester-pod
spec:
  containers:
  - name: java-resource-tester
    image: sunnyvale/resource-tester:1.0
    resources:
      requests:
        memory: "60Mi"
        cpu: "500m"
      limits:
        memory: "128Mi"
        cpu: "500m"
```

This Pod start a container based on the Docker image sunnyvale/resource-tester:1.0. As the container's entrypoint, a Java class is run with the pourpose to display how many CPU's and GB of RAM the Java process perceives.

```java
...
public static void main(String[] args) {
        Runtime rt = Runtime.getRuntime();
        Vector v = new Vector();

        while (rt.freeMemory() > 5210000) {
            byte b[] = new byte[1024000];
            v.add(b);
            rt = Runtime.getRuntime();
            System.out.println("Used memory: " + (Runtime.getRuntime().totalMemory() - Runtime.getRuntime().freeMemory()) / 1024 / 1024 + " MB");
        }

        System.out.println("Max Processors: " + Runtime.getRuntime().availableProcessors());
        System.out.println("Max Memory: " + Runtime.getRuntime().maxMemory() / 1024 / 1024);
    }
...
```
Saying that, a Kubernetes node should have been provisioned with 1 CPU and 1024 MB of RAM, let's apply this Pod configuration and see the output with request and limits as configured in the YAML file.

```console
$ kubectcl apply -f java-pod.yaml
pod/java-resource-tester-pod created
```

```console
$ kubectl logs pod/java-resource-tester-pod 
...
Max Processors: 1
Max Memory: 61
```

**Max Processors** was 1 because the JDK round 0.5 to the next integer number. The Javadoc says about Runtime.availableProcessors() method that: returns the maximum number of processors available to the virtual machine; **never smaller than one**.

**Max Memory** was 61 as the memory request we made on the Pod's container specification.

Now, in the Pod specification yaml, uncomment the environment variable JAVA_OPTS (which in turns allocates 128m of Java Heap). 

```yaml
...
    env:
      - name: JAVA_OPTS
        value: "-Xms128m"
...
```

Then, destroy and recreate the Pod (modifications about env variables are not allowed)

```console
$ kubectl delete -f java-pod.yaml
pod "java-resource-tester-pod" deleted
```


```console
$ kubectl apply -f java-pod.yaml
pod/java-resource-tester-pod created
```


```console
$ kubectl logs pod/java-resource-tester-pod  
...
Max Processors: 1
Max Memory: 123
```

**Max Memory** was 123, close to 128, as the memory limit we made on the Pod's container specification.

The last example will make you test to allocate more Java heap than the memory the cointainer is allowed to consume.

```yaml
...
    env:
      - name: JAVA_OPTS
        value: "-Xms512m"
...
```

```console
$ kubectl delete -f java-pod.yaml
pod "java-resource-tester-pod" deleted
```


```console
$ kubectl apply -f java-pod.yaml
pod/java-resource-tester-pod created
```


```console
$ kubectl logs pod/java-resource-tester-pod   
...
Used memory: 94 MB
Used memory: 95 MB
Used memory: 96 MB
Used memory: 97 MB
Used memory: 98 MB
Killed
```

```console
$ kubectl get po                                                           
NAME                       READY   STATUS             RESTARTS   AGE
java-resource-tester-pod   0/1     CrashLoopBackOff   3          102s
```

Kubernetes killed the Pod since is trying to allocate (and use) more than 128Mi.

After 3 restart, the Pod is marked as **CrashLoopBackOff**.