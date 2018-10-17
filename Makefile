DOCTOOLS=doctools
DOCBUILD=$(DOCTOOLS)/docbuild

VERBOSE=--verbose

FETCHTS=.fetch.ts
LOCALFETCH=.LocalFetch.ts

define GetFromConfig
$(shell node -p "require('./docs.json').$(1)")
endef

DOCTOOLSREPO      := $(call GetFromConfig,doctools.url)
DOCTOOLSBRANCH := $(call GetFromConfig,doctools.version)

all: help

help:
	@echo "Usage:"
	@echo "- make distclean: clean all generated files and repos"
	@echo "- make clean: clean all generated files"
	@echo "- make doctools: clone doctools repository"
	@echo "- make fetch: fetch the site if necessary"
	@echo "- make localFetch: fetch the site if necessary but use local file."
	@echo "- make build: build the site"
	@echo "- make push: push the built site"
	@echo "- make serve: serve the site"

.PHONY: distclean
distclean: clean
	rm -fr $(DOCTOOLS)

.PHONY: clean
clean:
	$(DOCBUILD) $(VERBOSE) --clean
	rm -f $(FETCHTS)
	rm -f $(LOCALFETCH)

$(LOCALFETCH): $(wildcard content/toc/*/fetched_files.yml)
	$(DOCBUILD) $(VERBOSE) --localFetch --fetch --force
	touch $(FETCHTS)
	touch $@

$(FETCHTS): $(wildcard content/toc/*/fetched_files.yml)
	$(DOCBUILD) $(VERBOSE) $(LOCAL_FETCHTS) --fetch --force
	touch $@

prebuild:
	@node -v && [ $$? -eq 0 ] || (echo "Please, make sure nodejs is installed" && false)
	@jekyll -v && [ $$? -eq 0 ] || (echo "Please, make sure jekyll is installed" && false)

.PHONY: doctools
doctools: prebuild
	echo $(DOCTOOLSREPO)
	@test ! -d $(DOCTOOLS) && git clone -b $(DOCTOOLSBRANCH) $(DOCTOOLSREPO) $(DOCTOOLS) || true
	@cd $(DOCTOOLS) && npm install

.PHONY: fetch
fetch: doctools $(FETCHTS)
	@echo "Fetched files up to date."

.PHONY: build
build: doctools $(FETCHTS)
	$(DOCBUILD) $(VERBOSE) --build

.PHONY: push
push: doctools $(FETCHTS)
	$(DOCBUILD) $(VERBOSE) --build --push

.PHONY: serve
serve: doctools $(FETCHTS)
	$(DOCBUILD) $(VERBOSE) --build --serve

