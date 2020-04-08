---
title: "Load kubeconfigs from different files"
date: 2020-03-09T23:44:52+02:00
tags: ["kubernetes", "kubectl"]
draft: false
---

By default, Kubernetes stores kubeconfig files to `$HOME/.kube/config`. If there are configurations for multiple clusters, all of them are stored to the same file. I find this rather unclear, as configuration set consists of cluster, user, and context, which are defined in different parts of the file. `kubectl config` subcommands can be used to manipulate this file and to list configured contexts on clusters.

Another approach to configuration management is to use `KUBECONFIG` environment variable. It can be used to point kubectl to use non-default configuration file, so one could have multiple configuration files and switch between them by exporting `KUBECONFIG` to point to correct file. However, with this approach user can't use awesome [kubectx](https://github.com/ahmetb/kubectx) tool to quickly switch between contexts.

## Appending multiple files to `KUBECONFIG` environment variable

`KUBECONFIG` environment variable can point to multiple files by separating files path with colon (`:`). In my kubeconfig management approach, each cluster has its own config file in `$HOME/kube/.config.d`. These file paths are then appended to `KUBECONFIG` environment variable at shell startup. Additionaly, I have wrapped this to zsh function, so I can load kubeconfigs only on-demand:

```
loadkubeconfig() {
    kubeconfig=""

    for kubecfg in "$HOME/.kube/config.d/"*; do
       kubeconfig+=$kubecfg:
    done

    export KUBECONFIG=$kubeconfig
}
```

Luckily `kubectl` does not care about the trailing colon, so things can be kept simple. With this, I can easily switch contexts with `kubectx` and have configuration for different cluster in their own files.

## Other stuff to make my life easier with kubectl

Unload:

```
unloadkubeconfig() {
    unset KUBECONFIG
}
```

And then the aliases..
