#!/bin/bash

cd /build/Form-Diva
prove -lv t/*.t | tee /build/result
