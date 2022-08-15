#!/bin/bash

cd /build/Form-Diva
cpm install -g
prove -l t/*.t
# while true; do sleep 1; done