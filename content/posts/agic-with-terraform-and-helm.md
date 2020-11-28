---
title: "Deploying Azure Application Gateway Ingress Controller with Terraform and Helm"
date: 2020-11-28T11:41:00+02:00
tags: ["azure", "kubernetes"]
draft: false
---

## Why Terraform and Helm

* list reasons why to do this
* Create a nice deployment package with infra and the controller
* Cannot provision AppGw from the controller like in aws-alb-contoller
* Terraform provides a way to declaratively define Helm chart deployment* Terraform provides a way to declaratively define Helm chart deploymentss
* It seems that AGIC is only released as Helm chart

## Provisioning needed infrastructure and the ingress controller

* User assigned identity
* Role assignments
* Application Gateway
* Public IP for Application Gateway

## Testing the deployment

Deploy and test
