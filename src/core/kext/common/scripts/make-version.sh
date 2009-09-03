#!/bin/sh

ostype=$(basename $(pwd))
version=$(cat ../../../../version)
echo "char config_version[] = \"$version-$ostype\";" > version.hpp
