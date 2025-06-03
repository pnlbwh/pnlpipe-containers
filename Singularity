Bootstrap: docker
From: redhat/ubi9:9.5-1738643550

%labels
    MAINTAINER Tashrif Billah <tbillah@bwh.harvard.edu>

%help
    https://github.com/pnlbwh/CNN-Diffusion-MRIBrain-Segmentation 

    Please report issues on GitHub.


%post
    #
    # set up user and working directory
    mkdir /home/pnlbwh
    cd /home/pnlbwh
    export HOME=`pwd`
    #
    # install required libraries
    yum -y install wget file bzip2 which vim git make unzip libstdc++-static mesa-libGL bc libSM \
    gcc-c++ openssl-devel libX11-devel
    
    TCSH=tcsh-6.22.03-6.el9.x86_64.rpm
    wget https://dl.rockylinux.org/pub/rocky/9/devel/x86_64/os/Packages/t/$TCSH
    rpm -ivh $TCSH
    
    yum clean all
    #
    # install Cmake
    CMAKE=3.31.0 && \
    wget https://github.com/Kitware/CMake/releases/download/v${CMAKE}/cmake-${CMAKE}.tar.gz && \
    tar -xzf cmake-${CMAKE}.tar.gz && \
    cd cmake-${CMAKE} && mkdir build && cd build && \
    ../bootstrap --parallel=4 && make -j4
    cd
    #
    # install dcm2niix
    git clone https://github.com/rordenlab/dcm2niix.git && \
    cd dcm2niix && mkdir build && cd build && \
    /home/pnlbwh/cmake-${CMAKE}/build/bin/cmake .. && make -j4 && \
    mv bin/dcm2niix /usr/bin/ && \
    cd && rm -rf $HOME/dcm2niix && \
    #
    # install ANTs
    git clone https://github.com/ANTsX/ANTs.git
    cd ANTs && mkdir build && cd build
    /home/pnlbwh/cmake-${CMAKE}/build/bin/cmake .. && make -j4
    cd
    #
    # install ukftractography
    git clone https://github.com/pnlbwh/ukftractography.git && \
    cd ukftractography && mkdir build && cd build && \
    /home/pnlbwh/cmake-${CMAKE}/build/bin/cmake .. && make -j4
    cd
    #
    # install miniconda3
    wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -O Miniconda3-latest-Linux-x86_64.sh && \
    /bin/bash Miniconda3-latest-Linux-x86_64.sh -b -p miniconda3/ && \
    source miniconda3/bin/activate && \
    #
    # install pnlpipe
    git clone https://github.com/pnlbwh/pnlNipype.git
    conda create -y -n pnlpipe9 -c conda-forge --override-channels python
    conda activate pnlpipe9
    cd pnlNipype
    pip install -r requirements.txt
    conda deactivate
    cd
    #
    git clone https://github.com/pnlbwh/luigi-pnlpipe.git
    git clone https://github.com/pnlbwh/HCPpipelines.git
    git clone https://github.com/pnlbwh/conversion.git
    #
    # CNN-Diffusion-MRIBrain-Segmentation
    git clone https://github.com/pnlbwh/CNN-Diffusion-MRIBrain-Segmentation.git && \
    wget https://github.com/pnlbwh/CNN-Diffusion-MRIBrain-Segmentation/releases/download/v0.3/model_folder.tar.gz && \
    tar -xzvf model_folder.tar.gz && rm -f model_folder.tar.gz && \
    conda create -y -n dmri_seg python=3.11 -c conda-forge --override-channels && \
    conda activate dmri_seg && \
    pip install 'tensorflow[and-cuda]==2.15.1' && \
    pip install scikit-image git+https://github.com/pnlbwh/conversion.git && \
    conda deactivate
    #
    # HD-BET
    conda create -y -n hd-bet python=3.9 -c conda-forge --override-channels
    conda activate hd-bet
    git clone --single-branch --branch pnl https://github.com/pnlbwh/HD-BET.git
    cd HD-BET/
    pip install .
    pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
    conda deactivate
    #
    # download HD-BET params
    cd /home/pnlbwh/miniconda3/envs/hd-bet/lib/python3.9/site-packages/HD_BET
    mkdir -p params && cd params
    for i in {0..4}
    do
        wget https://zenodo.org/record/2540695/files/${i}.model
    done
    cd
    #
    # whitematteranalysis
    conda create -y -n wma python=3.9 -c conda-forge --override-channel
    conda activate wma
    pip install git+https://github.com/SlicerDMRI/whitematteranalysis.git
    #
    git clone https://github.com/demianw/tract_querier.git
    cd tract_querier
    python setup.py install
    export PATH=`pwd`/scripts:$PATH
    pip install plumbum
    conda deactivate
    #
    # install FSL
    echo "Downloading FSL installer" && \
    wget https://fsl.fmrib.ox.ac.uk/fsldownloads/fslinstaller.py -O fslinstaller.py > /dev/null 2>&1 && \
    echo "Installing FSL" && \
    V=6.0.7 && \
    python fslinstaller.py -V $V -d $HOME/fsl-$V > /dev/null && \
    # setup FSL environment
    export FSLDIR=$HOME/fsl-$V && \
    rm -f fslinstaller.py && \
    #
    # install freesurfer
    echo "Downloading FreeSurfer"
    V=7.4.1
    TAR=freesurfer-linux-centos8_x86_64-7.4.1.tar.gz
    wget https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/${V}/${TAR} > /dev/null 2>&1
    echo "Unzipping FreeSurfer tar ball"
    tar -xzf $TAR && rm -f $TAR
    mv freesurfer freesurfer-$V
    #
    # install MCR for -subfields
    export FREESURFER_HOME=/home/pnlbwh/freesurfer-$V
    source ${FREESURFER_HOME}/SetUpFreeSurfer.sh
    fs_install_mcr R2019b
    #
    # clean up
    rm -rf $HOME/.cache/pip/ $HOME/Miniconda3-latest-Linux-x86_64.sh
    conda deactivate
    source $HOME/miniconda3/bin/activate
    conda clean -y --all
    
    
%environment
    #
    # set up bashrc i.e shell
    #
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
    PATH=$ROOT/miniconda3/envs/pnlpipe9/bin:$PATH
    #
    export PATH


