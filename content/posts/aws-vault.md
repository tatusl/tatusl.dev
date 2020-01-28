---
title: "Protecting AWS access keys with AWS Vault"
date: 2020-01-25T22:22:43+02:00
tags: ["aws", "security"]
draft: false
---

> AWS Vault is a tool to securely store and access AWS credentials in a development environment.

https://github.com/99designs/aws-vault

In software development, local development environment can be considered as one of the attack vectors. In this context, malicious script or malware could steal AWS access keys, or someone could get them if workstation is left unlocked. AWS Vault helps to mitigate this risk by encrypting access keys and only exposing short-lived temporary keys to local environment.

Instead of storing AWS IAM credentials to `~/.aws/credentials` in clear-text, credentials are stored to operatings system's secure key store. For example, to Keychain in macOS. AWS Vault also supports other backends, so it works on all major operating systems.

After the "main" IAM access keys are stored to secure key store, AWS Vault exposes short-lived temporary access keys for shell and other process using AWS's Security Token Service (STS) `GetSessionToken` or `AssumeRole` API calls. As the temporary keys are soon expired, consequences of leaking keys are less severe.

Installation and basic configuration is rather straight-forward process by following the instructions in the GitHub repo. Main motivation for writing this post is that at least for me it took sometime get the the configuration right with MFA enabled roles. Furthermore, in my opinion integration with aws-cli using credential process makes day-to-day use easier for example with Terraform.

## Handling MFA in multi-account model

```
# $HOME/.aws/config

[profile central-iam]
region = $AWS_REGION
mfa_serial = arn:aws:iam::$ACCOUNT_ID:mfa/$YOUR_EMAIL
credential_process = aws-vault exec central-iam --duration=1h --json --prompt=osascript

[profile assume-role-account-dev]
region=$AWS_REGION
role_arn = arn:aws:iam::$ACCOUNT_ID:role/$ROLE_NAME
role_session_name = $YOUR_EMAIL
source_profile = central-iam
```

## Integration to aws-cli with credential_process

## Configuring macOS Keychain lock timeout

## Conclusion
