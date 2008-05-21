#!/bin/sh

ostype=$(basename $(pwd))
version=$(cat ../../../../version)
echo "char * const config_version = \"$version-$ostype\";" > version.hpp
