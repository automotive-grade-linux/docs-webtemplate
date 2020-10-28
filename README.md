# Deprecated repo. 

Please use  https://automotivegradelinux.readthedocs.io . The sources of it are in https://git.automotivelinux.org/AGL/documentation .












# Introduction

This repository contains AGL documentation website template, rendering is visible at http://docs.automotivelinux.org
This website relies on the generator located in [docs-tools](https://github.com/automotive-grade-linux/docs-tools)


# Installing

Get the setupdocs script to initialise your environment.

```bash
wget https://raw.githubusercontent.com/automotive-grade-linux/docs-webtemplate/master/setupdocs.sh
```

This script fetches [docs-tools](https://github.com/automotive-grade-linux/docs-tools), install npm modules.

```bash
mkdir docs-webtemplate
bash setupdocs.sh --directory=docs-webtemplate
```

For consulting help, do:

```bash
bash setupdocs.sh --help
```

## Configure webdoc

Some default configuration options can be overridden in the project directory. For this, you can adjust the configuration file conf/AppDefaults.js

Other configuration files in conf/ starting by an underscore (_) are used by Jekyll. Some options may also be adjusted in particular in conf/_config.yml.

## generate a 1st site from your template

```bash
 ./doctools/docbuild --clean  # deleted all generated file if any
 ./doctools/docbuild --fetch [--force]  # collect doc from github (fetch list in content/toc/*/fetch_files.yml)
 ./doctools/docbuild --build --serve --watch --incremental # build config/tocs, generate html and start a local webserver
 

 xdg-open http://localhost:4000

 ./doctools/docbuild --push --verbose # push generated to production webserver (check conf/AppDefault 1st)
```

Alternatively, a Makefile can be used and defines the most common operations:

```bash
 make fetch
 make localFetch
 make build
 make push
 make serve
 make clean
```

## Work with local repos

For local fetch, a specific file named  "__fetched_files_local.yml" was introduced.

This file is used to overload url_fetch in fetched_files.yml in order to use local repositories on not remote ones.

Thus, this file is needed to be added in the docs-webtemplate root, see an example below:

```bash
############__fetched_files_local.yml##############
-
    url_fetch : <pathToDocsSources>/docs-sources/
    git_name   : "automotive-grade-linux/docs-sources"
-
    url_fetch : <pathToXdsDocs>/xds-docs/
    git_name   : src/xds/xds-docs

###################################################
```

## Start writing documentation

- the directory ./site holds your website content
- site/* directories not prefixed with "_" represent en entry within the menu
- site/_* directories contain template, configuration, options used by Jekyll
- site/_data is a special directory that hold both static and generated files to adjust page/site values within html pages
- content/toc/*/toc_VERSION_LANGUAGE.yml TOC(TableOfContent) and Fetch definitions
- site/_layouts and site/_includes holds page template
- site/static holds assets (static images, CSS etc.)

- register at https://community.algolia.com/docsearch/ and update your apikey into conf/_config.yml

## Notes

- The setupdocs.sh script can be used to update the docs-tools repository.
- The setupdocs.sh script cannot update the current repository, use git commands instead.

## bugs

```bash
 --watch to automatically regenerate pages on markdown file, you should force "./build --configs" when changing TOC or versions.
```
