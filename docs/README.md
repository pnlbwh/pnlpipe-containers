![](./pnl-bwh-hms.png)

[![DOI](https://zenodo.org/badge/doi/10.5281/zenodo.3258854.svg)](https://doi.org/10.5281/zenodo.3258854) [![Python](https://img.shields.io/badge/Python-3.6-green.svg)]() [![Platform](https://img.shields.io/badge/Platform-linux--64%20%7C%20osx--64%20%7C%20win--64-orange.svg)]()

Developed by Tashrif Billah and Sylvain Bouix, Brigham and Women's Hospital (Harvard Medical School).


Table of contents
=================

   * [Citation](#citation)
   * [Background](#background)
      * [System requirement](#system-requirement)      
          * [Single machine](#single-machine)
          * [Distributed environment](#distributed-environment)            
      * [Time profile](#time-profile)
   * [pnlpipe containers](#pnlpipe-containers)
      * [Docker](#docker)
      * [Singularity](#singularity)
   * [Programs](#programs)
   * [Luigi tasks](#luigi-tasks)
   * [Tests](#tests)
   * [Data analysis](#data-analysis)
   * [Appendix](#appendix)


# Citation

If *pnlpipe-containers* are useful in your research, please cite as below:

Billah, Tashrif; Bouix, Sylvain; Rathi, Yogesh; NIFTI MRI processing pipeline, https://github.com/pnlbwh/pnlNipype, 2019, DOI: 10.5281/zenodo.3258854


# Background

If you are new to the container concept, it can be resourceful to see Tashrif's [presentation](https://www.dropbox.com/s/nmpnto459yus3lg/031521-Containers-Part-2.pptx?dl=0) on containers. In any case, your system needs the following capabilities to run containers.

## System requirement

#### Single machine

- Examples are your personal laptop or lab workstation
- Docker or Singularity, whichever you use, must be installed.
  Running Docker conventionally requires administrative/sudo (root) privileges.
  But you may be able to run Docker in [rootless](https://docs.docker.com/engine/security/rootless/) mode.
- 4 cores, 16 GB RAM, 30 GB disk space for each container image
- 10 GB/subject disk space

#### Distributed environment

- A Linux cluster with a job scheduler (LSF or SLURM).
- Docker or Singularity, whichever you use, must be installed. Running Docker requires administrative (sudo) privileges.
  Because of the risk involved with sudo, shared clusters usually have Singularity only. But your cluster admin may also create
  an isolated virtual machine (VM) for you with sudo privileges where you can run Docker.
- Core, RAM, and disk space are usually abundant in a cluster. But you would need at least
  10 GB/subject disk space, either physical or mounted to the node where job is run.


## Time profile

Time profile of various tasks of *pnlpipe* is given below:

| Task                                     | Estimated time hour/subject               |
|------------------------------------------|-------------------------------------------|
| T1/T2 MABS<sup>~</sup> masking           | 1.5                                       |
| T1/T2 HD-BET masking                     | 0.1                                       |
| FreeSurfer segmentation                  | 6 (1 mm<sup>3</sup>), 9 (high resolution) |
| DWI Gibb's unringing                     | 0.5                                       |
| DWI CNN masking                          | 0.25                                      |
| FSL eddy correction                      | 2                                         |
| FSL HCP Pipeline (topup+eddy) correction | 4                                         |
| PNL eddy correction                      | 0.5                                       |
| PNL epi correction                       | 0.5                                       |
| UKF tractography                         | 2                                         |
| White matter analysis                    | 1.5                                       |
| FreeSurfer to DWI                        | 1.5                                       |

<sup>~</sup>MABS: Multi Atlas Brain Segmentation

If we add the times, total duration per subject for various pipelines would be:

| Pipeline | Estimated total hour/subject |
|--|--|
| [Structural](https://github.com/pnlbwh/pnlNipype/blob/master/docs/TUTORIAL.md#structural) | 10 |
| [Diffusion](https://github.com/pnlbwh/pnlNipype/blob/master/docs/TUTORIAL.md#diffusion) | 7 (FSL HCP Pipeline), 2 (PNL eddy+epi) |
| [Tractography](https://github.com/pnlbwh/pnlNipype/blob/master/docs/TUTORIAL.md#tractography) | 5 |
| Total | 22 |

Job execution nodes in a cluster managed by LSF or SLURM are usually time-constrainted. For running our pipelines,
you must choose such nodes/queues that allow at least as much runtime as above.


# pnlpipe containers

This repository provides recipes for building [*pnlpipe*](https://github.com/pnlbwh/pnlNipype) containers.
The containers include the following software:

* Python
* [ANTs](https://github.com/ANTsX/ANTs)
* [unu](https://teem.sourceforge.net/unrrdu)
* [tract_querier](https://github.com/demianw/tract_querier)
* [dcm2niix](https://github.com/rordenlab/dcm2niix)
* [whitematteranalysis](https://github.com/SlicerDMRI/whitematteranalysis)
* [UKFTractography](https://github.com/pnlbwh/UKFTractography)
* [pnlNipype](https://github.com/pnlbwh/pnlNipype)
* [luigi-pnlpipe](https://github.com/pnlbwh/luigi-pnlpipe)
* [conversion](https://github.com/pnlbwh/conversion)
* [HCPpipelines](https://github.com/pnlbwh/HCPpipelines)
* [CNN-Diffusion-MRIBrain-Segmentation](https://github.com/pnlbwh/CNN-Diffusion-MRIBrain-Segmentation)
* [HD-BET](https://github.com/pnlbwh/HD-BET)

Consult each software's documentation about their detailed running instructions.
*pnlpipe* pipeline depends on two other software, installation of which requires you to agree to their license terms:

* [FreeSurfer](https://surfer.nmr.mgh.harvard.edu/fswiki/DownloadAndInstall) 7.4.1
* [FSL](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FslInstallation) 6.0.7

They are already installed in the *tbillah/pnlpipe* docker image. Befor using the image, you should review their 
respective licenses. A salient clause of FSL license states it is not free for commercial use. 
So, if you use *tbillah/pnlpipe* image, make sure you are aware of that limitation. The maintainer of this image is not 
and cannot be held liable for any unlawful use of this image. On the other hand, obtain a FreeSurfer license key from [here](https://surfer.nmr.mgh.harvard.edu/fswiki/License) 
and save it as `license.txt` file in your host machine. To be able to run FreeSurfer, you have to mount the license into 
this image.

Furthermore, if you want to use our *CNN-Diffusion-MRIBrain-Segmentation* tool, you must download `IITmean_b0_256.nii.gz` 
locally and mount into this image:

    wget https://www.nitrc.org/frs/download.php/11290/IITmean_b0_256.nii.gz


## Docker

(i) The *pnlpipe* docker container is publicly hosted at [https://hub.docker.com/r/tbillah/pnlpipe](https://hub.docker.com/r/tbillah/pnlpipe).
You can get it by:

    docker pull tbillah/pnlpipe
    
Instead of Docker Hub, you can also download the container from our Dropbox:

    wget https://www.dropbox.com/s/hfkyxvu9hvahumb/pnlpipe.tar.gz


(ii) Process your data:

    docker run --rm -v /host/path/to/freesurfer/license.txt:/home/pnlbwh/freesurfer-7.4.1/license.txt \
    -v /host/path/to/myData:/home/pnlbwh/myData \
    -v /host/path/to/IITmean_b0_256.nii.gz:/home/pnlbwh/CNN-Diffusion-MRIBrain-Segmentation/model_folder/IITmean_b0_256.nii.gz \
    tbillah/pnlpipe \
    "dwi_masking.py -i /home/pnlbwh/myData/imagelist.txt -f /home/pnlbwh/CNN-Diffusion-MRIBrain-Segmentation/model_folder"

* Please make sure to enclose your command within double quotes--`"dwi_masking.py ..."`.
* `-v /host/path/to/myData:/home/pnlbwh/data` is for mounting your data into the container so you can analyze.
* If you would like an interactive shell into the container, use `docker run --rm -ti ...` and omit the command in `" "`.


## Singularity

(i) Download pre-built singularity image from our Dropbox:

    wget https://www.dropbox.com/s/8qtqjisfnv5t9i5/pnlpipe.sif

Because of limited storage quota, it could not be hosted in https://cloud.sylabs.io/library/.


(ii) Process your data:

    singularity run --bind /host/path/to/freesurfer/license.txt:/home/pnlbwh/freesurfer-7.4.1/license.txt \
    --bind /host/path/to/IITmean_b0_256.nii.gz:/home/pnlbwh/CNN-Diffusion-MRIBrain-Segmentation/model_folder/IITmean_b0_256.nii.gz \
    --bind /host/path/to/myData:/home/pnlbwh/myData \
    pnlpipe.sif \
    dwi_masking.py -i /home/pnlbwh/myData/imagelist.txt -f /home/pnlbwh/CNN-Diffusion-MRIBrain-Segmentation/model_folder

* Notice that you do NOT need to enclose your command within double quotes.
* `--bind` is for mounting your data into the container so you can analyze. Singularity mounts `$HOME` directory by default. 
So, if your data is in any subdirectory of `$HOME`, you should NOT need to mount them.
* If you would like an interactive shell into the container, use `singularity shell ...` and omit the command to run. 
Once inside the shell, you might want to set `alias ls='ls --color'` in the first place.
* While trying to analyze data, if you run into write permission issue, use the `singularity run --writable-tmpfs ...`.



# Programs

All *pnlpipe* scripts and executables are available to `docker run ...` and `singularity run ...`. 
You may learn more about them in corresponding tutorials linked above.


# Luigi tasks

Now you can run [luigi-pnlpipe](https://github.com/pnlbwh/luigi-pnlpipe) inside our containers leveraging your own Luigi server.
To be able to do so, launch Luigi server in your host computer:

    git clone https://github.com/pnlbwh/pnlpipe-containers.git
    cd pnlpipe-containers
    ./luigi.sh

Visit http://localhost:8082 in your browser to confirm that you have successfully launched the server.
Now shell into the containers and run programs from the interactive shells:

    # Launch Docker container
    docker run --rm -ti \
    --gpus=all --network=host \
    -v /host/path/to/freesurfer/license.txt:/home/pnlbwh/freesurfer-7.4.1/license.txt \
    -v /host/path/to/IITmean_b0_256.nii.gz:/home/pnlbwh/CNN-Diffusion-MRIBrain-Segmentation/model_folder/IITmean_b0_256.nii.gz \
    -v /host/path/to/myData:/home/pnlbwh/myData \
    tbillah/pnlpipe

    # Inside the container
    cd /home/pnlbwh
    export LUIGI_CONFIG_PATH=`pwd`/luigi-pnlpipe/params/hcp/T2w_mask_params.cfg
    luigi-pnlpipe/workflows/ExecuteTask.py -c 1001 -s 1 --t1-template sub-*/ses-*/anat/*_T1w.nii.gz --task StructMask \
    --bids-data-dir /home/pnlbwh/myData/rawdata


---


    # Launch Singularity container
    singularity shell \
    --nv \
    --bind /host/path/to/freesurfer/license.txt:/home/pnlbwh/freesurfer-7.4.1/license.txt \
    --bind /host/path/to/IITmean_b0_256.nii.gz:/home/pnlbwh/CNN-Diffusion-MRIBrain-Segmentation/model_folder/IITmean_b0_256.nii.gz \
    --bind /host/path/to/myData:/home/pnlbwh/myData \
    pnlpipe.sif
    
    # Inside the container
    cd /home/pnlbwh
    export LUIGI_CONFIG_PATH=`pwd`/luigi-pnlpipe/params/hcp/T2w_mask_params.cfg
    luigi-pnlpipe/workflows/ExecuteTask.py -c 1001 -s 1 --t1-template sub-*/ses-*/anat/*_T1w.nii.gz --task StructMask \
    --bids-data-dir /home/pnlbwh/myData/rawdata


You may need to edit Luigi configuration files before running *luigi-pnlpipe* tasks hence we recommend using interactive shells.
Example:

    # Inside the container
    cp /home/pnlbwh/luigi-pnlpipe/params/hcp/T2w_mask_params.cfg /tmp/
    vim /tmp/T2w_mask_params.cfg
    export LUIGI_CONFIG_PATH=/tmp/T2w_mask_params.cfg


# Tests

Once inside the container, you can test its functionality with:

> align.py --help

> UKFTractography --help

> antsRegistration --help



The above should print corresponding help messages without any error.



# Data analysis

With the above `docker run` and `singularity run` commands, you mount your data inside the containers 
so you can analyze using *pnlpipe*. The files you generate at `/home/pnlbwh/myData` are saved at `/host/path/to/myData`.

**NOTE** The containers are not equipped with GUI by default. So, if you need to visually look at your MRI-- 
launch fsleyes, freeview etc from your host machine, not from the container. Since processed data is saved in 
the host directory that you mounted on the container, it should not be a problem to explore them from your host 
machine. Optionally, if you want to run applications that require GUI support, 
please see https://github.com/tashrifbillah/glxgears-containers for details.


# Appendix

### Cmake installation

    yum -y install openssl-devel
    wget https://github.com/Kitware/CMake/releases/download/v3.19.4/cmake-3.19.4.tar.gz
    tar -xzf cmake-3.19.4.tar.gz
    cd cmake-3.19.4 && mkdir build && cd build
    ../bootstrap && make -j4
    export PATH=`pwd`/build/bin:$PATH

### GPU usage

First of all, you need to have GPU(s) available in your host computer. NVIDIA driver should be installed in your host computer.
In a Linux device, if `nvidia-smi` prints a valid output, then your host is compatible for GPU jobs.


    Thu Jul  3 14:56:24 2025
    +---------------------------------------------------------------------------------------+
    | NVIDIA-SMI 535.146.02             Driver Version: 535.146.02   CUDA Version: 12.2     |
    |-----------------------------------------+----------------------+----------------------+
    | GPU  Name                 Persistence-M | Bus-Id        Disp.A | Volatile Uncorr. ECC |
    | Fan  Temp   Perf          Pwr:Usage/Cap |         Memory-Usage | GPU-Util  Compute M. |
    |                                         |                      |               MIG M. |
    |=========================================+======================+======================|
    |   0  NVIDIA GeForce RTX 4080        Off | 00000000:C3:00.0  On |                  N/A |
    |  0%   36C    P8              15W / 320W |    396MiB / 16376MiB |      2%      Default |
    |                                         |                      |                  N/A |
    +-----------------------------------------+----------------------+----------------------+

    +---------------------------------------------------------------------------------------+
    | Processes:                                                                            |
    |  GPU   GI   CI        PID   Type   Process name                            GPU Memory |
    |        ID   ID                                                             Usage      |
    |=======================================================================================|
    |    0   N/A  N/A     76021      G   /usr/libexec/Xorg                           173MiB |
    |    0   N/A  N/A     76147      G   /usr/bin/gnome-shell                         52MiB |
    +---------------------------------------------------------------------------------------+


* In Singularity, you need to provide `--nv` flag to your `shell` or `run` command to have GPU(s) availabe to the container.
* In Docker, it is more tricky. You ned to install `nvidia-container-toolkit` on top of the above:

        curl -s -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo | sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo
        dnf config-manager --enable nvidia-container-toolkit-experimental
        dnf install -y nvidia-container-toolkit
        systemctl restart docker

  And finally, you need to provide `--gpus=all` flag to your `run` command to have GPU(s) availabe to the container.

