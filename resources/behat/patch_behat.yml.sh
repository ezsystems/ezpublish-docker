#!/bin/bash

cp behat.yml.dist behat.yml
patch -p0 < /behat.yml.patch

