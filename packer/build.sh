#!/usr/bin/env bash

set -e

BUILDER_TYPE="$1"
TEMPLATE_NAME="$2"

function __build_vagrant {
  pushd templates
  packer build -only=vagrant "$TEMPLATE_NAME.json"
  popd

  temp_dir="vagrant/$TEMPLATE_NAME/tmp"
  vagrant box add --force "$TEMPLATE_NAME" "$temp_dir/package.box"
  rm -rf "$temp_dir"
}

case $BUILDER_TYPE in
  vagrant)
    __build_vagrant
    ;;
  *)
    echo 'Unknown command'
    exit 1
esac
