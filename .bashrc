# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

alias ls='ls --color'

ROOT=/home/pnlbwh
#
# FSL
export FSLDIR=$ROOT/fsl-6.0.7
export FSLOUTPUTTYPE=NIFTI_GZ
PATH=$FSLDIR/share/fsl/bin:$PATH
#
# FreeSurfer
export SUBJECTS_DIR=$ROOT/FS_SUBJECTS_DIR
export FREESURFER_HOME=$ROOT/freesurfer-7.4.1
source ${FREESURFER_HOME}/SetUpFreeSurfer.sh
#
# Teem
PATH=$ROOT/ukftractography/build/bin/:$PATH
#
# ukftractography
PATH=$ROOT/ukftractography/build/UKFTractography-build/UKFTractography/bin:$PATH
#
# ANTs
export ANTSPATH=$ROOT/ANTs/build/ANTS-build/Examples
PATH=$ANTSPATH:$ROOT/ANTs/Scripts:$PATH
#
export PYTHONPATH=$ROOT/luigi-pnlpipe
#
PATH=$ROOT/miniconda3/envs/pnlpipe9/bin:$ROOT/miniconda3/condabin:$PATH
#
PATH=$ROOT/pnlNipype/scripts:$PATH
#
export PATH ROOT

