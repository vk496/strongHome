#!/bin/bash

if [[ $# -eq 0 ]]; then
  bash
fi

if [[ $1 == "config" ]]; then
  if [[ ! -f /remote/config/strongHome-schema.yaml ]]; then
    echo "Missing ./config/strongHome-schema.yaml"
    exit 1
  fi

  ./configurator.sh
fi

cd /remote
bash "$@"
