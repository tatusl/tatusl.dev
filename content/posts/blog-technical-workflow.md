---
title: "Blog Technical Workflow"
date: 2016-03-19T13:05:23+02:00
draft: false
---

## Technical side of the blog

I could have picked some blog engine like Wordpress of Ghost, but I decided to go towards static side generators. I really like the idea that all of my content is in static files and I don't need more than a web server to host my blog. With static files, I can version control my blog and content with Git and I don't need to worry about security updates to the blog engine. Also, serving static content is very resource friendly with web server like Nginx. In fact, this blog is hosted in the cheapest RamNode VPS with 128 MB memory, costing 15$/year. That's pretty low-end server, but it should be more than enough for small-scale website like this.

## Pelican + Git + TravisCI

### Pelican

My choice for the static site generator is [Pelican](http://getpelican.com). I have done some experimentation with [Jekyll](https://jekyllrb.com/), but somehow Pelican felt simpler and I have basic skills and experience with Python which Pelican uses. In this post, I don't cover specifics about setting up or working with Pelican, because there are already good guides how to do that. If you are interested, you should check [Official Pelican Quickstart guide](http://docs.getpelican.com/en/3.6.3/quickstart.html).

There are several ready-made themes for Pelican. Most of them are listed in the [pelican-themes](https://github.com/getpelican/pelican-themes) repository. I'm using [hyde](https://github.com/jvanz/pelican-hyde) by [jvanz](https://github.com/jvanz) with some personal modifications.

With Pelican, everytime blog content is updated or changed, site generation commands need to be executed. That is the reason I wanted to come up with some automated solution for content updating. I really don't want to repeat these manual steps everytime I change or update blog content. This is when Git ([GitHub](https://github.com/) more specifically) and [Travis CI](https://travis-ci.org/) come to the picture.

### The workflow

To summarize the workflow, Pelican sources are stored to a Git repository in Github and everytime the blog content changes (that is to say, there is a push to a Git repository), Travis CI will build the sources to the static HTML files and upload these files to the webserver using rsync. I'm not going into how to use Git, there are tons of good guides online for that. I'm not going into specifics about Travis CI either.

### Setting up ssh keys for Travis CI

The trickiest part in the setup is dealing with the ssh keys in Travis CI. Ssh keys are used in order to securely upload the files to the webserver. Let's start with generating ssh keypair.

```
ssh-keygen -t rsa
```
Store the keys to a convenient place and don't add passphrases. Add the public key to the **authorized_keys** file of the web server

It's not a good idea to store the private key (which is used to login to the webserver) to a public repository. That's why the encryption of the key is needed. This can be done using Ruby gem called Travis. Install the gem:

```
gem install travis
```

In your repository folder, use command **travis login** to authenticate. Type in your Github username and password. After that, use command **travis encrypt-file your_private_key** to encrypt the file. The command will output the string you need to enter to the **.travis.yml** **before_install** section.

### Example .travis.yml configuration

Travis CI uses **.travis.yml** for deciding how to build and deploy the project. Here is the **.travis.yml** file I'm using for this blog.

```
branches:
  only:
  - master
language: python
python:
- 2.7
install:
- pip install -r requirements.txt
script:
- pelican content
- fab publish
before_install:
- echo -e "Host seppa-lassila.fi\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config
- openssl aes-256-cbc -K $encrypted_1b260d22b91d_key -iv $encrypted_1b260d22b91d_iv -in deploy_key.enc -out deploy_key -d
- chmod 600 deploy_key
- mv deploy_key ~/.ssh/id_rsa
```

The start of the file defines that I want to build master branch and I'm using python (specifically version 2.7.). The install section will install pelican and the dependencies defined in the **requirements.txt** file. You can get the current dependencies for your project easily with command **pip freeze > requirements.txt**. The script section will do the actual site generation with command **pelican content** and upload the site to the web server using Fabric with **fab publish** command. The Fabric configuration can be found from **fabfile.py**. The before_install will setup the ssh key properly.

With this setup, the site is generated and deployed to the webserver after every push to the repository.

## Conclusion

This is not the easiest way to setup a blog and it took me a couple of nights to set this up. However, I am pleased by the result and now I can use online markup editors like [prose.io](http://prose.io/) to create and edit blog posts. Also, I learned the basics of using Travis CI in the process.

Sources of this blog can be seen in [https://github.com/tatusl/blog](https://github.com/tatusl/blog)
