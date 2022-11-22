#!/bin/sh

cd /var/www/blog

git pull --force

git submodule update --init --recursive

git submodule update --rebase --remote

hugo