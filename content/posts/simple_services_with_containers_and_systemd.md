+++
date = '2025-05-02T12:38:41Z'
draft = false
title = 'Simple container hosting setup with SystemD'
+++

I wanted to self-host certain small services like RSS reader [Miniflux](https://miniflux.app/). I had the following for requirements for hosting setup:

* Services should run in containers
* Ingress service, which routes requests for correct containers and manages SSL certificates from Let's Encrypt
* Declarative configuration
* Whole setup should be easy to maintain

First I thought about setting up a hobby Kubernetes cluster to Hetzner Cloud. This would have been interesting project from learning perspective. However, I only had one service I really wanted to host at this point and setting up a whole Kubernetes cluster with its associated services felt a bit overkill for my goal. In addition, monthly costs would be something like 20 euros per month.

I already had small VPS from Hetzner Cloud for running my IRC client. Resources of the server were heavily under utilized, so I thought why I wouldn't use something I already own.
