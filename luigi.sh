#!/bin/bash

# This is a convenience script for installing and launching luigid server.

# work in $HOME
cd $HOME

if [ ! -f miniconda3/bin/luigid ]
    # install python
    wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
    bash Miniforge3-Linux-x86_64.sh -b -p miniconda3
    source miniconda3/bin/activate

    # install luigid
    pip install git+https://github.com/spotify/luigi.git@172128c3de7a41411a10e61e3c675b76595793e2
    pip install sqlalchemy==1.4.54
    pip install setuptools<81
fi

# launch luigid server
if [ ! -d luigi-pnlpipe ]
    git clone https://github.com/pnlbwh/luigi-pnlpipe.git
fi

cd luigi-pnlpipe
mkdir -p luigi-server
luigid --logdir luigi-server --background

# confirm launch at http://localhost:8082

