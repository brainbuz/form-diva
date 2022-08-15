#!/bin/bash

cd /build/Form-Diva
cpm install
prove -lv t/*.t
