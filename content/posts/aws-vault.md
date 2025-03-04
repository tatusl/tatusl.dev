---
title: "Protecting AWS access keys with AWS Vault"
date: 2020-02-10T19:22:43+02:00
tags: ["aws", "security"]
draft: false
---

> AWS Vault is a tool to securely store and access AWS credentials in a development environment.

https://github.com/99designs/aws-vault

In software development, local development environment can be considered as one of the attack vectors. In this context, malicious script or malware could steal AWS access keys, or someone could get them if developer's workstation is left unlocked. AWS Vault helps to mitigate this risk by encrypting access keys and exposing short-lived temporary keys to local environment.

Instead of storing AWS IAM credentials to `~/.aws/credentials` in clear-text, credentials are stored to operating system's secure key store. For example, to Keychain in macOS. AWS Vault also supports other backends, so it works on all major operating systems.

After the "main" IAM access keys are stored to secure key store, AWS Vault exposes short-lived temporary access keys for shell and other process using AWS's Security Token Service (STS) `GetSessionToken` or `AssumeRole` API calls. As the temporary keys are soon expired, consequences of leaking keys are less severe.

Installation and basic configuration is rather straight-forward process by following the instructions on the GitHub repository. Main motivation for writing this post is that at least for me it took sometime to get the configuration right with MFA enabled roles. Furthermore, in my opinion integration with aws-cli using credential process makes day-to-day usage easier for example with Terraform.

## Integration with aws-cli using credential_process

AWS Vault can be seamlessly integrated with aws-cli using `credential_process` attribute for `aws-cli`. This means that AWS Vault provides AWS access keys for aws-cli in json format. See example configuration below:

```shell
[profile example]
region=eu-west-1
credential_process=aws-vault exec example --json --prompt=osascript
output=json
```

With the example configuration, there is no need run `aws-vault exec` separately, but aws-cli can be used similarly than without AWS Vault.

More information about credential_process can be found from [AWS documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sourcing-external.html)

## Handling MFA in multi-account model

When working with accounts which have MFA enabled for AWS API, AWS Vault asks for new TOTP token when it needs be refreshed. `--prompt` attribute for `aws-vault exec` decides which UI technology is responsible for displaying the TOTP token prompt. Possible values are `osascript`, `zenity` and `terminal`.

`mfa_serial` needs to be defined only for IAM login account. It can be omitted for accounts, which are accessed by assuming a role. Example configuration can be found below:

```shell
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

With the example configuration, each AWS profile can be used by exporting the `AWS_PROFILE` environment variable and passing a desired profile name as value. There are multiple tools which make switching between profiles easier, I use [aws plugin for zsh](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/aws)

## Configuring macOS Keychain lock timeout

macOS locks specific keychain in 15 minutes by default. This can be changed by opening Keychain Access, right-clicking the keychain created for aws-vault, selecting "Change Settings for Keychain", and then changing the value of "Lock after" field. Deciding value for settings like this is always balancing between usability and security.

## Conclusion

This post described how AWS Vault can be used to enhance local development environment security by storing AWS access keys to secure backend and exposing short-lived temporary credentials for processes. In my opinion, AWS Vault is a very handy tool for managing AWS access keys and making MFA API access easier. I recommend it for every professional who works with AWS.
