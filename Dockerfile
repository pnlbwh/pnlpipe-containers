FROM centos:7.5.1804

MAINTAINER Tashrif Billah <tbillah@bwh.harvard.edu>

    # set up user and working directory
ARG USER=pnlbwh
ENV USER="$USER"
ARG CWD=/home/$USER
WORKDIR $CWD
ENV PWD="$CWD"

    # libraries and commands for FSL
RUN yum -y update \
    && yum -y install epel-release wget file bzip2 openblas-devel which vim && \

    # install FSL, -V 5.0.11, you are welcome to change it below
    wget https://fsl.fmrib.ox.ac.uk/fsldownloads/fslinstaller.py -O fslinstaller.py \
    && python fslinstaller.py -V 6.0.1 -d `pwd`/fsl-5.0.11-centos7 -p

    # setup FSLDIR
ENV FSLDIR="$PWD/fsl-5.0.11-centos7"

    # setup all environment variables
ENV PATH="$FSLDIR/bin/:$PATH" \
	FSLMULTIFILEQUIT=TRUE \
	FSLGECUDAQ=cuda.q \
	FSLTCLSH="$FSLDIR/bin/fsltclsh" \
	FSLWISH="$FSLDIR/bin/fslwish" \
	FSLOUTPUTTYPE=NIFTI_GZ \

	PNLPIPE_SOFT="$PWD/pnlpipe/soft_dir" \

    CONDA_EXE="$PWD/miniconda3/bin/conda" \
	CONDA_PREFIX="$PWD/miniconda3" \
	CONDA_PYTHON_EXE="$PWD/miniconda3/bin/python" \
    PATH="$PWD/miniconda3/bin/:$PATH"


    # apply FSL patch
RUN $FSLDIR/fslpython/bin/conda install -y -n fslpython -c conda-forge deprecation==1.* && \

    # install python
    wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh \
	-O Miniconda3-latest-Linux-x86_64.sh \
    && /bin/bash Miniconda3-latest-Linux-x86_64.sh -b -p miniconda3/ && \

    git clone --recurse-submodules https://github.com/pnlbwh/pnlpipe.git && \
    cd pnlpipe && \

    # temporarily we are using py3-compatible branch
    git checkout py3-compatible  && \

    conda env create -f python_env/environment36.yml && \

    # should introduce '(pnlpipe3)' in front of each line
    conda activate pnlpipe3 && \

    # 'soft_dir' is where pipeline dependencies will be installed
    mkdir soft_dir && \

    # makes default parameter file: pnlpipe_params/std.params
    ./pnlpipe std init && \

    # builds pipeline dependencies specified in std.params
    ./pnlpipe std setup


