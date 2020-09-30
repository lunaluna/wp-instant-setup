#!/bin/sh -ux

# exit if wp-cli, wordmove or git is not installed.
type wp >/dev/null 2>&1 || { echo >&2 "wp-cli is not installed.  Aborting."; exit 1; }
type git >/dev/null 2>&1 || { echo >&2 "git is not installed.  Aborting."; exit 1; }


# Variables.
NOW=$(date +%Y%m%d_%H%M%S)
SERVER_DIR=${PWD}


# Create directories
if [ ! -e ${SERVER_DIR}/list ]; then
  mkdir ${SERVER_DIR}/list
fi

LIST_DIR="$SERVER_DIR/list"


# list plugins log
PLUGINSLIST=$(cat << EOC
## Plugins List
`wp plugin list --format=csv`

## Theme List
`wp theme list --format=csv`

## Number of plugins: `wp plugin list --format=count`
EOC
)

# file output
echo "$PLUGINSLIST" >> list.md
cat list.md > ${LIST_DIR}/list-${NOW}.md
rm -f list.md

exit 0
