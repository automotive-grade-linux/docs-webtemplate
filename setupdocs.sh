#!/bin/bash

DEBUG=1
PROGNAME=$(basename $BASH_SOURCE)
DESTINATION="."
GITREF=""
DOCTOOLSDIR="doctools"
docswebtemplates="https://github.com/automotive-grade-linux/docs-webtemplate.git"
doctools="https://github.com/automotive-grade-linux/docs-tools.git"

#default branch
ref_docswebtemplate=""
ref_doctools="master"

pushd() {
    command pushd "$@" &> /dev/null
}
popd() {
     command popd "$@" &> /dev/null
}
debug() {
    [[ $DEBUG -eq 0 ]] && echo "[DEBUG]: $@" >&2
}
error() {
    echo "$@" >&2
}

gitcheckout() {
    command git checkout "$@" &> /dev/null
    if [ ! $? -eq 0 ]; then
        error "Cannot checkout: $@ does not exit"
        exit 4
    fi
}

gitclone() {
    command git clone "$@" &> /dev/null
    if [ ! $? -eq 0 ]; then
        error "Cannot clone $@ "
        exit 5
    fi
}

function usage() {
    cat <<EOF >&2
Usage: $PROGNAME [OPTIONS]... [DIRECTORY]
    --debug                               debug mode
    -d, --directory=[DST]                 directory destination; DST is the destination
    -h, --help                            print this help
    -t, --doctools-ref=[REFERENCE]        doctools reference;
                                          REFERENCE can be a branch, a tag, a commit
    -w, --webtemplate-ref=[REFERENCE]    webtemplates reference;
                                          REFERENCE can be a branch, a tag, a commit
EOF
    exit 1
}


SHORTOPTS="w:t:d:h"
LONGOPTS="webtemplate-ref:,doctools-ref:,directory:,debug,help"
ARGS=$(getopt -s bash --options $SHORTOPTS  \
  --longoptions $LONGOPTS --name $PROGNAME -- "$@" )
if [ ! $? -eq 0 ]; then
    exit 1
fi
eval set -- "$ARGS"

while [ "$#" -gt "1" ]; do
    case "$1" in
        -w|--webtemplate-ref)
            ref_docswebtemplate=$2;shift 2;;
        -t|--doctools-ref)
            ref_doctools=$2; shift 2;;
        -d|--directory)
            DESTINATION=$2;shift 2;;
        --debug)
            DEBUG=0;shift 2;;
        -h|--help)
            usage;;
        *)
            usage;;
    esac
done

#make sure nodejs and jekyll are installed
node -v && jekyll -v
if [ ! $? -eq 0 ]; then
    error "please, make sure nodejs and jekyll are installed"
    exit 3
fi

#check writable dir
if [ ! -w $DESTINATION ]; then
    error "$DESTINATION is not a writable directory"
    exit 2
fi


pushd $DESTINATION

#get reference
[[ -d .git ]] && [[ "$(realpath $BASH_SOURCE)" == "$(realpath $(basename $BASH_SOURCE))" ]] && GITREF=$(git rev-parse HEAD)
ref_docswebtemplate=${ref_docswebtemplate:-${GITREF:-master}}
debug "ref_docswebtemplate=$ref_docswebtemplate ref_doctools=$ref_doctools"

[[ -d .git ]] && rev=$(git show-ref -s $ref_docswebtemplate | sort | uniq) && rev=${rev:-$ref_docswebtemplate}

debug "GITREF=$GITREF and rev=$rev"
#check that reference given matching with local repo
[[ "$GITREF" != "$rev" ]]  \
    && { error "Invalid reference between $ref_docswebtemplate and local repo in $DESTINATION"; exit 5; }
#processing cloning or update
if [ -z $GITREF ]; then
    echo "Cloning docwebtemplates and doctools in $DESTINATION"
    gitclone $docswebtemplates .
    gitcheckout $ref_docswebtemplate
    gitclone $doctools $DOCTOOLSDIR
    pushd $DOCTOOLSDIR
    gitcheckout $ref_doctools
    npm install
    popd
    echo "docwebtemplates and doctools cloned in $DESTINATION"
else
    echo "you are in docs-webtemplate: process $DOCTOOLSDIR"
    echo "so no process will be done in docs-webtemplate"
    if [ -d $DOCTOOLSDIR ]; then
        echo "$DOCTOOLSDIR already exits: process update with reference=$ref_doctools"
        pushd $DOCTOOLSDIR
        gitcheckout $branch_doctools
        git pull $doctools $branch_doctools &> /dev/null
        npm install
        popd
    else
        echo "cloning $DOCTOOLSDIR"
        gitclone $doctools $DOCTOOLSDIR
        pushd $DOCTOOLSDIR
        gitcheckout $ref_doctools
        npm install
        popd
    fi
    echo "doctools updated"
fi
popd
