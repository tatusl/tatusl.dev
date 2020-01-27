---
title: "Protecting AWS access keys with AWS Vault"
date: 2020-01-25T22:22:43+02:00
draft: false
---

> AWS Vault is a tool to securely store and access AWS credentials in a development environment.

https://github.com/99designs/aws-vault

Instead of storing AWS IAM credentials to `~/.aws/credentials` in clear-text, credentials are stored to operatings system's secure key store. For example, to Keychain in macOS. AWS Vault also supports other backends, so it works on all major operating systems.

After the "main" IAM access keys are stored to secure key store, AWS Vault exposes short-lived temporary access keys for shell and other process using AWS's Security Token Service (STS) `GetSessionToken` or `AssumeRole` API calls. As the temporary keys are soon expired, consequences of leaking keys are less severe.

**Chapter about how this reduces the attack vector in local development environment** 

## Handling MFA in multi-account model

## Integration to aws-cli with credential_process

## Configuring macOS Keychain lock timeout

## Conclusion
