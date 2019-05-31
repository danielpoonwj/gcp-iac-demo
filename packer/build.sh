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

function __build_googlecompute {
  cd templates
  packer build -only=googlecompute -var-file=../vars/googlecompute.vars "$TEMPLATE_NAME.json"
}

case $BUILDER_TYPE in
  vagrant)
    __build_vagrant
    ;;
  googlecompute)
    __build_googlecompute
    ;;
  *)
    echo 'Unknown command'
    exit 1
esac
