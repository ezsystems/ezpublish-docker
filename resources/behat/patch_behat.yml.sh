#!/bin/bash

patch -p0 < /behat.yml.dist.add_junit_formatter.patch
cp behat.yml.dist behat.yml
patch -p0 < /behat.yml.patch

composer require --dev jarnaiz/behat-junit-formatter
