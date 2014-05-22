#!/bin/bash

module='mapper'
usage()
{
cat << EOF
usage: $0 options

This script installs/uninstalls module $module.

OPTIONS:
   -h      Show this message
   -d      Database
   -m      Install/Uninstall [1/0]
   -i      Execute Init script
EOF
}

INIT=0
while getopts "hd:m:i" OPTION
do
    case $OPTION in
        h)
            usage
            exit 1
            ;;
        d)
            DATABASE=$OPTARG
            ;;
        m)
            MODE=$OPTARG
            ;;
        i)
                INIT=1
            ;;
        ?)
            usage
            exit
            ;;
    esac
done

if [[ -z $DATABASE ]] || [[ -z $MODE ]]; then
    usage
    exit 1
fi

if [ $MODE -eq 0 ]; then
    psql -d $DATABASE < schema_drop.sql
elif [ $MODE -eq 1 ]; then
    psql -d $DATABASE < schema_create.sql
    if [ $INIT -eq 1 ]; then
	psql -d $DATABASE < schema_init.sql
    fi
fi
exit 0