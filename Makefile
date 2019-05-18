DOCBUILD=doctools/docbuild

ifeq ($(V),1)
	VERBOSE_OPT=--verbose
endif
ifeq ($(VERBOSE),1)
	VERBOSE_OPT=--verbose
endif

FETCHTS=.fetch.ts
LOCALFETCH=.LocalFetch.ts

all: help

help:
	@echo -e "Usage:"
	@echo -e "- make clean: clean all generated files"
	@echo -e "- make fetch VERSIONS=[VERSION,...] SECTIONS=[SECTION,...]: fetch the site if necessary "
	@echo -e "- make localFetch VERSIONS=[VERSION,...] SECTIONS=[SECTION,...]: fetch the site if necessary but use local file."
	@echo -e "- make build VERSIONS=[VERSION,...] SECTIONS=[SECTION,...]: build the site"
	@echo -e "- make push  VERSIONS=[VERSION,...] SECTIONS=[SECTION,...]: push the built site"
	@echo -e "- make serve VERSIONS=[VERSION,...] SECTIONS=[SECTION,...]: serve the site"
	@echo -e "- make linkchecker: check link in the local site, PORT=[default:4000]"
	@echo -e
	@echo -e "VERSIONS="
	@echo -e "\t represents the desired versions, separated with ,"
	@echo -e "SECTIONS="
	@echo -e "\t represents the desired sections, separated with ,"

.PHONY: clean
clean:
	$(DOCBUILD) $(VERBOSE_OPT) --clean
	rm -f $(FETCHTS)
	rm -f $(LOCALFETCH)

$(LOCALFETCH): $(wildcard content/toc/*/fetched_files.yml)
	$(DOCBUILD) $(VERBOSE_OPT) --localFetch --fetch --force
	touch $(FETCHTS)
	touch $@

$(FETCHTS): $(wildcard content/toc/*/fetched_files.yml)
	$(DOCBUILD) $(VERBOSE_OPT) $(LOCAL_FETCHTS) --fetch --force --versions=$(VERSIONS) --sections=$(SECTIONS)
	touch $@

.PHONY: fetch
fetch: $(FETCHTS)
	@echo "Fetched files up to date."

.PHONY: localFetch
localFetch: $(LOCALFETCH) $(FETCHTS)
	@echo "Fetched files up to date and copy local file."

.PHONY: build
build: $(FETCHTS)
	$(DOCBUILD) $(VERBOSE_OPT) --build

.PHONY: push
push: $(FETCHTS)
	$(DOCBUILD) $(VERBOSE_OPT) --build --push

.PHONY: serve
serve: $(FETCHTS)
	$(DOCBUILD) $(VERBOSE_OPT) --build --serve

.PHONY: linkchecker
linkchecker: $(FETCHS)
	@which linkchecker &> /dev/null || { echo "No linkchecker found, please install linkchecker"; exit -1; }
	@curl http://localhost:4000 &> /dev/null || { echo "No localhost:4000 found: Please run make serve before checking localsite"; exit -1; }
	linkchecker http://localhost:4000


