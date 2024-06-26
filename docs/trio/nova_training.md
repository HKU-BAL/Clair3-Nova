# Train a model for Clair3-nova calling

---

June 23, 2024

Clair3-Nova requires a pileup model, the training procedure of which is identical to Clair3, and a nova model, the training procedure of which is shown below. The pileup model can be obtained from [pre-trained](https://github.com/HKU-BAL/Clair3#pre-trained-models) and the training guide is at [here](../pileup_training.md). The nova model's training procedure is shown below, and the example provided uses the GIAB Ashkenazim Trio (HG002/3/4) as input. To get started, it's recommended that you modify the following helper scripts below to train a nova model.




- [0_generate_trio_bed.sh](0_generate_trio_bed.sh)
- [1 representation_unification_trio.md](representation_unification_trio.md)
- [2_generate_downsample_phased_bam](2_gen_downsample_phased_bam_p.sh)
- [3_generate_downsample_pileup.sh](3_generate_downsample_pileup.sh)
- [4.1_create tensors for equal depths](4_create_tensors.sh)
- [4.2_create tensors for diverse depths](4_create_tensors_sub.sh)
- [4.3_create tensors for de novo cases](4_create_tensors_denovo.sh)
- [4.4_downsample_tensors.sh](4_1_downsample_bin.sh)
- [5_train.sh](5_train_all_dn.sh)



To train a trio model, it's recommended to use data with a minimum coverage above 60x, as the downsampling coverage setting in this training procedure is tailored for data above 60x.

If you're using the data with a minimum data coverage of 65x, you can find the best downsampling coverage setting for the data in this section: [[ONT Q20+](#q20-data-configuration)].


---

## Prerequisites

- Clair3 installed
- Clair3-Nova installed
- GNU Parallel installed
- Sufficient hard-disk space
- Truth VCF files with representation unification applied (check [here](representation_unification_trio.md) for steps)
- A high-end GPU

---

## Contents

  - [1. Set variables](#1-set-variables)
  - [2. Run Clair3 pileup model](#2-run-clair3-pileup-model)
  - [3-1 Create and merge trio tensors](#3-1-create-and-merge-trio-tensors)
  - [3-2 Downsample all bins](#3-2-downsample-all-bins)
  - [4. Train a Clair3-Nova model](#4-train-a-clair3-nova-model)

---

## 0. Prepare required files

The input files for training Clair3-Nova model include:

- Reference file: [R]
- child/parents high-confidence BED files for truth variants: [C TRUTH BED], [P1 TRUTH BED], [P2 TRUTH BED]
- BAM and VCF files generated after finishing the steps in [representation_unifivation_trio](https://github.com/HKU-BAL/Clair3-Trio/blob/trio/docs/trio/representation_unification_trio.md) 
  - phased alignment BAM files of child and parents: [C BAM], [P1 BAM], [P2 BAM]
  - child/parents truth VCF files with representation unification applied: [C TRUTH VCF], [P1 TRUTH VCF], [P2 TRUTH VCF]


## 1. Set variables


The trio model requires phased alignments, which are necessary for training it.

Please use this [page](representation_unification_trio.md) to run phasing alignments in all of your family samples.

Note that all samples in the family should be phased before training to ensure the accuracy of the trio model.

```bash
PARALLEL="[WHATSHAP_PATH]"                           # e.g. "parallel"
PYPY="[PYPY_PATH]"                                   # e.g. "pypy3"
SAMTOOLS="[SAMTOOLS_PATH]"                           # e.g. "samtools"
PYTHON3="[PYTHON3_PATH]"                             # e.g. "python3"
THREADS=8                                            # threads number
PLATFORM="ont"                      

# Clair3 folder
_ORI_CLAIR3="[CLAIR3_PATH]"
_MODEL_DIR="[CLAIR3_MODEL_PATH]"
C3_THREADS=8                                         # Clair3 threads number


# Clair3-Nova's path
CLAIR3_Nova="[CLAIR3-NOVA_PATH]/clair3.py"      

# Creating working folder
TRAIN_FOLDER_PREFIX="[YOU_TRAINING_FOLDER]"
BUILD_N="[DATA_BUILDING_NAME]"                       # data building data, e.g. "HG002_all"

# Temporary working directories
TRAIN_FOLDER="${TRAIN_FOLDER_PREFIX}"
mkdir -p ${TRAIN_FOLDER}

DATASET_FOLDER_PATH="${TRAIN_FOLDER}/build/${BUILD_N}"
TENSOR_CANDIDATE_FOLDER_PATH="${DATASET_FOLDER_PATH}/tensor_can"
BINS_FOLDER_PATH="${DATASET_FOLDER_PATH}/bins"
READ_FOLDER_PATH="${DATASET_FOLDER_PATH}/read_info"
INDEL_PATH="${DATASET_FOLDER_PATH}/alt_info"
SPLIT_BED_PATH="${DATASET_FOLDER_PATH}/split_beds"
PHASE_VCF_PATH="${DATASET_FOLDER_PATH}/phased_vcf"
PHASE_BAM_PATH="${DATASET_FOLDER_PATH}/phased_bam"
LOG_PATH="${DATASET_FOLDER_PATH}/log"
PILEUP_OUTPUT_PATH="${DATASET_FOLDER_PATH}/pileup"
mkdir -p ${DATASET_FOLDER_PATH}
mkdir -p ${TENSOR_CANDIDATE_FOLDER_PATH}
mkdir -p ${BINS_FOLDER_PATH}
mkdir -p ${READ_FOLDER_PATH}
mkdir -p ${INDEL_PATH}
mkdir -p ${SPLIT_BED_PATH}
mkdir -p ${PHASE_VCF_PATH}
mkdir -p ${PHASE_BAM_PATH}
mkdir -p ${LOG_PATH}
mkdir -p ${PILEUP_OUTPUT_PATH}
cd ${DATASET_FOLDER_PATH}

# log file suffix name
_LOG_SUF=""                         # log file suffix

# input files and parameters

# sample name
ALL_SAMPLE=(
${CHILD_SAMPLE_N}                   # your child sample name
${P1_SAMPLE_N}                      # your parenet-1 sample name
${P2_SAMPLE_N}                      # your parenet-2 sample name
${CHILD_SAMPLE_N}                   # your child sample name
${P1_SAMPLE_N}                      # your parenet-1 sample name
${P2_SAMPLE_N}                      # your parenet-2 sample name
)

TRIO_N="${CHILD_SAMPLE_N}_TRIO"     # your trio name, e.g. HG002_TRIO

# Note: Here we setting the data coverage as 10x and 30x for example, all following paths of (${ALL_RU_FILE_PATH}, ${ALL_PHASED_BAM_FILE_PATH}, ${ALL_REFERENCE_FILE_PATH}, etc.),  need to be set to ${DEPTHS} accordingly. check the 4_create_tensors.sh for more example

DEPTHS=(                            # data coverage
10
10
10
30
10
10
)

# True variants set from Clair3-Trio Representation Unification
# Each line represents one representation-unified path for each input sample
# Note the all path have a folder called **var_ru**
# Check the representation_unification_trio.md page for more information
# For practical concerns, the representation_unification_trio.md require only run once on the highest depth for each sample, while the low coverage can be sampled from the highest coverage data, i.e. merged.bam in the representation_unification folder

ALL_RU_FILE_PATH=(
"[child representation unified folder]"
"[parent-1 representation unified folder]"
"[parent-2 representation unified folder]"
"[child representation unified folder]"
"[parent-1 representation unified folder]"
"[parent-2 representation unified folder]"
)

# downsampled RU bam
ALL_PHASED_BAM_FILE_PATH=(
"[child representation unified folder]/${CHILD_SAMPLE_N}_10.bam"          
"[parent-1 representation unified folder]/${P1_SAMPLE_N}_10.bam"
"[parent-2 representation unified folder]/${P2_SAMPLE_N}_10.bam"
"[child representation unified folder]/${CHILD_SAMPLE_N}_30.bam"          
"[parent-1 representation unified folder]/${P1_SAMPLE_N}_10.bam"
"[parent-2 representation unified folder]/${P2_SAMPLE_N}_10.bam"
)

ALL_REFERENCE_FILE_PATH=(
"[YOUR_REF_FILE]"
"[YOUR_REF_FILE]"
"[YOUR_REF_FILE]"
"[YOUR_REF_FILE]"
"[YOUR_REF_FILE]"
"[YOUR_REF_FILE]"
)

ALL_ORI_BED_FILE_PATH=(
"[YOUR_BED_FILE_CHILD]"
"[YOUR_BED_FILE_PARENET1]"
"[YOUR_BED_FILE_PARENET2]"
"[YOUR_BED_FILE_CHILD]"
"[YOUR_BED_FILE_PARENET1]"
"[YOUR_BED_FILE_PARENET2]"
)

# training chrosome name, and prefix
CHR=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 21 22)
CHR_PREFIX="chr"

# merge trio's bed file
BED2=${ALL_ORI_BED_FILE_PATH[0]}
BED3=${ALL_ORI_BED_FILE_PATH[1]}
BED4=${ALL_ORI_BED_FILE_PATH[2]}
_TRIO_BED_PATH=${DATASET_FOLDER_PATH}/020304.bed

docker run -v "${_INPUT_DIR}":"${_INPUT_DIR}" biocontainers/bedtools:v2.26.0dfsg-3-deb_cv1 bedtools intersect -a ${BED2} -b ${BED3} > ${_INPUT_DIR}/tmp_out
docker run -v "${_INPUT_DIR}":"${_INPUT_DIR}" biocontainers/bedtools:v2.26.0dfsg-3-deb_cv1 bedtools sort -i ${_INPUT_DIR}/tmp_out > ${_INPUT_DIR}/0203.bed
docker run -v "${_INPUT_DIR}":"${_INPUT_DIR}" biocontainers/bedtools:v2.26.0dfsg-3-deb_cv1 bedtools intersect -a ${_INPUT_DIR}/0203.bed -b ${BED4} > ${_INPUT_DIR}/tmp_out
docker run -v "${_INPUT_DIR}":"${_INPUT_DIR}" biocontainers/bedtools:v2.26.0dfsg-3-deb_cv1 bedtools sort -i ${_INPUT_DIR}/tmp_out > ${_TRIO_BED_PATH}

ALL_BED_FILE_PATH=(
${_TRIO_BED_PATH}
${_TRIO_BED_PATH}
${_TRIO_BED_PATH}
${_TRIO_BED_PATH}
${_TRIO_BED_PATH}
${_TRIO_BED_PATH}
)

```
---

## 2. Run Clair3 pileup model

```
# Run Clair3 pileup model
time ${PARALLEL} -j ${C3_THREADS} --joblog  ${LOG_PATH}/input_pileup${_LOG_SUF}.log ${_ORI_CLAIR3}/run_clair3.sh \
  --bam_fn={5} \
  --ref_fn={2} \
  --threads=${C3_THREADS} \
  --platform="ont" \
  --model_path="${_MODEL_DIR}" \
  --output=${PILEUP_OUTPUT_PATH}/{1}_{4} \
  --bed_fn={3} \
  --pileup_only ::: ${ALL_SAMPLE[@]} :::+ ${ALL_REFERENCE_FILE_PATH[@]} :::+ ${ALL_BED_FILE_PATH[@]} :::+ ${DEPTHS[@]} :::+ ${ALL_PHASED_BAM_FILE_PATH[@]}

```

## 3-1 Create and merge trio tensors

Generate even and uneven coverage combinations as the input for Clair3-Nova model training, here we set it as (child 10x, parent 1 10x, parent2 10x) + (child 30x, parent 1 10x, parent2 10) for exmaple.

```

# Get output pileup vcf path
ALL_PILEUP_VCF_FILE_PATH=(
"${PILEUP_OUTPUT_PATH}/${ALL_SAMPLE[$(($0))]}_${DEPTHS[$(($0))]}/pileup.vcf.gz"
"${PILEUP_OUTPUT_PATH}/${ALL_SAMPLE[$(($1))]}_${DEPTHS[$(($1))]}/pileup.vcf.gz"
"${PILEUP_OUTPUT_PATH}/${ALL_SAMPLE[$(($2))]}_${DEPTHS[$(($2))]}/pileup.vcf.gz"
"${PILEUP_OUTPUT_PATH}/${ALL_SAMPLE[$(($3))]}_${DEPTHS[$(($3))]}/pileup.vcf.gz"
"${PILEUP_OUTPUT_PATH}/${ALL_SAMPLE[$(($4))]}_${DEPTHS[$(($4))]}/pileup.vcf.gz"
"${PILEUP_OUTPUT_PATH}/${ALL_SAMPLE[$(($5))]}_${DEPTHS[$(($5))]}/pileup.vcf.gz"
)

# set up input for trio
INPUT_PILEUP_VCF_C=()
INPUT_PILEUP_VCF_P1=()
INPUT_PILEUP_VCF_P2=()

TRUE_RU_FILE_C=()
TRUE_RU_FILE_P1=()
TRUE_RU_FILE_P2=()

DEPTH_S=()

# create trio list for candidates input
for i in $(seq 0 $((${#ALL_SAMPLE[@]}-1)))
do
    if [ $(($i % 3)) -eq 0]; then
        INPUT_PILEUP_VCF_C+=("${ALL_PILEUP_VCF_FILE_PATH[$(($i))]}")
        INPUT_PILEUP_VCF_P1+=("${ALL_PILEUP_VCF_FILE_PATH[$(($i+1))]}")
        INPUT_PILEUP_VCF_P2+=("${ALL_PILEUP_VCF_FILE_PATH[$(($i+2))]}")

        TRUE_RU_FILE_C+=("${ALL_RU_FILE_PATH[$(($i))]}")
        TRUE_RU_FILE_P1+=("${ALL_RU_FILE_PATH[$(($i+1))]}")
        TRUE_RU_FILE_P2+=("${ALL_RU_FILE_PATH[$(($i+2))]}")
        
        DEPTH_S+=("${DEPTHS[$(($i))]}")
    fi
done


# created tensors chunk number for each chr
chunk_num=20
CHUNK_LIST=`seq 1 ${chunk_num}`

# create tensors bin chunk number for each chr
bin_chunk_num=10
BIN_CHUNK_LIST=`seq 1 ${bin_chunk_num}`


# Select trio candidates from pileup candidates using the SelectHetSnp_Trio submodule
time ${PARALLEL} --joblog ${LOG_PATH}/S_fiter_hete_snp_pileup${_LOG_SUF}.log -j${THREADS} \
"${PYPY} ${CLAIR3_NOVA} SelectHetSnp_Trio \
--alt_fn_c {2} \
--alt_fn_p1 {3} \
--alt_fn_p2 {4} \
--var_fn_c {5}/var_ru/var_{1} \
--var_fn_p1 {6}/var_ru/var_{1} \
--var_fn_p2 {7}/var_ru/var_{1} \
--split_folder ${SPLIT_BED_PATH} \
--sampleName ${TRIO_N} \
--depth {8} \
--ref_pct_full 0.2 \
--var_pct_full 1.0 \
--ref_var_max_ratio 1.0 \
--for_train 1 \
--chunk_num ${chunk_num} \
--bed ${_TRIO_BED_PATH} \
--ctgName ${CHR_PREFIX}{1}" ::: ${CHR[@]} ::: ${INPUT_PILEUP_VCF_C[@]} :::+ ${INPUT_PILEUP_VCF_P1[@]} :::+ ${INPUT_PILEUP_VCF_P2[@]} :::+ ${TRUE_RU_FILE_C[@]} :::+ ${TRUE_RU_FILE_P1[@]} :::+ ${TRUE_RU_FILE_P2[@]} :::+ ${DEPTH_S[@]} |& tee ${LOG_PATH}/FHSP${_LOG_SUF}.log

echo "[INFO] Create Tensors"
time ${PARALLEL} --joblog ${LOG_PATH}/S_create_tensor${_LOG_SUF}.log -j${THREADS} \
"${PYPY} ${CLAIR3_NOVA} CreateTensorFullAlignment \
--bam_fn {4} \
--ref_fn {5} \
--tensor_can_fn ${TENSOR_CANDIDATE_FOLDER_PATH}/tensor_can_{2}_{3}_{1}_{6} \
--indel_fn ${INDEL_PATH}/{2}_{3}_{1}_{6} \
--ctgName ${CHR_PREFIX}{1} \
--samtools ${SAMTOOLS} \
--platform ${PLATFORM} \
--full_aln_regions ${SPLIT_BED_PATH}/${TRIO_N}_{3}_{1}_{6} \
--add_no_phasing_data_training \
--phasing_info_in_bam" ::: ${CHR[@]} ::: ${ALL_SAMPLE[@]} :::+ ${DEPTHS[@]} :::+ ${ALL_PHASED_BAM_FILE_PATH[@]} :::+ ${ALL_REFERENCE_FILE_PATH[@]} ::: ${CHUNK_LIST[@]} |& tee ${LOG_PATH}/CT${_LOG_SUF}.log


# merge trio tensor, noted that merged no depth info
time ${PARALLEL} --joblog ${LOG_PATH}/S_merge_tensors${_LOG_SUF}.log -j${THREADS} \
"${PYTHON3} ${CLAIR3_NOVA} Merge_Tensors_Trio \
--tensor_fn_c ${TENSOR_CANDIDATE_FOLDER_PATH}/tensor_can_${ALL_SAMPLE[0]}_{3}_{1}_{2} \
--tensor_fn_p1 ${TENSOR_CANDIDATE_FOLDER_PATH}/tensor_can_${ALL_SAMPLE[1]}_{3}_{1}_{2} \
--tensor_fn_p2 ${TENSOR_CANDIDATE_FOLDER_PATH}/tensor_can_${ALL_SAMPLE[2]}_{3}_{1}_{2} \
--candidate_fn_c ${INDEL_PATH}/${ALL_SAMPLE[0]}_{3}_{1}_{2} \
--candidate_fn_p1 ${INDEL_PATH}/${ALL_SAMPLE[1]}_{3}_{1}_{2} \
--candidate_fn_p2 ${INDEL_PATH}/${ALL_SAMPLE[2]}_{3}_{1}_{2} \
--tensor_fn ${TENSOR_CANDIDATE_FOLDER_PATH}/tensor_can_${TRIO_N}_{3}_{1}_{2} \
--candidate_fn ${INDEL_PATH}/${TRIO_N}_{3}_{1}_{2} \
" ::: ${CHR[@]} ::: ${CHUNK_LIST[@]} ::: ${DEPTH_S[@]} |& tee ${LOG_PATH}/MT${_LOG_SUF}.log

IF_CHECK_MCV=0  # whether filter MCV in training data
# setting to generate denovo variant or not, for genreating de novo cases, the script to switch the child and parent 1 in input
# please check the 4_create_tensors_denovo.sh for a complete example
ONLY_DENOVO=0

time ${PARALLEL} --joblog ${LOG_PATH}/S_tensor2Bin${_LOG_SUF}.log -j${THREADS} \
"${PYTHON3} ${CLAIR3_TRIO} Tensor2Bin_Trio_denovo \
--tensor_fn ${TENSOR_CANDIDATE_FOLDER_PATH}/tensor_can_${TRIO_N}_{3}_{1} \
--var_fn_c {4}/var_ru/var_{1} \
--var_fn_p1 {5}/var_ru/var_{1} \
--var_fn_p2 {6}/var_ru/var_{1} \
--bin_fn ${BINS_FOLDER_PATH}/${TRIO_N}_{3}_{1}_{2} \
--chunk_id {2} \
--chunk_num ${bin_chunk_num} \
--platform ${PLATFORM} \
--allow_duplicate_chr_pos \
--maximum_non_variant_ratio 1.0 \
--check_mcv ${IF_CHECK_MCV} \
--only_denovo ${ONLY_DENOVO} \
--shuffle" ::: ${CHR[@]} ::: ${BIN_CHUNK_LIST[@]} ::: ${DEPTH_S[@]} :::+ ${TRUE_RU_FILE_C[@]} :::+ ${TRUE_RU_FILE_P1[@]} :::+ ${TRUE_RU_FILE_P2[@]} |& tee ${LOG_PATH}/T2B${_LOG_SUF}.log

```

## 3-2 Downsample all bins

Downsample all bin files for model training, by copying all bin files from even/uneven coverage `${BINS_FOLDER_PATH}` into `$ALL_BINS_FOLDER_PATH`.

We recommend downsampling bin files, as an example in [4_1_downsample_bin.sh](4_1_downsample_bin.sh).


## 4. Train a Clair3-Nova model 

Please set the `${ALL_BINS_FOLDER_PATH}` which contains the target bin files.

```
# Training trio model
TRAIN_N="[YOUR_CLAIR3-TRIO_MODEL_NAME]"
MODEL_FOLDER_PATH="${TRAIN_FOLDER_PREFIX}/train/{TRAIN_N}"					      
mkdir -p ${MODEL_FOLDER_PATH}
cd ${MODEL_FOLDER_PATH}

# Training setting
BATCH_SIZE="[YOUR_BATCH_SIZE]"  #training batch size, e.g. 800
add_indel_length=1
MODEL_ARC=NN
MODEL_ALS="Clair3_Trio_Out3_denovo"
IF_ADD_MCV_LOSS=0
MCVLOSS_ALPHA=0

# A single GPU is used for model training
export CUDA_VISIBLE_DEVICES="0"

echo "[INFO] Model training"
time ${PYTHON3} ${CLAIR3_TRIO} Train_Trio \
--bin_fn ${ALL_BINS_FOLDER_PATH} \
--ochk_prefix ${MODEL_FOLDER_PATH}/trio \
--add_indel_length ${add_indel_length} \
--platform ${PLATFORM} \
--validation_dataset \
--learning_rate 0.001 \
--maxEpoch 30 \
--model_arc ${MODEL_ARC} \
--model_cls ${MODEL_ALS} \
--batch_size ${BATCH_SIZE} \
--add_mcv_loss ${IF_ADD_MCV_LOSS} \
--mcv_alpha ${MCVLOSS_ALPHA} \
--train_denovo 1 \
 |& tee ${MODEL_FOLDER_PATH}/train_log

```


## Q20 data configuration

For a trio data from [Q20+](https://labs.epi2me.io/askenazi-kit14-2022-12/) with a maximum trio coverage (or minimum data coverage) of 65x:

| sample | coverage |
| ------ | -------- |
| HG002  | 70.13    |
| HG003  | 79.66    |
| HG004  | 64.72    |


We recommend generating trio data coverage config as below:


| even coverage   | HG002 | HG003 | HG004 |
| --------------- | ----- | ----- | ----- |
|                 | 10    | 10    | 10    |
|                 | 30    | 30    | 30    |
|                 | 50    | 50    | 50    |
|                 | 65    | 65    | 65    |
|                 |       |       |       |
| uneven coverage | HG002 | HG003 | HG004 |
|                 | 30    | 10    | 10    |
|                 | 50    | 10    | 10    |
|                 | 50    | 30    | 30    |
|                 | 65    | 10    | 10    |
|                 | 65    | 30    | 30    |
|                 | 65    | 50    | 50    |
