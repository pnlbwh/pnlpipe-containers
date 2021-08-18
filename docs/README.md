![](./pnl-bwh-hms.png)

[![DOI](https://zenodo.org/badge/doi/10.5281/zenodo.2584271.svg)](https://doi.org/10.5281/zenodo.2584271) [![Python](https://img.shields.io/badge/Python-3.6-green.svg)]() [![Platform](https://img.shields.io/badge/Platform-linux--64%20%7C%20osx--64%20%7C%20win--64-orange.svg)]()

Developed by Tashrif Billah and Sylvain Bouix, Brigham and Women's Hospital (Harvard Medical School).


Table of contents
=================

   * [pnlpipe containers](#pnlpipe-containers)
      * [Docker](#docker)
      * [Singularity](#singularity)
   * [Citation](#citation)
   * [Tests](#tests)
   * [Data analysis](#data-analysis)
   * [Appendix](#appendix)


Table of Contents created by [gh-md-toc](https://github.com/ekalinin/github-markdown-toc)


# Background

If you are new to the container concept, it can be resourceful to see Tashrif's [presentation](https://www.dropbox.com/s/nmpnto459yus3lg/031521-Containers-Part-2.pptx?dl=0) on containers. In any case, your system needs the following capabilities to run containers: 

#### Single machine

- Examples are your personal laptop or lab workstation
- Docker or Singularity, whichever you use, must be installed. Running Docker requires administrative (sudo) privileges.
- 4 cores, 16 GB RAM, 30 GB disk space for each container image
- 10 GB/subject disk space

#### Distributed environment:

- A Linux cluster with a job scheduler (LSF or SLURM)
- Docker or Singularity, whichever you use, must be installed. Running Docker requires administrative (sudo) privileges.
  Because of the risk involved with sudo, shared clusters usually have Singularity only. But your cluster admin may also create
  an isolated virtual machine (VM) for you with sudo privileges where you can run Docker.
- Core, RAM, and disk space are usually abundant in a cluster but you would need at least the requirement of a single machine
- 10 GB/subject disk space, either physical or mounted to the node where job is run


#### Time profile

Time profile of various tasks of *pnlpipe* is given below:

| Task                            | Estimated time hour/subject   |
|---------------------------------|-------------------------------|
| T1/T2 MABS<sup>~</sup> masking  | 1.5                           |
| FreeSurfer segmentation         | 6 (1mm3) 9 (high resolution)  |
| DWI Gibb's unringing            | 0.5                           |
| DWI CNN masking                 | 0.25                          |
| FSL eddy correction             | 2                             |
| FSL epi (topup+eddy) correction | 2.5                           |
| PNL eddy correction             | 0.5                           |
| PNL epi correction              | 0.5                           |
| UKF tractography                | 2                             |
| White matter analysis           | 1.5                           |
| FreeSurfer to DWI               | 1.5                           |

<sup>~</sup> MABS: Multi Atlas Brain Segmentation

# pnlpipe containers

This repository provides recipes for building [*pnlpipe* software](https://github.com/pnlbwh/pnlpipe_software) containers.
The containers contain the following software:

* Python=3.6
* ANTs=2.3.0
* BRAINSTools
* UKFTractography
* tract_querier
* dcm2niix
* trainingDataT1AHCC
* trainingDataT2Masks
* whitematteranalysis

*pnlpipe* pipeline depends on two other software, installation of which requires you to agree to their license terms:

* [FreeSurfer](https://surfer.nmr.mgh.harvard.edu/fswiki/DownloadAndInstall) 7.1.0
* [FSL](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FslInstallation) 6.0.1

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

    docker run --rm -v /host/path/to/freesurfer/license.txt:/home/pnlbwh/freesurfer-7.1.0/license.txt \
    -v /host/path/to/myData:/home/pnlbwh/myData \
    -v /host/path/to/IITmean_b0_256.nii.gz:/home/pnlbwh/CNN-Diffusion-MRIBrain-Segmentation/model_folder/IITmean_b0_256.nii.gz \
    tbillah/pnlpipe \
    "nifti_atlas -t /home/pnlbwh/myData/t1w.nii.gz -o /home/pnlbwh/myData/t1Mask --train /home/pnlbwh/myData/yourTrainingT1Masks.csv"

* Please make sure to enclose your command within double quotes--`"nifti_atlas ..."`.
* `-v /host/path/to/myData:/home/pnlbwh/data` is for mounting your data into the container so you can analyze.
* If you would like an interactive shell into the container, use `docker run --rm -ti ...` and omit the command in `" "`.


## Singularity

(i) Download pre-built singularity image from our Dropbox:

    wget https://www.dropbox.com/s/8qtqjisfnv5t9i5/pnlpipe.sif

Because of limited storage quota, it could not be hosted in https://cloud.sylabs.io/library/.


(ii) Process your data:

    singularity run --bind /host/path/to/freesurfer/license.txt:/home/pnlbwh/freesurfer-7.1.0/license.txt \
    --bind /host/path/to/IITmean_b0_256.nii.gz:/home/pnlbwh/CNN-Diffusion-MRIBrain-Segmentation/model_folder/IITmean_b0_256.nii.gz \
    --bind /host/path/to/myData:/home/pnlbwh/myData \
    pnlpipe.sif \
    nifti_atlas -t /home/pnlbwh/myData/t1w.nii.gz -o /home/pnlbwh/myData/t1Mask --train /home/pnlbwh/myData/yourTrainingT1Masks.csv

* Notice that you do NOT need to enclose your command within double quotes.
* `--bind` is for mounting your data into the container so you can analyze. Singularity mounts `$HOME` directory by default. 
So, if your data is in any subdirectory of `$HOME`, you should NOT need to mount them.
* If you would like an interactive shell into the container, use `singularity shell ...` and omit the command to run. 
Once inside the shell, you might want to set `alias ls='ls --color'` in the first place.
* While trying to analyze data, if you run into write permission issue, use the `singularity run --writable-tmpfs ...`.



# Programs

All *pnlpipe* scripts and executables are available to `docker run ...` and `singularity run ...`. 
You may learn more about them in the corresponding tutorials:

*pnlNipype* https://github.com/pnlbwh/pnlNipype/blob/master/docs/TUTORIAL.md

*pnlpipe*   https://github.com/pnlbwh/pnlpipe

    

# Citation

If *pipeline* containers are useful in your research, please cite as below:

Billah, Tashrif*; Eckbo, Ryan*; Bouix, Sylvain; Norton, Isaiah; Processing pipeline for anatomical and diffusion weighted images, 
https://github.com/pnlbwh/pnlpipe, 2018, DOI: 10.5281/zenodo.2584271


# Tests

Once inside the container, you can test its functionality with:

> atlas.py --help

> UKFTractography --help

> DWIConvert --help


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


### ANTs from source

Only one additional library should be required:

    yum -y install zlib-devel

