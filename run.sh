#!/usr/bin/env bash

set -ex;

count=`ps -ef | grep mysqld | grep -v grep | wc -l`
#count=`ps cax | grep mysqld | wc -l`
if [ $count = 0 ]; then
    mysql.server start
else
    mysql.server stop
    mysql.server start
fi

. ./conf.ini

WP_PATH=$(pwd)/www

if [ -e "$WP_PATH/wp-config.php" ]; then
    open http://127.0.0.1:$PORT
    wp server --host=0.0.0.0 --port=$PORT --docroot=$WP_PATH
    exit 0
fi

echo "path: www" > $(pwd)/wp-cli.yml

# wp core download --path=$WP_PATH --locale=en_US --version=trunk --force
wp core download --path=$WP_PATH --locale=$LOCALE --version=latest --force

if [ $DB_PASS ]; then
wp config create \
--skip-check \
--dbhost=127.0.0.1 \
--dbname="$DB_NAME" \
--dbuser="$DB_USER" \
--dbpass="$DB_PASS" \
--dbprefix=wp_ \
--locale=$LOCALE \
--extra-php <<PHP
define( 'JETPACK_DEV_DEBUG', true );
define( 'JETPACK_STAGING_MODE', true );
define( 'WP_DEBUG', true );
PHP
else
wp config create \
--skip-check \
--dbhost=127.0.0.1 \
--dbname=$DB_NAME \
--dbuser=$DB_USER \
--dbprefix=wp_ \
--locale=$LOCALE \
--extra-php <<PHP
define( 'JETPACK_DEV_DEBUG', true );
define( 'JETPACK_STAGING_MODE', true );
define( 'WP_DEBUG', true );
PHP
fi

wp db create || wp db reset --yes

wp core install \
--url=http://127.0.0.1:$PORT \
--title="WordPress" \
--admin_user="admin" \
--admin_password="admin" \
--admin_email="admin@example.com"

wp rewrite structure "/archives/%post_id%"

wp option update blogname "$WP_TITLE"
wp option update blogdescription "$WP_DESC"

if [ -e "provision-post.sh" ]; then
    bash provision-post.sh
fi

open http://127.0.0.1:$PORT
wp server --host=0.0.0.0 --port=$PORT --docroot=$WP_PATH
