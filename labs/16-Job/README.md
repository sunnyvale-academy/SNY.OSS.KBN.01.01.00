# Job
Before using **kubectl**, please set the **KUBECONFIG** environment variable to point to the right kubeconfig file.

```console
$ export KUBECONFIG=../02-Multi-node_cluster/vagrant/kubeconfig.yaml
```

A job in Kubernetes is a supervisor for pods carrying out batch processes, that is, a process that runs for a certain time to completion, for example a calculation or a backup operation.

Let’s create a job called countdown that supervises a pod counting from 9 down to 1:

```console
$ kubectl apply -f job.yaml
job.batch/countdown created
```

You can see the job and the pod  like so:

```console
$ kubectl get jobs
NAME        COMPLETIONS   DURATION   AGE
countdown   1/1           2s         2s
```


```console
$ kubectl get pods
NAME              READY   STATUS      RESTARTS   AGE
countdown-xjmhc   0/1     Completed   0          75s
```

To learn more about the status of the job, do:

```console
$ kubectl describe jobs/countdown
Name:           countdown
Namespace:      default
Selector:       controller-uid=18e1ee54-13b3-42ba-b561-42ab030d64bf
Labels:         controller-uid=18e1ee54-13b3-42ba-b561-42ab030d64bf
                job-name=countdown
Annotations:    kubectl.kubernetes.io/last-applied-configuration:
                  {"apiVersion":"batch/v1","kind":"Job","metadata":{"annotations":{},"name":"countdown","namespace":"default"},"spec":{"template":{"metadata...
Parallelism:    1
Completions:    1
Start Time:     Tue, 24 Sep 2019 17:17:25 +0200
Completed At:   Tue, 24 Sep 2019 17:17:27 +0200
Duration:       2s
Pods Statuses:  0 Running / 1 Succeeded / 0 Failed
Pod Template:
  Labels:  controller-uid=18e1ee54-13b3-42ba-b561-42ab030d64bf
           job-name=countdown
  Containers:
   counter:
    Image:      centos:7
    Port:       <none>
    Host Port:  <none>
    Command:
      bin/bash
      -c
      for i in 9 8 7 6 5 4 3 2 1 ; do echo $i ; done
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Events:
  Type    Reason            Age    From            Message
  ----    ------            ----   ----            -------
  Normal  SuccessfulCreate  2m51s  job-controller  Created pod: countdown-xjmhc
```

And to see the output of the job via the pod it supervised, execute:

```console
$ kubectl logs countdown-xjmhc
9
8
7
6
5
4
3
2
1
```

To clean up, use the delete verb on the job object which will remove all the supervised pods:

```console
$ kubectl delete jobs/countdown
job.batch "countdown" deleted
```

