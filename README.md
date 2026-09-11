# tatusl.dev

My personal tech blog at https://tatusl.dev.

Built with [Hugo](https://gohugo.io) and customized [hugo-theme-nostyleplease](https://github.com/hanwenguo/hugo-theme-nostyleplease) theme. Hosted on [Cloudflare Pages](https://pages.cloudflare.com/).

## Hugo version

The Hugo version is pinned in the `Makefile` (`HUGO_VERSION`). It is the single
source of truth: local builds run that version's container image, and `build.sh`
reads the same value when Cloudflare Pages builds the site. Bumping the version
in the `Makefile` is enough to move both.

Cloudflare Pages cannot pin Hugo from the repository on its own — it only offers
the `HUGO_VERSION` build environment variable — so the Pages project is
configured to run the build script instead:

- Build command: `sh ./build.sh`
- Build output directory: `public`

The script builds with `-b "$CF_PAGES_URL"` when Pages provides that variable,
so preview deployments keep linking to themselves rather than to production.

The `HUGO_VERSION` environment variable is therefore unused and should stay
unset in the Pages dashboard.
