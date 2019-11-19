# Google Kubernetes Engine Demo

## Prerequisites

- HashiCorp Terraform v. 0.12 or greater. [Download here](https://www.terraform.io/downloads.html)   
- A valid Google Cloud Platform account (you can register for a free trial [here](https://cloud.google.com))

## GCP new project configuration

Open the GCP console [here](https://cloud.google.com) and click on **My First Project**

![GCP Console](img/gcp_1.png)

On the just openend modal window, click on NEW PROJECT

![New project](img/gcp_2.png)

Insert the new project name, then click on the CREATE button

![Insert project name](img/gcp_3.png)

## GCP new Service Account configuration

Being sure to have selected the newly created project, click on **IAM & admin > Service accounts** in the left menu

![Create a service account](img/gcp_4.png)

In the **Service account** page, click on **CREATE SERVICE ACCOUNT**

![Click on CREATE SERVICE ACCOUNT](img/gcp_5.png)

In the **Create service account** page, insert your service account name (in this case **devops**), then click on **CREATE**

![Insert your service account name](img/gcp_6.png)

In the next step of the wizard, click on **Owner** to grant the rights to our service account, then click on **CONTINUE**

![Select Owner](img/gcp_7.png)

Before exiting the wizard, create a new Key

![Create a new key](img/gcp_8.png)

Select JSON format then click **CREATE**

![Select JSON](img/gcp_8.png)

A new private key should have been downloaded on your computer, copy it into <GIT_REPO_HOME>/labs/Google_Kubernetes_Engine_Demo/terraform (the same folder where this README.md file resides).

