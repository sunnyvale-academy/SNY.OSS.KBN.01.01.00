# ConfigMap

Before using **kubectl**, please set the **KUBECONFIG** environment variable to point to the right kubeconfig file.

```console
$ export KUBECONFIG=../02-Multi-node_cluster/vagrant/kubeconfig.yaml
```

## How does a ConfigMap work?

![ConfigMap](img/configmap-diagram.gif)

A ConfigMap is a dictionary of key-value pairs that store configuration settings for your applications.

First, create a ConfigMap in your cluster by tweaking our sample YAML to your needs.

Second, consume to ConfigMap in your Pods and use its values.

The ConfigMap described in **nginx-cm.yaml** bring two key/value entry, the first **nginx.conf** will be used within a Nginx container to configure the webserver, the second **virtualhost.conf** will be used to configure a Virtualhost within the same Nginx container.

To understand better how ConfigMaps are declared, please have a look of [nginx-cm.yaml](nginx-cm.yaml) file.

Let's create the CM

```console
$ kubectl apply -f nginx-cm.yaml
configmap/nginx-conf created
```

With the following instructions, the Nginx container uses the CM key/value entries to configure Nginx webserver:

```yaml
...
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
        volumeMounts:
        - mountPath: /etc/nginx # mount nginx-conf volume to /etc/nginx
          readOnly: true
          name: nginx-conf
        - mountPath: /var/log/nginx
          name: log
      volumes:
      - name: nginx-conf
        configMap:
          name: nginx-conf # place ConfigMap `nginx-conf` on /etc/nginx
          items:
            - key: nginx.conf
              path: nginx.conf
            - key: virtualhost.conf
              path: virtualhost/virtualhost.conf # dig directory
      - name: log
        emptyDir: {}
...
```

Let's create the Nginx Pod

```console
$ kubectl apply -f nginx-deployment.yaml
deployment.apps/nginx created
```

Verify that the Pod is running

```console
$ kubectl get po 
NAME                     READY   STATUS    RESTARTS   AGE
nginx-5496c46599-k5wzd   1/1     Running   0          21s
```

The Nginx container has been configured (through the ConfigMap) to proxy requests to [http://www.sunnyvale.it](http://www.sunnyvale.it) website.

To test our Nginx configuration let's create a NodePort service

```console
$ kubectl apply -f nginx-service.yaml 
service/nginx created
```

If everything has been configured properly, if you point your browser to [http://192.168.26.11:31719](http://192.168.26.11:31719) you should be redirected to [http://www.sunnyvale.it](http://www.sunnyvale.it) website.

To remove everything you created earlier:

```console
$ kubectl delete -f .
configmap "nginx-conf" deleted
deployment.apps "nginx" deleted
service "nginx" deleted
```
