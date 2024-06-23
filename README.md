<div align="center">
  <a href="https://en.wiktionary.org/wiki/%E7%9C%BC" target="_blank">
    <img src="docs/images/clair3_trio_nova.png" width = "90" height = "90" alt="Clair3-Trio Logo">
  </a>
</div>

# Clair3-Nova: Accurate Nanopore long-read <em>de novo</em> variant calling in family trios with deep neural networks 

[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause) [![install with docker](https://img.shields.io/badge/install%20with-docker-blue)](https://hub.docker.com/r/hkubal/clair3-nova)


Contact: Ruibang Luo, Junhao Su  
Email: rbluo@cs.hku.hk, jhsu@cs.hku.hk  

Clair3-Nova is the 2nd generation of [Clair3-Trio](https://github.com/HKU-BAL/Clair3-Trio). Nova supports _de novo_ variant calling in trio. To cite Clair3-Nova, please cite [Clair3-trio (Briefing in Bioinformatics, 2022)](https://academic.oup.com/bib/article/23/5/bbac301/6645484).

----

## Contents

* [Latest Updates](#latest-updates)
* [Pre-trained Models](#pre-trained-models)
* [Quick Demo](docs/trio/trio_quick_demo.md)
* [Installation](#installation)
  + [Option 1. Docker pre-built image](#option-1-docker-pre-built-image)
  + [Option 2. Build an anaconda virtual environment](#option-2-build-an-anaconda-virtual-environment)
  + [Option 3. Docker Dockerfile](#option-3-docker-dockerfile)
* [General Usage](#general-usage)
* [Options](#options)
* [Output Files](#output-files)
* [How to get high-quality de novo variants from the output](#how-to-get-high-quality-de-novo-variants-from-the-output)
* [Model Training](docs/trio/nova_training.md)
----

## Latest Updates
*v0.3 (June 23, 2024)*: add r10.4.1 hac model and add base_err feature
1. add r10 HAC model trained at HG002 trio
2. add `--base_err` [flag](https://github.com/HKU-BAL/Clair3/issues/220) for reducing "./." in gvcf output
3. add `--keep_iupac_bases` [flag](https://en.wikipedia.org/wiki/International_Union_of_Pure_and_Applied_Chemistry) to showing iupac char.

*v0.2.1 (May 15, 2024)*: fix bugs of SelectCandidates_Trio.

*v0.2 (Apr 2, 2024)*: added models for r10.4.1 and r9.4.1

*v0.1 (Feb 6, 2024)*: Initial release.

----

## Pre-trained Models

Download models from [here](http://www.bio8.cs.hku.hk/clair3_trio/clair3_nova_models/) or click on the links below.

|           Model name           |  Platform   |    Training samples         |   Date   |  Basecaller  | File    |          Link            |
| :----------------------------: | :---------: | :----------------------------------------------------------: | -------------------------------- | :--------------------------: | ----------------| :-------------------: |
|   r1041_e82_400bps_sup_nova |     ONT r10.4.1 E8.2 (5kHz)    |                         HG002,3,4      |             20240206 | Dorado v4.0.0 SUP | r1041_e82_400bps_sup_nova.tar.gz      | [Download](http://www.bio8.cs.hku.hk/clair3_trio/clair3_nova_models/r1041_e82_400bps_sup_nova.tar.gz) |
|   r1041_e82_400bps_hac_nova |     ONT r10.4.1 E8.2 (5kHz)    |                         HG002,3,4      |             20240723 | Dorado v4.0.0 HAC | r1041_e82_400bps_hac_nova.tar.gz      | [Download](http://www.bio8.cs.hku.hk/clair3_trio/clair3_nova_models/r1041_e82_400bps_hac_nova.tar.gz) |
|   r941_prom_sup_g5014_nova |     ONT r9.4.1 |                         HG002,3,4      |             20240330 | Guppy5 sup| r941_prom_sup_g5014_nova.tar.gz      | [Download](http://www.bio8.cs.hku.hk/clair3_trio/clair3_nova_models/r941_prom_sup_g5014_nova.tar.gz) |



### Clair3's Pre-trained Models

When using the Clair3-Nova model, please use a corresponding Clair3 model for Pileup calling. Check [here](https://github.com/HKU-BAL/Clair3#pre-trained-models) or [here](https://github.com/nanoporetech/rerio) for more information about Clair3 pretrained model.

|           Model name           |  Platform   |                       Training samples                       | Date   |  Basecaller  | File                                |                             Link                             |
| :----------------------------: | :---------: | :----------------------------------------------------------: | -------------------------------- | :--------------------------: | ----------------------------------- | :----------------------------------------------------------: |
|  r1041_e82_400bps_sup_v430  |     ONT r10.4.1 E8.2 (5kHz)  |       -   | - |  Dorado v4.3.0 SUP | r1041_e82_400bps_sup_v430.tar.gz          | [Download](http://www.bio8.cs.hku.hk/clair3_trio/clair3_models/r1041_e82_400bps_sup_v430.tar.gz) |
|  r1041_e82_400bps_hac_v430  |     ONT r10.4.1 E8.2 (5kHz)  |       -   | - |  Dorado v4.3.0 HAC | r1041_e82_400bps_hac_v430.tar.gz          | [Download](http://www.bio8.cs.hku.hk/clair3_trio/clair3_models/r1041_e82_400bps_hac_v430.tar.gz) |
|  r941_prom_sup_g5014 |     ONT r9.4.1 |       -   | - |  Guppyu5 sup | r941_prom_sup_g5014.tar.gz          | [Download](http://www.bio8.cs.hku.hk/clair3_trio/clair3_models/r941_prom_sup_g5014.tar.gz) |

----

## Installation

### Option 1. Docker pre-built image

A pre-built docker image is available [here](https://hub.docker.com/r/hkubal/clair3-nova). With it you can run Clair3-Nova using a single command.

Caution: Absolute path is needed for both `INPUT_DIR` and `OUTPUT_DIR`.

```bash
INPUT_DIR="[YOUR_INPUT_FOLDER]"            # e.g. /input
REF=${_INPUT_DIR}/ref.fa                   # change your reference file name here
OUTPUT_DIR="[YOUR_OUTPUT_FOLDER]"          # e.g. /output
THREADS="[MAXIMUM_THREADS]"                # e.g. 8
MODEL_C3="[Clair3 MODEL NAME]"         	   # e.g. Clair3 model, e.g. r1041_e82_400bps_sup_v430
MODEL_C3D="[Clair3-Trio MODEL NAME]"       # e.g. Clair3-Nova model, r1041_e82_400bps_sup_nova

docker run -it \
  -v ${INPUT_DIR}:${INPUT_DIR} \
  -v ${OUTPUT_DIR}:${OUTPUT_DIR} \
  hkubal/clair3-nova:latest \
  /opt/bin/run_clair3_nova.sh \
  --ref_fn=${INPUT_DIR}/ref.fa \                  ## change your reference file name here
  --bam_fn_c=${INPUT_DIR}/child_input.bam \       ## change your child's bam file name here 
  --bam_fn_p1=${INPUT_DIR}/parent1_input.bam \    ## change your parent-1's bam file name here     
  --bam_fn_p2=${INPUT_DIR}/parenet2_input.bam \   ## change your parent-2's bam file name here   
  --sample_name_c=${SAMPLE_C} \                   ## change your child's name here
  --sample_name_p1=${SAMPLE_P1} \                 ## change your parent-1's name here
  --sample_name_p2=${SAMPLE_P2} \                 ## change your parent-2's name here
  --threads=${THREADS} \                          ## maximum threads to be used
  --model_path_clair3="/opt/models/clair3_models/${MODEL_C3}" \
  --model_path_clair3_nova="/opt/models/clair3_nova_models/${MODEL_C3D}" \
  --output=${OUTPUT_DIR}                          ## absolute output path prefix 

```


### Option 2. Build an anaconda virtual environment

**Anaconda install**:

Please install anaconda using the official [guide](https://docs.anaconda.com/anaconda/install) or using the commands below:

```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod +x ./Miniconda3-latest-Linux-x86_64.sh 
./Miniconda3-latest-Linux-x86_64.sh
```

**Install Clair3 env and Clair3-Nova using anaconda step by step:**


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

# clone Clair3-Nova
git clone https://github.com/HKU-BAL/Clair3-Nova.git
cd Clair3-Nova

# download Clair3's pre-trained models
mkdir -p models/clair3_models
wget http://www.bio8.cs.hku.hk/clair3_trio/clair3_models/clair3_models.tar.gz 
tar -zxvf clair3_models.tar.gz -C ./models/clair3_models

# download Clair3-Nova's pre-trained models
mkdir -p models/clair3_nova_models
wget http://www.bio8.cs.hku.hk/clair3_trio/clair3_nova_models/clair3_nova_models.tar.gz 
tar -zxvf clair3_nova_models.tar.gz -C ./models/clair3_nova_models

# run clair3-nova
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
_MODEL_DIR_C3="[Clair3 MODEL NAME]"         # e.g. ./models/clair3_models/r1041_e82_400bps_sup_v430
_MODEL_DIR_C3D="[Clair3-Nova MODEL NAME]"   # e.g. ./models/clair3_nova_models/r1041_e82_400bps_sup_nova

./run_clair3_nova.sh \
  --bam_fn_c=${_BAM_C} \    
  --bam_fn_p1=${_BAM_P1} \
  --bam_fn_p2=${_BAM_P2} \
  --output=${_OUTPUT_DIR} \
  --ref_fn=${_REF} \
  --threads=${_THREADS} \
  --model_path_clair3="${_MODEL_DIR_C3}" \
  --model_path_clair3_nova="${_MODEL_DIR_C3D}" \
  --sample_name_c=${_SAMPLE_C} \
  --sample_name_p1=${_SAMPLE_P1} \
  --sample_name_p2=${_SAMPLE_P2}

```

### Option 3. Docker Dockerfile

Building a docker image.
```
# clone Clair3-Nova
git clone https://github.com/hku-bal/Clair3-Nova.git
cd Clair3-Nova

# build a docker image named hkubal/clair3-nova:latest
# might require docker authentication to build docker image 
docker build -f ./Dockerfile -t hkubal/clair3-nova:latest .

# run clair3-docker image like 
docker run -it hkubal/clair3-nova:latest /opt/bin/run_clair3_nova.sh --help
```

### General Usage

**Caution**:  Use `=value` for optional parameters, e.g. `--bed_fn=fn.bed` instead of `--bed_fn fn.bed`.

```bash

./run_clair3_nova.sh \
  --bam_fn_c=${_BAM_C} \    
  --bam_fn_p1=${_BAM_P1} \
  --bam_fn_p2=${_BAM_P2} \
  --output=${_OUTPUT_DIR} \
  --ref_fn=${_REF} \
  --threads=${_THREADS} \
  --model_path_clair3="${_MODEL_DIR_C3}" \
  --model_path_clair3_nova="${_MODEL_DIR_C3D}" \
  --sample_name_c=${_SAMPLE_C} \
  --sample_name_p1=${_SAMPLE_P1} \
  --sample_name_p2=${_SAMPLE_P2}

```

### Options

**Required parameters:**

```bash
--bam_fn_c=FILE                BAM file input, for child. The input file must be samtools indexed.
--bam_fn_p1=FILE               BAM file input, for parent1. The input file must be samtools indexed.
--bam_fn_p2=FILE               BAM file input, for parent1. The input file must be samtools indexed.
--ref_fn=FILE                  FASTA reference file input. The input file must be samtools indexed.
--model_path_clair3=STR        The folder path containing a Clair3 model (requiring six files in the folder, including pileup.data-00000-of-00002, pileup.data-00001-of-00002 pileup.index, full_alignment.data-0000
0-of-00002, full_alignment.data-00001-of-00002  and full_alignment.index).                                                                                                                                      
--model_path_clair3_nova=STR   The folder path containing a Clair3-Nova model (files structure same as Clair3).                                                                            
-t, --threads=INT              Max #threads to be used. The full genome will be divided into small chunks for parallel processing. Each chunk will use 4 threads. The #chunks being processed simultaneously is ceil
(#threads/4)*3. 3 is the overloading factor.                                                              
-o, --output=PATH              VCF/GVCF output directory. 

```

**Other parameters:**

**Caution**:  Use `=value` for optional parameters, e.g., `--bed_fn=fn.bed` instead of `--bed_fn fn.bed`

```bash
-v, --version                  Check Clair3-Nova version
-h, --help                     Check Clair3-Nova help page
--bed_fn=FILE                  Call variants only in the provided bed regions.
--vcf_fn=FILE                  Candidate sites VCF file input, variants will only be called at the sites in the VCF file if provided.
--ctg_name=STR                 The name of the sequence to be processed.
--pileup_only                  Use the pileup model only when calling, default: disable.
--pileup_phasing               Use the pileup model calling and phasing, default: disable.
--sample_name_c=STR            Define the sample name for Child to be shown in the VCF file.[Child]
--sample_name_p1=STR           Define the sample name for Parent1 to be shown in the VCF file.[Parent1]
--sample_name_p2=STR           Define the sample name for Parent2 to be shown in the VCF file.[Parent2]
--gvcf                         Enable GVCF output, default: disable.
--qual=INT                     If set, variants with >=$qual will be marked PASS, or LowQual otherwise.
--samtools=STR                 Path of samtools, samtools version >= 1.10 is required.
--python=STR                   Path of python, python3 >= 3.6 is required.
--pypy=STR                     Path of pypy3, pypy3 >= 3.6 is required.
--parallel=STR                 Path of parallel, parallel >= 20191122 is required.
--whatshap=STR                 Path of whatshap, whatshap >= 1.0 is required.
--chunk_size=INT               The size of each chuck for parallel processing, default: 5000000.
--print_ref_calls              Show reference calls (0/0) in VCF file, default: disable.
--include_all_ctgs             Call variants on all contigs, otherwise call in chr{1..22,X,Y} and {1..22,X,Y}, default: disable.
--snp_min_af=FLOAT             Minimum SNP AF required for a candidate variant. Lowering the value might increase a bit of sensitivity in trade of speed and accuracy, default: ont:0.08.
--indel_min_af=FLOAT           Minimum Indel AF required for a candidate variant. Lowering the value might increase a bit of sensitivity in trade of speed and accuracy, default: ont:0.15.
--nova_model_prefix=STR        Model prefix in trio & nova calling, including $prefix.data-00000-of-00002, $prefix.data-00001-of-00002 $prefix.index, default: nova.
--enable_output_phasing        Output phased variants using whatshap, default: disable.
--enable_output_haplotagging   Output enable_output_haplotagging BAM variants using whatshap, default: disable.
--enable_phasing               It means `--enable_output_phasing`. The option is retained for backward compatibility.
--var_pct_full=FLOAT           EXPERIMENTAL: Specify an expected percentage of low quality 0/1 and 1/1 variants called in the pileup mode for full-alignment mode calling, default: 0.3.
--ref_pct_full=FLOAT           EXPERIMENTAL: Specify an expected percentage of low quality 0/0 variants called in the pileup mode for full-alignment mode calling, default:  0.1 .
--var_pct_phasing=FLOAT        EXPERIMENTAL: Specify an expected percentage of high quality 0/1 variants used in WhatsHap phasing, default: 0.8 for ont guppy5 and 0.7 for other platforms.
--pileup_model_prefix=STR      EXPERIMENTAL: Model prefix in pileup calling, including $prefix.data-00000-of-00002, $prefix.data-00001-of-00002 $prefix.index. default: pileup.
--keep_iupac_bases             EXPERIMENTAL: Keep IUPAC reference and alternate bases, default: convert all IUPAC bases to N.
--base_err=FLOAT               EXPERIMENTAL: Estimated base error rate when enabling gvcf option, default: 0.05 (set smaller will increase reduce the number of ./. output).
--gq_bin_size=INT              EXPERIMENTAL: Default gq bin size for merge non-variant block when enabling gvcf option, default: 5.

```

## Output Files

Clair3-Nova outputs files in VCF/GVCF format for the trio & de novo genotype. The output files (for a trio [C ], [P1], [P2]) including:

    .
    ├── run_clair3_nova.log		        # Clair3-Nova running log
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



## How to get high-quality de novo variants from the output


```bash
# input: clair3-nova's output of ${SAMPLE[0]}.vcf.gz, ${SAMPLE[1]}.vcf.gz, ${SAMPLE[2]}.vcf.gz files
# output: merged vcf and de novo variants

# requires bcftools and rtg tools
# install bcftools: https://github.com/samtools/bcftools
# install rtg tools: https://github.com/RealTimeGenomics/rtg-tools
BCFTOOLS=bcftools
RTG=rtg

# input files
# requires trio's ped file, reference sdf file
# example input
_TRIO_PED=/autofs/bal31/jhsu/home/data/giab/trio.ped  
cat $_TRIO_PED
    #PED format pedigree
    #
    #fam-id/ind-id/pat-id/mat-id: 0=unknown
    #sex: 1=male; 2=female; 0=unknown
    #phenotype: -9=missing, 0=missing; 1=unaffected; 2=affected
    #
    #fam-id ind-id pat-id mat-id sex phen
    1 HG002 HG003 HG004 1 0
    1 HG003 0 0 1 0
    1 HG004 0 0 2 0
# your reference sdf file path
REF_SDF_FILE_PATH=./GCA_000001405.15_GRCh38_no_alt_analysis_set.sdf

# output files
# merged and de novo vcfs
M_VCF=trio_m.vcf.gz
M_VCF_annotated=trio_m_ann.vcf.gz
denovo_VCF=trio_all_denovo.vcf.gz
denovo_VCF_sf=trio_high_quality_denovo.vcf.gz

# merge trio vcfs
${BCFTOOLS} merge ${SAMPLE[0]}.vcf.gz \
${SAMPLE[1]}.vcf.gz \
${SAMPLE[2]}.vcf.gz \
--threads 32 -f PASS -0 -m all| ${BCFTOOLS} view -O z -o ${M_VCF}

# index
${BCFTOOLS} index ${M_VCF}
#${BCFTOOLS} view ${M_VCF} -H | wc -l

# annotate with Mendelian inherrtance pattern
${RTG} mendelian -i ${M_VCF} -o ${M_VCF_annotated} --pedigree ${_TRIO_PED} -t ${REF_SDF_FILE_PATH} |& tee MDL.log

# get de novo variants
${BCFTOOLS} view -i 'INFO/MCV ~ "0/0+0/0->0/1"' ${M_VCF_annotated} -O z -o ${denovo_VCF}
${BCFTOOLS} index ${denovo_VCF}
# get high quality de novo variants
${BCFTOOLS} view -i "INFO/DNP>0.85" ${denovo_VCF} -s ${SAMPLE[0]} -O z -o ${denovo_VCF_sf}
${BCFTOOLS} index ${denovo_VCF_sf}
# high quality de novo variants set is in ${denovo_VCF_sf}
```
