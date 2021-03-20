---
title: "Deploy Azure Application Gateway Ingress Controller with Terraform and Helm"
date: 2020-11-28T11:41:00+02:00
tags: ["azure", "kubernetes"]
draft: false
---

I have been creating Azure infrastructure for the past six months in my work current project. Backend services are run in Azure Kubernetes Service (AKS) and we needed an ingress controller for receiving traffic outside of the cluster. I have used alb-ingress-controller (now AWS Load Balancer Controller) in AWS and I wanted the same functionality in Azure.

[Application Gateway Ingress Controller](https://github.com/Azure/application-gateway-kubernetes-ingress) (AGIC) from Microsoft seemed to provide that functionality with Azure Application Gateway in-front of the AKS cluster. However, as opposed to AWS Load Balancer Controller, deployment of AGIC does not provision an Application Gateway automatically. Therefore, an user needs to provision an Application Gateway and then configure AGIC accordingly.

This post goes through how to package AGIC, Application Gateway, and related resources to a single Terraform module to make deployment and configuration as effortless as possible. In addition, this post talks about why packaging cluster add-on software and related infrastructure to a Terraform module is a valid choice.

As of March 2021, [App Gateway ingress controller add-on for AKS](https://azure.microsoft.com/en-us/updates/general-availability-app-gateway-ingress-controller-addon-for-aks/) is in GA. This will automate deployment of AGIC even further, as Azure takes care of provisioning and configuration of AGIC and Application Gateway. **This will also probably make this blog post obsolete.** However, by the time of writing this post, Terraform lacks the support for this add-on. See related [issue](https://github.com/terraform-providers/terraform-provider-azurerm/issues/7384). Because of that, I see writing this post relevant and hopefully it's useful for someone. In addition, this pattern can be generalized for other cluster add-on software.

## Why Terraform and Helm?

AGIC is only released as Helm chart, so therefore using Helm is a mandatory choice. As mentioned above, an user needs to provision Application Gateway by themselves. As I want my infrastructure as code and I prefer Terraform over ARM templates, Terraform is an obvious choice for this task. I chose to wrap deployment of the Helm chart to Terraform using the [Helm provider](https://registry.terraform.io/providers/hashicorp/helm/latest/docs) of Terraform. There are couple of main reasons for this.

First is to have a declaritive way to define Helm relases applied to a cluster. Another options for this are tools like [helmfile](https://github.com/roboll/helmfile) or [helmsman](https://github.com/Praqma/helmsman). Second, and the main reason, is being able to get needed attributes from infrastructure and pass them as configuration values to AGIC deployment. Examples of these attributes are name of the Application Gateway, managed identity resource id, and managed identity client id.

Deploying both the AGIC Helm chart and related infrastructure with Terraform makes it to possible to package everything that's needed to a single Terraform module. This makes deployment effortless and more easily repeatable.

## Provisioning needed infrastructure and the ingress controller

* User assigned identity
* Role assignments
* Application Gateway
* Public IP for Application Gateway

## Testing the deployment

Deploy and test
