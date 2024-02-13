# Clair3-Denovo: <em>de novo</em> variant calling in trio using Nanopore long-reads


[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)  [![install with bioconda](https://img.shields.io/badge/install%20with-bioconda-brightgreen.svg?style=flat)](http://bioconda.github.io/recipes/clair3-trio/README.html) [![install with docker](https://img.shields.io/badge/install%20with-docker-blue)](https://hub.docker.com/r/hkubal/clair3-trio)


Contact: Ruibang Luo, Junhao Su  
Email: rbluo@cs.hku.hk, jhsu@cs.hku.hk  

----

## Introduction

TBC


----

## Contents

* [Latest Updates](#latest-updates)
* [What's New in Clair3-Denovo](#whats-new-in-clair3-denovo)
* [Pre-trained Models](#pre-trained-models)
* [Quick Demo](docs/trio/trio_quick_demo.md)
* [Installation](#installation)
  + [Option 1. Docker pre-built image](#option-1-docker-pre-built-image)
  + [Option 2. Singularity](#option-2-singularity)
  + [Option 3. Build an anaconda virtual environment](#option-3-build-an-anaconda-virtual-environment)
  + [Option 4. Bioconda](#option-4-bioconda)
  + [Option 5. Docker Dockerfile](#option-5-docker-dockerfile)

----

## Latest Updates

*v0.1 (Feb 6, 2024)*: Initial release.

---

## What's New in Clair3-Denovo

TBC


----

## Pre-trained Models

Download models from [here](http://www.bio8.cs.hku.hk/clair3_trio/clair3_denovo_models/) or click on the links below.

|           Model name           |  Platform   |    Training samples         |   Date   |  Basecaller  | File    |          Link            |
| :----------------------------: | :---------: | :----------------------------------------------------------: | -------------------------------- | :--------------------------: | ----------------| :-------------------: |
|   r1041_e82_400bps_sup_denovo |     ONT 10.4.1    |                         HG002,3,4      |             20240206 | Dorado v4.0.0 SUP | r1041_e82_400bps_sup_denovo.tar.gz      | [Download](http://www.bio8.cs.hku.hk/clair3_trio/clair3_denovo_models/r1041_e82_400bps_sup_denovo.tar.gz) |



### Clair3's Pre-trained Models

When using the Clair3-Denovo model, please use a corresponding Clair3 model for Pileup calling. Check [here](https://github.com/HKU-BAL/Clair3#pre-trained-models) or [here](https://github.com/nanoporetech/rerio) for more information about Clair3 pretrained model.

|           Model name           |  Platform   |                       Training samples                       | Date   |  Basecaller  | File                                |                             Link                             |
| :----------------------------: | :---------: | :----------------------------------------------------------: | -------------------------------- | :--------------------------: | ----------------------------------- | :----------------------------------------------------------: |
|  r1041_e82_400bps_sup_v430  |     ONT r10.4.1 E8.2 (5kHz)  |                    HG002,4,5  | - |  Dorado v4.3.0 SUP | r1041_e82_400bps_sup_v430.tar.gz          | [Download](http://www.bio8.cs.hku.hk/clair3_trio/clair3_models/r1041_e82_400bps_sup_v430.tar.gz) |


----


## Installation

### Option 1. Docker pre-built image

A pre-built docker image is available [here](https://hub.docker.com/r/hkubal/clair3-denovo). With it you can run Clair3-Denovo using a single command.

Caution: Absolute path is needed for both `INPUT_DIR` and `OUTPUT_DIR`.

```bash
INPUT_DIR="[YOUR_INPUT_FOLDER]"            # e.g. /input
REF=${_INPUT_DIR}/ref.fa                   # change your reference file name here
OUTPUT_DIR="[YOUR_OUTPUT_FOLDER]"          # e.g. /output
THREADS="[MAXIMUM_THREADS]"                # e.g. 8
MODEL_C3="[Clair3 MODEL NAME]"         	   # e.g. Clair3 model, e.g. r1041_e82_400bps_sup_v430
MODEL_C3D="[Clair3-Trio MODEL NAME]"       # e.g. Clair3-Denovo model, r1041_e82_400bps_sup_denovo


docker run -it \
  -v ${INPUT_DIR}:${INPUT_DIR} \
  -v ${OUTPUT_DIR}:${OUTPUT_DIR} \
  hkubal/clair3-denovo:latest \
  /opt/bin/run_clair3_denovo.sh \
  --ref_fn=${INPUT_DIR}/ref.fa \                  ## change your reference file name here
  --bam_fn_c=${INPUT_DIR}/child_input.bam \       ## change your child's bam file name here 
  --bam_fn_p1=${INPUT_DIR}/parent1_input.bam \    ## change your parent-1's bam file name here     
  --bam_fn_p2=${INPUT_DIR}/parenet2_input.bam \   ## change your parent-2's bam file name here   
  --sample_name_c=${SAMPLE_C} \                   ## change your child's name here
  --sample_name_p1=${SAMPLE_P1} \                 ## change your parent-1's name here
  --sample_name_p2=${SAMPLE_P2} \                 ## change your parent-2's name here
  --threads=${THREADS} \                          ## maximum threads to be used
  --model_path_clair3="/opt/models/clair3_models/${MODEL_C3}" \
  --model_path_clair3_denovo="/opt/models/clair3_denovo_models/${MODEL_C3D}" \
  --output=${OUTPUT_DIR}                          ## absolute output path prefix 

```

### Option 2. Singularity


TBC


### Option 3. Build an anaconda virtual environment

**Anaconda install**:

Please install anaconda using the official [guide](https://docs.anaconda.com/anaconda/install) or using the commands below:

```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod +x ./Miniconda3-latest-Linux-x86_64.sh 
./Miniconda3-latest-Linux-x86_64.sh
```

**Install Clair3 env and Clair3-Denovo using anaconda step by step:**


```bash
# create and activate an environment named clair3
conda create -n clair3 python=3.9.0 -y
source activate clair3

# install pypy and packages in the environemnt
conda install -c conda-forge pypy3.6 -y
pypy3 -m ensurepip
pypy3 -m pip install mpmath==1.2.1

# install python packages in environment
conda install -c conda-forge tensorflow==2.8.0 -y
conda install -c conda-forge pytables -y
conda install -c anaconda pigz cffi==1.14.4 -y
conda install -c conda-forge parallel=20191122 zstd -y
conda install -c conda-forge -c bioconda samtools=1.15.1 -y
conda install -c conda-forge -c bioconda whatshap=1.7 -y
conda install -c conda-forge xz zlib bzip2 automake curl -y
# tensorflow-addons is required in training
pip install tensorflow-addons

# clone Clair3-Denovo
git clone https://github.com/HKU-BAL/Clair3-Denovo.git
cd Clair3-Denovo

# download Clair3's pre-trained models
mkdir -p models/clair3_models
wget http://www.bio8.cs.hku.hk/clair3_trio/clair3_models/clair3_models.tar.gz 
tar -zxvf clair3_models.tar.gz -C ./models/clair3_models


# download Clair3-Denovo's pre-trained models
mkdir -p models/clair3_denovo_models
wget http://www.bio8.cs.hku.hk/clair3_trio/clair3_denovo_models/clair3_denovo_models.tar.gz 
tar -zxvf clair3_denovo_models.tar.gz -C ./models/clair3_denovo_models


# run clair3-denovo
_INPUT_DIR="[YOUR_INPUT_FOLDER]"            # e.g. ./input
_BAM_C=${_INPUT_DIR}/input_child.bam        # chnage your child's bam file name here
_BAM_P1=${_INPUT_DIR}/input_parent1.bam     # chnage your parent-1's bam file name here
_BAM_P2=${_INPUT_DIR}/input_parent2.bam     # chnage your parent-2's bam file name here
_SAMPLE_C="[Child sample ID]"               # child sample ID, e.g. HG002
_SAMPLE_P1="[Parent1 sample ID]"            # parent1 sample ID, e.g. HG003
_SAMPLE_P2="[Parent2 sample ID]"            # parent2 sample ID, e.g. HG004
_REF=${_INPUT_DIR}/ref.fa                   # change your reference file name here
_OUTPUT_DIR="[YOUR_OUTPUT_FOLDER]"          # e.g. ./output
_THREADS="[MAXIMUM_THREADS]"                # e.g. 8
_MODEL_DIR_C3="[Clair3 MODEL NAME]"         # e.g. ./models/clair3_models/ont
_MODEL_DIR_C3D="[Clair3-Denovo MODEL NAME]"   # e.g. ./models/clair3_denovo_models/c3t_hg002_g422

./run_clair3_trio.sh \
  --bam_fn_c=${_BAM_C} \    
  --bam_fn_p1=${_BAM_P1} \
  --bam_fn_p2=${_BAM_P2} \
  --output=${_OUTPUT_DIR} \
  --ref_fn=${_REF} \
  --threads=${_THREADS} \
  --model_path_clair3="${_MODEL_DIR_C3}" \
  --model_path_clair3_trio="${_MODEL_DIR_C3T}" \
  --sample_name_c=${_SAMPLE_C} \
  --sample_name_p1=${_SAMPLE_P1} \
  --sample_name_p2=${_SAMPLE_P2}

```
### Option 4. Bioconda


```bash
# make sure channels are added in conda
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge

# create conda environment named "clair3-denovo"
conda create -n clair3-denovo -c bioconda clair3-denovo python=3.6.10 -y
conda activate clair3-denovo

# run clair3-denovo like this afterward
_INPUT_DIR="[YOUR_INPUT_FOLDER]"            # e.g. ./input
_BAM_C=${_INPUT_DIR}/input_child.bam        # chnage your child's bam file name here
_BAM_P1=${_INPUT_DIR}/input_parent1.bam     # chnage your parent-1's bam file name here
_BAM_P2=${_INPUT_DIR}/input_parent2.bam     # chnage your parent-2's bam file name here
_SAMPLE_C="[Child sample ID]"               # child sample ID, e.g. HG002
_SAMPLE_P1="[Parent1 sample ID]"            # parent1 sample ID, e.g. HG003
_SAMPLE_P2="[Parent2 sample ID]"            # parent2 sample ID, e.g. HG004
_REF=${_INPUT_DIR}/ref.fa                   # change your reference file name here
_OUTPUT_DIR="[YOUR_OUTPUT_FOLDER]"          # e.g. ./output
_THREADS="[MAXIMUM_THREADS]"                # e.g. 8
_MODEL_DIR_C3="[Clair3 MODEL NAME]"         # e.g. r1041_e82_400bps_sup_v430
_MODEL_DIR_C3D="[Clair3-Denovo MODEL NAME]"   # e.g. r1041_e82_400bps_sup_denovo

run_clair3_denovo.sh \
  --bam_fn_c=${_BAM_C} \    
  --bam_fn_p1=${_BAM_P1} \
  --bam_fn_p2=${_BAM_P2} \
  --output=${_OUTPUT_DIR} \
  --ref_fn=${_REF} \
  --threads=${_THREADS} \
  --model_path_clair3="${CONDA_PREFIX}/bin/models/${_MODEL_DIR_C3}" \ 
  --model_path_clair3_denovo="${CONDA_PREFIX}/bin/models/${_MODEL_DIR_C3D}" \ 
  --sample_name_c=${_SAMPLE_C} \
  --sample_name_p1=${_SAMPLE_P1} \
  --sample_name_p2=${_SAMPLE_P2}
```



### Option 5. Docker Dockerfile

Building a docker image.
```
# clone Clair3-Denovo
git clone https://github.com/hku-bal/Clair3-Denovo.git
cd Clair3-Denovo

# build a docker image named hkubal/clair3-denovo:latest
# might require docker authentication to build docker image 
docker build -f ./Dockerfile -t hkubal/clair3-denovo:latest .

# run clair3-trio docker image like 
docker run -it hkubal/clair3-denovo:latest /opt/bin/run_clair3_denovo.sh --help
```


## Output Files

Clair3-Denovo outputs files in VCF/GVCF format for the trio & de novo genotype. The output files (for a trio [C ], [P1], [P2]) including:

    .
    ├── run_clair3_denovo.log		        # Clair3-Denovo running log
    ├── [C ].vcf.gz				# Called variants in vcf format for [C ]
    ├── [P1].vcf.gz				# Called variants in vcf format for [P1]
    ├── [P2].vcf.gz				# Called variants in vcf format for [P2]
    ├── [C ].gvcf.gz			# Called variants in gvcf format for [C ] (when enabled `--gvcf`)
    ├── [P1].gvcf.gz			# Called variants in gvcf format for [P2] (when enabled `--gvcf`)
    ├── [P2].gvcf.gz			# Called variants in gvcf format for [P2] (when enabled `--gvcf`)
    ├── phased_[C ].vcf.gz			# Called phased variants for [C ] (when enabled `--enable_output_phasing`)		
    ├── phased_[P1].vcf.gz			# Called phased variants for [P1] (when enabled `--enable_output_phasing`)		
    ├── phased_[P2].vcf.gz			# Called phased variants for [P2] (when enabled `--enable_output_phasing`)		
    ├── phased_[C ].bam			# alignment tagged with phased variants info. for [C ] (when enabled `--enable_output_haplotagging`)		
    ├── phased_[P1].bam			# alignment tagged with phased variants info. for [P1] (when enabled `--enable_output_haplotagging`)		
    ├── phased_[P2].bam			# alignment tagged with phased variants info. for [P2] (when enabled `--enable_output_haplotagging`)		
    ├── /log				# folder for detailed running log
    └── /tmp				# folder for all running temporary files 


