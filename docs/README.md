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

Table of Contents created by [gh-md-toc](https://github.com/ekalinin/github-markdown-toc)


# pnlpipe containers

The *pnlpipe* docker container is publicly hosted at [https://cloud.docker.com/u/tbillah/repository/docker/tbillah/pnlpipe](https://cloud.docker.com/u/tbillah/repository/docker/tbillah/pnlpipe)

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
this images.

Furthermore, if you want to use our CNN-Diffusion-MRIBrain-Segmentation tool, you must download IITmean_b0_256.nii.gz 
locally and mount into this image:

    wget https://www.nitrc.org/frs/download.php/11290/IITmean_b0_256.nii.gz


## Docker

    docker run --rm -v /host/path/to/freesurfer/license.txt:/home/pnlbwh/freesurfer-7.1.0/license.txt \
    -v /host/path/to/myData:/home/pnlbwh/myData \
    -v /host/path/to/IITmean_b0_256.nii.gz:/home/pnlbwh/CNN-Diffusion-MRIBrain-Segmentation/model_folder/ \
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


