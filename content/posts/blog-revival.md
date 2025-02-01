+++
date = '2025-01-31T05:34:39Z'
draft = true
title = 'Blog Revival'
+++

It has been almost five years since I last posted to this blog. A lot has happened in the world and in my life since then. Lately, I have had more energy for hobby projects and tinkering outside of work. It has been nice to see that I still have the inner curiosity for IT, learning new technologies and concepts, and finding out how things work.

I have also felt that it could be fun to write about my experiments and projects. So, I decided to revive this blog. I started by checking if I could still build the site with Hugo. I didn't have high hopes, because I assumed there had been breaking changes in Hugo during these past years. I found out that my theme wasn't compatible with the latest Hugo version. I considered trying to fix things for a while but then decided it was time for a new theme.

I wanted a minimal and lightweight theme without any extra features. During my search, I came across [hugo-theme-nostyleplease](https://github.com/hanwenguo/hugo-theme-nostyleplease). It looked clean and minimal, and after testing it briefly, I decided to use it. I made some minor modifications to the theme. For example, I wanted to show only a list of blog posts on the front page without list item bullets. I'm not that familiar with Hugo internals, but with the help of Claude AI, I was able to make the modifications. Best of all, I was able to learn something new about Hugo.

I also migrated the blog's hosting from Netlify to Cloudflare Pages. The migration process was simple and straightforward. I pointed Cloudflare Pages to my blog's GitHub repository and then configured the correct build command for the Hugo project. Since Cloudflare is the DNS host for the tatusl.dev zone, it suggested configuring the DNS record automatically. At first, the blog build wasn't successful, but I noticed that the default Hugo version was rather old. Users can configure the Hugo version by setting the `HUGO_VERSION` environment variable. After that, the build was successful and the blog deployed correctly.

Only time will tell if I have the time and energy to post to this blog more regularly. However, reviving and revising it has been an interesting task in itself.
