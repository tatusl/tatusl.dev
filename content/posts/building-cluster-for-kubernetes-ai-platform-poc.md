+++
date = '2026-10-13T07:42:20Z'
draft = false
title = 'Kubernetes AI Platform PoC on UpCloud: Building the cluster'
+++

## Introduction

I've been between client projects at work, so I had spare time on my hands to learn something new. As we all know, AI has fundamentally reshaped how the IT industry works, so learning skills related to it feels important to stay relevant in the field. I really like building platforms and I was interested how publicly available open-weights LLM models are run on Kubernetes. So, I set myself a goal: build a simplified proof-of-concept for easily deployable Kubernetes cluster for running and serving AI models. At the same time, the project would show me what kinds of software components a setup like this needs, and how each of them is configured.

I wanted to build this on public cloud, because it gets at least somewhat close to how this would be built and run in production. Running decent-sized AI models at acceptable performance requires GPU capacity, so the selected cloud platform should provide GPU instances. I picked UpCloud for three reasons: they offer GPU instances, I'd been curious about them because of the recent sovereign cloud discussion, and my employer had credits on the platform. UpCloud would've also had managed Kubernetes product, but I chose to build the cluster with [Talos Linux](https://www.siderolabs.com/talos-linux), which is a immutable, minimal, and API-driven Linux distribution for running Kubernetes. Choosing Talos keeps the setup reasonably portable across cloud providers and on-premises environments too.

This post describes how I built the Infrastructure as Code defined and easily deployable cluster to UpCloud using Packer, Terraform, Talos Linux, and FluxCD. It also tries to explain the architectural choices made and the reasons for them. A follow-up post will then go through the chosen LLM stack on top of Kubernetes, which keeps both posts at a reasonable length. Everything described here lives on [GitHub](https://github.com/tatusl-polarsquad/kubernetes-ai-platform-poc).

## Building the Talos Linux VM images using Packer

UpCloud doesn't have ready-made VM image for Talos Linux, so that had to be built first. I've used Packer before on different platforms and it has an [UpCloud integration](https://developer.hashicorp.com/packer/integrations/UpCloudLtd/upcloud), so it felt like the obvious choice for building the image. Author of Talos Linux Sidero Labs provide ready-made Packer template in [their documentation](https://docs.siderolabs.com/talos/v1.14/platform-specific-installations/cloud-platforms/upcloud) and I tried to follow their documentation, but I couldn't get the template to work. I suspect the reason for it was the way how the builder VM tried to write the Talos Linux image to the block storage device while it's own operating system was still running from that same block storage device.

I checked the documentation of the Packer integration and noticed that it has [UpCloud Import post-processor](https://developer.hashicorp.com/packer/integrations/UpCloudLtd/upcloud/latest/components/post-processor/upcloud-import) which is used to import raw disk images as private templates to UpCloud. Talos Linux [Image Factory](https://factory.talos.dev/) can be used to customize Talos Linux images and one of format it provides a disk image as is a raw disk image, so produced images can used directly used with the UpCloud Import post-processor of Packer. 

I used Nvidia GPU instances, so the Talos Linux node needs to have Nvidia drivers installed. However, the plain nodes don't need the drivers, so I built an image with and without the them. See [the Packer template](https://github.com/tatusl-polarsquad/kubernetes-ai-platform-poc/blob/main/packer/talos_on_upcloud.pkr.hcl) for the details.

## Architectural choices

### GitOps

I wanted everything related to configuration of the cluster and its software components to be defined as code. In addition, I also wanted cluster to be easily deployable. To achieve this, I selected FluxCD as the GitOps controller, because it feels a bit more lightweight compared to ArgoCD. The most typical way to bootsrap FluxCD after provisiong a cluster is to run [`flux bootstrap/`](https://fluxcd.io/flux/cmd/flux_bootstrap). I wanted to automate that, so instead I chose to bootstrap FluxCD directly from Terraform using Talos [inlineManifests and extraManifests](https://docs.siderolabs.com/kubernetes-guides/advanced-guides/inlinemanifests). They are Talos machine configuration fields, which can be used to apply Kubernetes resources to a cluster during Talos bootstrap. However, they are applied once during cluster bootstrap, so they can't be used to for example update FluxCD version. I wanted to be able to update FluxCD version during runtime, so I made FluxCD adopt and reconcialiate a state of itself.

### Networking

Even though this is a proof-of-concept solution, I wanted the network architecture to resemble one of a production. Thus, I placed cluster nodes to private subnet behind a load balancer, so that they are not directly reachable from the public network. As on most cloud platforms, resources in private subnets don't have route to public network. To provide routing to public networks, UpCloud has a [NAT Gateway](https://upcloud.com/docs/products/nat-gateway/) component. The diagram below describes the network architecture and its components.

![infrastructure.svg](/images/infrastructure.svg)

Having cluster nodes in a private subnet meant that I would need some other mechanism for running "Talos machine config apply" than over network. TBC

### Cloud platform integration

- FluxCD for GitOps
  - bootstrapped from Talos inline manifest and self-adopted 
  - CCM had to be boostrapped to get rid off the node taints 
- Private network nodes
  - UpCloud NAT instance
  - Load Balancer for the Kube / Talos API access
  - CCM / CSI
  - LB for public services (LiteLLM Proxy) provisioned by the CCM 
  - Talos machine config had to be done from cloud-init to prevent port mapping LB to cluster nodes
      - cluster cert keys in the, had to block metadata endpoint with Cilium, so had to install Cilium 

## Deploying the cluster with Terraform
