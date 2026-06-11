#!/bin/bash

git submodule update --init --recursive

# git submodule foreach 'git apply --ignore-whitespace ../../patches/$name.patch || echo "Patch já aplicado ou inexistente para $name"'