# Operator framework

## Prerequisites

Before using **kubectl**, please set the **KUBECONFIG** environment variable to point to the right kubeconfig file.

```console
$ export KUBECONFIG=../02-Multi-node_cluster/vagrant/kubeconfig.yaml
```

## CRs, CRDs and Operators

A custom resource (CR) is an extension of the Kubernetes API that is not necessarily available in a default Kubernetes installation. It represents a customization of a particular Kubernetes installation

A Kubernetes Operator is an abstraction for deploying non-trivial applications on Kubernetes. It wraps the logic for deploying and operating an application using Kubernetes constructs. As an example, the Kafka operator provides a Kafka cluster as a first-class object.

Custom resource definitions (CRDs) extend the Kubernetes API, providing definitions to create and modify custom resources to a Kubernetes cluster. Custom resources are created as instances of CRDs.

CRDs require a one-time installation in a cluster. Depending on the cluster setup, installation typically requires cluster admin privileges.

CRDs and custom resources are defined as YAML files.

A CRD defines a new kind of resource, such as **kind: Kafka**, within a Kubernetes cluster.

Operators are implemented as a collection of controllers where each controller watches a specific resource type. When a relevant event occurs on a watched resource a reconcile cycle is started.

During the reconcile cycle, the controller has the responsibility to check that current state matches the desired state described by the watched resource.

## Using an operator for running Kafka on K8S

Install the auxiliary Operator Lifecycle Manager (OLM), a tool to help manage the Operators running on your cluster.

```console
$ curl -sL https://github.com/operator-framework/operator-lifecycle-manager/releases/download/0.13.0/install.sh | bash -s 0.13.0
customresourcedefinition.apiextensions.k8s.io/clusterserviceversions.operators.coreos.com created
customresourcedefinition.apiextensions.k8s.io/installplans.operators.coreos.com created
customresourcedefinition.apiextensions.k8s.io/subscriptions.operators.coreos.com created
customresourcedefinition.apiextensions.k8s.io/catalogsources.operators.coreos.com created
customresourcedefinition.apiextensions.k8s.io/operatorgroups.operators.coreos.com created
namespace/olm created
namespace/operators created
clusterrole.rbac.authorization.k8s.io/system:controller:operator-lifecycle-manager created
serviceaccount/olm-operator-serviceaccount created
clusterrolebinding.rbac.authorization.k8s.io/olm-operator-binding-olm created
deployment.apps/olm-operator created
deployment.apps/catalog-operator created
clusterrole.rbac.authorization.k8s.io/aggregate-olm-edit created
clusterrole.rbac.authorization.k8s.io/aggregate-olm-view created
operatorgroup.operators.coreos.com/global-operators created
operatorgroup.operators.coreos.com/olm-operators created
clusterserviceversion.operators.coreos.com/packageserver created
catalogsource.operators.coreos.com/operatorhubio-catalog created
Waiting for deployment "olm-operator" rollout to finish: 0 of 1 updated replicas are available...
deployment "olm-operator" successfully rolled out
deployment "catalog-operator" successfully rolled out
Package server phase: Installing
Package server phase: Succeeded
deployment "packageserver" successfully rolled out
```

Next, install the Strimzi Kafka operator

```console
$ kubectl create -f https://operatorhub.io/install/strimzi-kafka-operator.yaml
subscription.operators.coreos.com/my-strimzi-kafka-operator created
```

To check if the operator has been installed successfully, wait until the PHASE changes into 'Succeeded' (it may take a while).


```console
$ kubectl get csv -n operators  
NAME                               DISPLAY                         VERSION   REPLACES                           PHASE
strimzi-cluster-operator.v0.14.0   Strimzi Apache Kafka Operator   0.14.0    strimzi-cluster-operator.v0.13.0   Succeeded
```

One or more CRD/s should have been created by the operator 

```console
$ kubectl get crd
NAME                                          CREATED AT
...
kafkabridges.kafka.strimzi.io                 2020-01-16T22:50:13Z
kafkaconnects.kafka.strimzi.io                2020-01-16T22:50:13Z
kafkaconnects2is.kafka.strimzi.io             2020-01-16T22:50:13Z
kafkamirrormakers.kafka.strimzi.io            2020-01-16T22:50:13Z
kafkas.kafka.strimzi.io                       2020-01-16T22:50:13Z
kafkatopics.kafka.strimzi.io                  2020-01-16T22:50:14Z
kafkausers.kafka.strimzi.io                   2020-01-16T22:50:14Z
...
```

If you want to inspect the CRD **kafkas.kafka.strimzi.io**:

```console
$ kubectl get crd kafkas.kafka.strimzi.io -o yaml | more 
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  creationTimestamp: "2020-01-16T22:50:13Z"
  generation: 1
  labels:
    app: strimzi
  name: kafkas.kafka.strimzi.io
  resourceVersion: "209301"
  selfLink: /apis/apiextensions.k8s.io/v1beta1/customresourcedefinitions/kafkas.kafka.strimzi.io
  uid: 95cf529d-ba41-45f3-a71c-5606c34ab3e9
spec:
  additionalPrinterColumns:
  - JSONPath: .spec.kafka.replicas
    description: The desired number of Kafka replicas in the cluster
    name: Desired Kafka replicas
    type: integer
  - JSONPath: .spec.zookeeper.replicas
    description: The desired number of Zookeeper replicas in the cluster
    name: Desired ZK replicas
    type: integer
  conversion:
    strategy: None
  group: kafka.strimzi.io
  names:
    kind: Kafka
    listKind: KafkaList
    plural: kafkas
    shortNames:
    - k
    singular: kafka
  preserveUnknownFields: true
  scope: Namespaced
  subresources:
:
```

Now, we are going to implement the following architecture:

![Kafka Operator](img/cluster-operator.png)

To test the operator, we are ready to create a **Kafka** resource, note the `kind: Kafka`

```yaml
apiVersion: kafka.strimzi.io/v1beta1
kind: Kafka
metadata:
  name: my-kafka-cluster-with-operator
spec:
  kafka:
    version: 2.3.0
    replicas: 3
    ...
```

```console
$ kubectl apply -f kafka-cluster.yaml 
kafka.kafka.strimzi.io/my-kafka-cluster-with-operator created
```

Note that since we installed the operator and its CRDs successfully, we can **get kafka** cluster using kubectl tool

```console
$ kubectl get kafka
NAME                             DESIRED KAFKA REPLICAS   DESIRED ZK REPLICAS
my-kafka-cluster-with-operator   3                        3
```

You can delete the cluster now:

```console
$ kubectl delete kafka my-kafka-cluster-with-operator                 
kafka.kafka.strimzi.io "my-kafka-cluster-with-operator" deleted
```