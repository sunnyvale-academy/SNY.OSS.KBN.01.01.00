# Pods

Before using **kubectl**, please set the **KUBECONFIG** environment variable to point to the right kubeconfig file.

```
$ export KUBECONFIG=../02-Multi-node_cluster/vagrant/kubeconfig.yaml
```

## Single container Pod

```
$ kubectl apply -f single-container_pod.yaml
```

Get the Pod status

```
$ kubectl get pods
NAME        READY   STATUS    RESTARTS   AGE           
myapp-pod   1/1     Running   0          16s
```

Discover where the Pod has been scheduled
```
$ kubectl get pod myapp-pod -o wide
NAME        READY   STATUS    RESTARTS   AGE     IP           NODE    NOMINATED NODE   READINESS GATES
myapp-pod   1/1     Running   0          3m30s   10.244.2.4   node2   <none>           <none>
```

Get the Pod's container logs
```
$ kubectl logs myapp-pod 
Hello Kubernetes!
```

Cleanup!

```
$ kubectl delete -f single-container_pod.yaml
pod "myapp-pod" deleted
```



## Two containers Pod

Create the Pod
```
$ kubectl apply -f two-containers_pod.yaml
pod/mc1 created
```

Try to get the Pod status
```
$ kubectl get pods
NAME   READY   STATUS              RESTARTS   AGE
mc1    0/2     ContainerCreating   0          114s
```

If you repeat the command after a while

```
$ kubectl get pods
NAME   READY   STATUS    RESTARTS   AGE
mc1    2/2     Running   0          3m30s
```

Get the Pod configuration in YAML format

```
$ kubectl get pod mc1 -o yaml
apiVersion: v1
kind: Pod
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","kind":"Pod","metadata":{"annotations":{},"name":"mc1","namespace":"default"},"spec":{"containers":[{"image":"nginx","name":"first","volumeMounts":[{"mountPath":"/usr/share/nginx/html","name":"html"}]},{"args":["while true; do date \u003e\u003e /html/index.html; sleep 1; done"],"command":["/bin/sh","-c"],"image":"debian","name":"second","volumeMounts":[{"mountPath":"/html","name":"html"}]}],"volumes":[{"emptyDir":{},"name":"html"}]}}
  creationTimestamp: "2019-09-11T20:39:22Z"
  name: mc1
  namespace: default
  resourceVersion: "3430"
  selfLink: /api/v1/namespaces/default/pods/mc1
  uid: 335352a0-83e0-42f4-a328-8d0aa2e49ebd
spec:
  containers:
  - image: nginx
    imagePullPolicy: Always
    name: first
    resources: {}
    terminationMessagePath: /dev/termination-log
    terminationMessagePolicy: File
    volumeMounts:
    - mountPath: /usr/share/nginx/html
      name: html
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: default-token-pscqc
      readOnly: true
  - args:
    - while true; do date >> /html/index.html; sleep 1; done
    command:
    - /bin/sh
    - -c
    image: debian
    imagePullPolicy: Always
    name: second
    resources: {}
    terminationMessagePath: /dev/termination-log
    terminationMessagePolicy: File
    volumeMounts:
    - mountPath: /html
      name: html
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: default-token-pscqc
      readOnly: true
  dnsPolicy: ClusterFirst
  enableServiceLinks: true
  nodeName: node1
  priority: 0
  restartPolicy: Always
  schedulerName: default-scheduler
  securityContext: {}
  serviceAccount: default
  serviceAccountName: default
  terminationGracePeriodSeconds: 30
  tolerations:
  ...
```

Cleanup!

```
$ kubectl delete -f two-containers_pod.yaml
pod "mc1" deleted
```

## Resource constrained Pod

Inspect the YAML file
```
$ cat resources-constrained_pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: frontend
spec:
  containers:
  - name: db
    image: mysql
    env:
    - name: MYSQL_ROOT_PASSWORD
      value: "password"
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
  - name: wp
    image: wordpress
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
```

Apply the YAML file

```
$ kubectl apply -f resources-constrained_pod.yaml
pod/frontend created
```

```
$ kubectl get pods
NAME       READY   STATUS    RESTARTS   AGE
frontend   2/2     Running   0          44s
```

```
$ kubectl get pod frontend -o wide
NAME       READY   STATUS    RESTARTS   AGE   IP           NODE    NOMINATED NODE   READINESS GATES
frontend   2/2     Running   0          9m    10.244.1.7   node1   <none>           <none>
```

```
$ kubectl delete -f resources-constrained_pod.yaml
pod "frontend" deleted
```

