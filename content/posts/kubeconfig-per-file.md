---
title: "Load Kubernetes configs from different files"
date: 2020-04-27T08:45:43+03:00
tags: ["kubernetes", "kubectl"]
draft: false
---

By default, Kubernetes stores kube config files to `$HOME/.kube/config`. If there are configurations for multiple clusters, all of them are stored in the same file. I find this rather unclear, as a configuration set consists of cluster, user, and context, which are defined in different parts of the file. `kubectl config` subcommands can be used to manipulate this file and to list configured contexts on clusters.

Another approach to configuration management is to use `KUBECONFIG` environment variable. It can be used to point kubectl to use a non-default configuration file, so one could have multiple configuration files and switch between them by exporting `KUBECONFIG` to point to the correct file. However, with this approach a user can't use the awesome [kubectx](https://github.com/ahmetb/kubectx) tool to quickly switch between contexts.

## Appending multiple files to KUBECONFIG environment variable

`KUBECONFIG` environment variable can point to multiple files by separating file paths with a colon (`:`). In my kube config management approach, each cluster has its own config file in `$HOME/kube/.config.d`. These file paths are then appended to `KUBECONFIG` environment variable at shell startup. Additionally, I have wrapped this to zsh function, so I can load kube configs only on-demand. Zsh functions can be stored to for example `$HOME/.zshrc`:

```
loadkubeconfig() {
    kubeconfig=""

    for kubecfg in "$HOME/.kube/config.d/"*; do
       kubeconfig+=$kubecfg:
    done

    export KUBECONFIG=$kubeconfig
}
```

Luckily `kubectl` does not care about the trailing colon, so things can be kept simple. With this, I can easily switch contexts with `kubectx` and have configuration for different clusters in their own files.

## Other stuff to make my life easier with kubectl

In addition to loading kube configs, I created a function for unloading them. This simply unsets the `KUBECONFIG` environment variable:

```
unloadkubeconfig() {
    unset KUBECONFIG
}
```

Both of the function names are rather long, so I aliased them in the following manner. Like zsh functions, aliases can be stored to `$HOME/.zshrc`:

```
alias lkc='loadkubeconfig'
alias ukc='unloadkubeconfig'
```

## Conclusion

This post demonstrated how kube configs from multiple files can be loaded at the same time to use tools like `kubectx`. Besides, having a config file per cluster makes managing configurations simpler in my opinion. Want to get rid of configuration for certain cluster? Just delete one file. Want to add a new cluster? Just append the config to a new file.
