#!/bin/bash

PREFIX=${ROOT}/miniconda3/envs/dmri_seg/
# export LD_LIBRARY_PATH=${PREFIX}/lib
${PREFIX}/bin/python ${ROOT}/CNN-Diffusion-MRIBrain-Segmentation/pipeline/dwi_masking.py $@

