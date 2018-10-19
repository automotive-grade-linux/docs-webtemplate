#!/bin/bash

PROGNAME=${0##*/}
DESTINATION="."
NOGIT=0
DOCTOOLSDIR="doctools"
docswebtemplates="https://github.com/automotive-grade-linux/docs-webtemplate.git"
doctools="https://github.com/automotive-grade-linux/docs-tools.git"

#default branch
branch_doctools="master"
branch_docswebtemplates="master"

pushd() {
    command pushd "$@" &> /dev/null
}
popd() {
     command popd "$@" &> /dev/null
}

function usage() {
    echo "Usage: setupdocs.sh [OPTIONS]... [DIRECTORY]"
    echo "    -d, --directory=[DST]                 directory destination"
    echo "    -h, --help                            print this help"
    echo "    -t, --doctools-branch=[BRANCH]        doctools branch; BRANCH can be master or master-next"
    echo "    -w, --webtemplates-branch=[BRANCH]    webtemplates branch; BRANCH can be master or master-next"
    exit 1
}


SHORTOPTS="w:t:d:h"
LONGOPTS="webtemplates-branch:,doctools-branch:,directory:,help"
ARGS=$(getopt -s bash --options $SHORTOPTS  \
  --longoptions $LONGOPTS --name $PROGNAME -- "$@" )
if [ ! $? -eq 0 ]; then
    exit 1
fi
eval set -- "$ARGS"

while [ "$#" -gt "1" ]; do
    case "$1" in
        -w|--webtemplates-branch)
            branch_docswebtemplates=$2;shift 2;;
        -t|--doctools-branch)
            branch_doctools=$2; shift 2;;
        -d|--directory)
            DESTINATION=$2;shift 2;;
        -h|--help)
            usage;;
        *)
            usage;;
    esac
done

#check writable dir
if [ ! -w $DESTINATION ]; then
    echo "$DESTINATION is not a writable directory"
    exit 2
fi

#make sure nodejs and jekyll are installed
node -v && jekyll -v
if [ ! $? -eq 0 ]; then
    echo "please, make sure nodejs and jekyll are installed"
    exit 3
fi

#cloning repos
pushd $DESTINATION
#Checking if current dir is docwebtemplates repo
currentremote=$(git remote -v 2> /dev/null)
if [ $? -eq 0 ]; then #within a git
    #check in remote there is docswebtemplate
    echo $currentremote | grep $(basename $docswebtemplates) &> /dev/null
    if [ $? -eq 0 ]; then
        NOGIT=1
    fi
fi

if [ $NOGIT -eq 0 ]; then
    echo "Cloning docwebtemplates and doctools in $DESTINATION"
    git clone -b $branch_docswebtemplates $docswebtemplates &> /dev/null
    pushd $(basename $docswebtemplates | sed "s/\..*//")
    git clone -b $branch_doctools $doctools $DOCTOOLSDIR &> /dev/null
    pushd $DOCTOOLSDIR
    npm install
    popd
    popd
    echo "docwebtemplates and doctools cloned in $DESTINATION"
else
    echo "you are in docs-webtemplate in branch $(git branch | grep "*"): process $DOCTOOLSDIR"
    echo "so no process will be done in docs-webtemplate"
    if [ -d $DOCTOOLSDIR ]; then
        echo "$DOCTOOLSDIR already exits: process update with branch=$branch_doctools"
        pushd $DOCTOOLSDIR
        git checkout $branch_doctools &> /dev/null
        git pull $doctools $branch_doctools &> /dev/null
        npm install
        popd
    else
        echo "cloning $DOCTOOLSDIR"
        git clone -b $branch_doctools $doctools $DOCTOOLSDIR &> /dev/null
        pushd $DOCTOOLSDIR
        npm install
        popd
    fi
    echo "doctools updated"
fi
popd
