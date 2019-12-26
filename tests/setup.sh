#!/bin/bash

git submodule init
git submodule update

ln -s ../../ roles/postgresql-backup
