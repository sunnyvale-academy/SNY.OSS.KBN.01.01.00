# Kubernetes multi-node cluster with Vagrant + Virtualbox + Kubeadm

Virtualbox + Vagrant + kubectl have to be installed on the host maschine as a prerequisite (see [00-Prerequisites](../00-Prerequisites/README.md))

All the istructions here after have to be run on the host machine.

Install vagrant plugins
```
$ vagrant plugin install vagrant-vbguest
$ vagrant plugin install vagrant-reload
$ vagrant plugin install vagrant-hostmanager
```
Provision the environent

```
$ cd vagrant
vagrant$ vagrant up
```

Test the environment

```
vagrant$ export KUBECONFIG=kubeconfig.yaml
vagrant$ kubectl get nodes

NAME     STATUS   ROLES    AGE   VERSION
master   Ready    master   18h   v1.15.3
node1    Ready    <none>   17h   v1.15.3
node2    Ready    <none>   17h   v1.15.3
```
