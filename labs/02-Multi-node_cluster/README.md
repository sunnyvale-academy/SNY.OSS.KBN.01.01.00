# Kubernetes multi-node cluster with Vagrant + Virtualbox + Kubeadm

Virtualbox + Vagrant + kubectl have to be installed on the host machine as a prerequisite (see [00-Prerequisites](../00-Prerequisites/README.md))

All the istructions here after have to be run on the host machine.

Install vagrant plugins
```console
$ vagrant plugin install vagrant-vbguest
$ vagrant plugin install vagrant-reload
$ vagrant plugin install vagrant-hostmanager
```
If you are have installed the latest versions of Vagrant (2.2.6) and VirtualBox (6.1.x) you can have compatibility problems, to avoid them you can follow this guide: 
https://blogs.oracle.com/scoter/getting-vagrant-226-working-with-virtualbox-61-ga

Provision the environent

```console
$ cd vagrant
vagrant$ vagrant up
```

Test the environment

```console
vagrant$ export KUBECONFIG=kubeconfig.yaml
vagrant$ kubectl get nodes

NAME     STATUS   ROLES    AGE   VERSION
master   Ready    master   18h   v1.15.3
node1    Ready    <none>   17h   v1.15.3
node2    Ready    <none>   17h   v1.15.3
```

Download kuberang utility [here](https://github.com/apprenda/kuberang/releases) and test the cluster

```console
vagrant$ ./kuberang

Kubectl configured on this node                                                 [OK]
Delete existing deployments if they exist                                       [OK]
Nginx service does not already exist                                            [OK]
BusyBox service does not already exist                                          [OK]
Nginx service does not already exist                                            [OK]
Issued BusyBox start request                                                    [OK]
Issued Nginx start request                                                      [OK]
Issued expose Nginx service request                                             [OK]
Both deployments completed successfully within timeout                          [OK]
Grab nginx pod ip addresses                                                     [OK]
Grab nginx service ip address                                                   [OK]
Grab BusyBox pod name                                                           [OK]
Accessed Nginx service at 10.97.93.142 from BusyBox                             [OK]
Accessed Nginx service via DNS kuberang-nginx-1568230142752374000 from BusyBox  [OK]
Accessed Nginx pod at 10.244.1.5 from BusyBox                                   [OK]
Accessed Nginx pod at 10.244.1.4 from BusyBox                                   [OK]
Accessed Nginx pod at 10.244.1.2 from BusyBox                                   [OK]
Accessed Google.com from BusyBox                                                [OK]
Accessed Nginx pod at 10.244.1.5 from this node                                 [ERROR IGNORED]
Accessed Nginx pod at 10.244.1.4 from this node                                 [ERROR IGNORED]
Accessed Nginx pod at 10.244.1.2 from this node                                 [ERROR IGNORED]
Accessed Google.com from this node                                              [OK]
Powered down Nginx service                                                      [OK]
Powered down Busybox deployment                                                 [OK]
Powered down Nginx deployment                                                   [OK]
```


You need to proxy your requests to access the Dashboard

```console
vagrant$ kubectl proxy
```

Point your browser [here](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/.)
