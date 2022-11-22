#!/bin/sh

cd /var/www/blog

git pull --force origin master:master

git submodule update --init --recursive

git submodule update --rebase --remote

hugo