#!/bin/bash
rm -rf form-diva
git clone https://github.com/brainbuz/form-diva.git
cd form-diva/Form-Diva
prove -lv t/*.t | tee /build/result
