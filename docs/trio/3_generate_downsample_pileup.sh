source /autofs/bal36/jhsu/trio/script/data_config_trio.sh

PARALLEL=parallel
PYPY=pypy
SAMTOOLS=samtools
PYTHON3=python3
PLATFORM="ont"

# Clair3 folder
_ORI_CLAIR3="/autofs/bal36/jhsu/trio/Clair3-Nova"

# note the use right models for your training
# check https://github.com/HKU-BAL/Clair3#pre-trained-models
#_MODEL_DIR="/autofs/bal31/jhsu/home/data/clair3_models/r941_prom_sup_g5014/"
_MODEL_DIR="/autofs/bal36/jhsu/trio/models/rerio/clair3_models/r1041_e82_400bps_hac_v430/"
C3_THREADS=36                                         # Clair3 threads number

# Clair3-Trio's path
CLAIR3_TRIO="/autofs/bal36/jhsu/trio/Clair3-Nova_dev/clair3.py"      

DATASET_FOLDER_PATH="/autofs/bal36/jhsu/trio/r1041_hac"

# creating working folder
PILEUP_OUTPUT_PATH="${DATASET_FOLDER_PATH}/3_pileup"
LOG_PATH="${PILEUP_OUTPUT_PATH}"
mkdir -p ${PILEUP_OUTPUT_PATH}
cd ${PILEUP_OUTPUT_PATH}


# input files and parameters
# training chrosome name, and prefix
CHR=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 21 22)
CHR_PREFIX="chr"

# GH (tb update to github)
CHILD_SAMPLE_N="HG002"
P1_SAMPLE_N="HG003"
P2_SAMPLE_N="HG004"

# sample name
ALL_SAMPLE=(
${CHILD_SAMPLE_N}                
${P1_SAMPLE_N}                   
${P2_SAMPLE_N}                
${CHILD_SAMPLE_N}                
${P1_SAMPLE_N}                   
${P2_SAMPLE_N}                
${CHILD_SAMPLE_N}                
${P1_SAMPLE_N}                   
${P2_SAMPLE_N}                
${CHILD_SAMPLE_N}                
${P1_SAMPLE_N}                   
${P2_SAMPLE_N}                
)


DEPTHS=(                            # data coverage
10
10
10
30
30
30
60
60
60
80
80
80
)

ALL_PHASED_BAM_FILE_PATH=(
"/autofs/bal36/jhsu/trio/r1041_hac/2_bam/HG002/HG002_10.bam"
"/autofs/bal36/jhsu/trio/r1041_hac/2_bam/HG003/HG003_10.bam"
"/autofs/bal36/jhsu/trio/r1041_hac/2_bam/HG004/HG004_10.bam"
"/autofs/bal36/jhsu/trio/r1041_hac/2_bam/HG002/HG002_30.bam"
"/autofs/bal36/jhsu/trio/r1041_hac/2_bam/HG003/HG003_30.bam"
"/autofs/bal36/jhsu/trio/r1041_hac/2_bam/HG004/HG004_30.bam"
"/autofs/bal36/jhsu/trio/r1041_hac/2_bam/HG002/HG002_60.bam"
"/autofs/bal36/jhsu/trio/r1041_hac/2_bam/HG003/HG003_60.bam"
"/autofs/bal36/jhsu/trio/r1041_hac/2_bam/HG004/HG004_60.bam"
"/autofs/bal36/jhsu/trio/r1041_hac/2_bam/HG002/HG002_80.bam"
"/autofs/bal36/jhsu/trio/r1041_hac/2_bam/HG003/HG003_80.bam"
"/autofs/bal36/jhsu/trio/r1041_hac/2_bam/HG004/HG004_80.bam"
)

#HOME_DIR="/autofs/bal31/jhsu/home"
#REF_FILE_PATH="${HOME_DIR}/data/reference/grch38_no_alt_plus_hs38d1/GCA_000001405.15_GRCh38_no_alt_plus_hs38d1_analysis_set.fna"
#CHILD_BED_FILE_PATH="${HOME_DIR}/data/giab/${CHILD_SAMPLE_N}_GRCh38_1_22_v4.2.1_benchmark_noinconsistent.bed"
#P1_BED_FILE_PATH="${HOME_DIR}/data/giab/${P1_SAMPLE_N}_GRCh38_1_22_v4.2.1_benchmark_noinconsistent.bed"
#P2_BED_FILE_PATH="${HOME_DIR}/data/giab/${P2_SAMPLE_N}_GRCh38_1_22_v4.2.1_benchmark_noinconsistent.bed"

# GH 
# merge trio's bed file using the gerneate_trio_bed.sh
#_TRIO_BED_PATH="${HOME_DIR}/data/giab/020304.bed"


ALL_REFERENCE_FILE_PATH=(
"${REF_FILE_PATH}"
"${REF_FILE_PATH}"
"${REF_FILE_PATH}"
"${REF_FILE_PATH}"
"${REF_FILE_PATH}"
"${REF_FILE_PATH}"
"${REF_FILE_PATH}"
"${REF_FILE_PATH}"
"${REF_FILE_PATH}"
"${REF_FILE_PATH}"
"${REF_FILE_PATH}"
"${REF_FILE_PATH}"
)


ALL_BED_FILE_PATH=(
${_TRIO_BED_PATH}
${_TRIO_BED_PATH}
${_TRIO_BED_PATH}
${_TRIO_BED_PATH}
${_TRIO_BED_PATH}
${_TRIO_BED_PATH}
${_TRIO_BED_PATH}
${_TRIO_BED_PATH}
${_TRIO_BED_PATH}
${_TRIO_BED_PATH}
${_TRIO_BED_PATH}
${_TRIO_BED_PATH}
)


# log file suffix name
_LOG_SUF=""                         # log file suffix

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

