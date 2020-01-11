# Requests and Limits

## Prerequisites

Before using **kubectl**, please set the **KUBECONFIG** environment variable to point to the right kubeconfig file.

```console
$ export KUBECONFIG=../02-Multi-node_cluster/vagrant/kubeconfig.yaml
```

Also, **openssl** must be installed on your PC.

## RBAC theory

From Kubernetes 1.6 onwards, RBAC policies are enabled by default. 

One basic Kubernetes feature is that all its resources are modeled API objects, which allow CRUD (Create, Read, Update, Delete) operations. 
Examples of resources are:

- Pods
- PersistentVolumes
- ConfigMaps
- Deployments
- Nodes
- Secrets
- Namespaces

Examples of possible operations over these resources are:

- create
- get
- delete
- list
- update
- edit
- watch
- exec    

At a higher level, resources are associated with API Groups (for example, Pods belong to the core API group whereas Deployments belong to the apps API group). For more information about all available resources, operations, and API groups, check the [Official Kubernetes API Reference](https://kubernetes.io/docs/reference/kubernetes-api/).


To manage RBAC in Kubernetes, apart from **resources** and **operations**, we need the following elements:

- **Rules**: A rule is a set of operations (verbs) that can be carried out on a group of resources which belong to different API Groups.
- **Roles** and **ClusterRoles**: Both consist of rules. The difference between a Role and a ClusterRole is the scope: in a Role, the rules are applicable to a single namespace, whereas a ClusterRole is cluster-wide, so the rules are applicable to more than one namespace. ClusterRoles can define rules for cluster-scoped resources (such as nodes) as well. Both Roles and ClusterRoles are mapped as API Resources inside our cluster.
- **Subjects**: These correspond to the entity that attempts an operation in the cluster. There are three types of subjects:
    - **User Accounts**: These are global, and meant for humans or processes living outside the cluster. There is no associated resource API Object in the Kubernetes cluster.
    - **Service Accounts**: This kind of account is namespaced and meant for intra-cluster processes running inside pods, which want to authenticate against the API.
    - **Groups**: This is used for referring to multiple accounts. There are some groups created by default such as cluster-admin (explained in later sections).
- **RoleBindings** and **ClusterRoleBindings**: Just as the names imply, these bind subjects to roles (i.e. the operations a given user can perform). As for Roles and ClusterRoles, the difference lies in the scope: a RoleBinding will make the rules effective inside a namespace, whereas a ClusterRoleBinding will make the rules effective in all namespaces.

## Create User With Limited Namespace Access

In this example, we will create the following User Account:

Username: denis
Group: sunnyvale

We will add the necessary RBAC policies so this user can fully manage deployments (i.e. use kubectl run command) only inside the office namespace. At the end, we will test the policies to make sure they work as expected.

Execute the kubectl create command to create the namespace (as the admin user):

```console
$ kubectl create namespace office
namespace/office created
```

Create The User Credentials. 

Create a private key for your user. In this example, we will name the file employee.key

```console
$ openssl genrsa -out denis.key 2048
Generating RSA private key, 2048 bit long modulus
.............+++
...................................................................................................................................................+++
e is 65537 (0x10001)
```

Create a certificate sign request employee.csr using the private key you just created (denis.key in this example). Make sure you specify your username and group in the -subj section (CN is for the username and O for the group). As previously mentioned, we will use denis as the name and sunnyvale as the group:

```console
$ openssl req -new -key denis.key -out denis.csr -subj "/CN=denis/O=sunnyvale"
```

In the current directory you will find the  Kubernetes cluster certification authority's (CA) key and certificate, copied here by the Kubernetes installation procedure (normally they reside in /etc/kubernetes/pki/ on the master node).

Let's generate the final certificate employee.crt by approving the previously created certificate sign request.

```console
$ openssl x509 -req -in denis.csr -CA ./ca.crt -CAkey ./ca.key -CAcreateserial -out denis.crt -days 500
Signature ok
subject=/CN=denis/O=sunnyvale
Getting CA Private Key
```

Add a new context with the new credentials for your Kubernetes cluster.

```console
$ kubectl config set-credentials denis --client-certificate=./denis.crt  --client-key=./denis.key
User "denis" set.
```

```console
$ kubectl config set-context denis-context --cluster=kubernetes --namespace=office --user=denis
Context "denis-context" created.
```

Now you should get an access denied error when using the kubectl CLI with this configuration file. This is expected as we have not defined any permitted operations for this user.


```console
$ kubectl --context=denis-context get pods
Error from server (Forbidden): pods is forbidden: User "denis" cannot list resource "pods" in API group "" in the namespace "office"
```