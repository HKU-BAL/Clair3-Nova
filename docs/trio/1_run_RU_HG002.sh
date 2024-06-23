source /autofs/bal36/jhsu/trio/script/data_config_trio.sh

# ** please update the following path
REFERENCE_FILE_PATH="${REF_FILE_PATH}"

# Input parameters
VCF_FILE_PATH="${CHILD_VCF_FILE_PATH}"
BED_FILE_PATH="${CHILD_BED_FILE_PATH}"
BAM_FILE_PATH=/autofs/bal36/jhsu/fast5/r1041/hac/HG002/hg002.pass.cram 
OUTPUT_DIR="/autofs/bal36/jhsu/fast5/r1041/hac/1_ru/HG002"
# ** end




# Chromosome prefix ("chr" if chromosome names have the "chr" prefix)
CHR_PREFIX="chr"

# array of chromosomes (do not include "chr"-prefix)
CHR=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22)

# Number of threads to be used
THREADS=24

# The number of chucks to be divided into for parallel processing
chunk_num=15
CHUNK_LIST=`seq 1 ${chunk_num}`

# Minimum AF required for a candidate variant
MIN_AF=0.08

# Temporary working directory
SPLIT_BED_PATH="${OUTPUT_DIR}/split_beds"
VCF_OUTPUT_PATH="${OUTPUT_DIR}/vcf_output"
VAR_OUTPUT_PATH="${OUTPUT_DIR}/var"
PHASE_VCF_PATH="${OUTPUT_DIR}/phased_vcf"
PHASE_BAM_PATH="${OUTPUT_DIR}/phased_bam"

mkdir -p ${SPLIT_BED_PATH}
mkdir -p ${VCF_OUTPUT_PATH}
mkdir -p ${VAR_OUTPUT_PATH}
mkdir -p ${PHASE_VCF_PATH}
mkdir -p ${PHASE_BAM_PATH}




cd ${OUTPUT_DIR}

# WhatsHap phasing vcf file if vcf file includes '|' in INFO tag
${WHATSHAP} unphase ${VCF_FILE_PATH} > ${OUTPUT_DIR}/INPUT.vcf.gz

# WhatsHap phase vcf file
${PARALLEL} --joblog ${PHASE_VCF_PATH}/phase.log -j${THREADS} \
"${WHATSHAP} phase \
    --output ${PHASE_VCF_PATH}/phased_{1}.vcf.gz \
    --reference ${REFERENCE_FILE_PATH} \
    --chromosome ${CHR_PREFIX}{1} \
    --ignore-read-groups \
    --distrust-genotypes \
    ${OUTPUT_DIR}/INPUT.vcf.gz \
    ${BAM_FILE_PATH}" ::: ${CHR[@]}

# Index phased vcf file
${PARALLEL} -j ${THREADS} tabix -p vcf ${PHASE_VCF_PATH}/phased_{1}.vcf.gz ::: ${CHR[@]}


# WhatsHap haplotags bam file
${PARALLEL} --joblog ${PHASE_BAM_PATH}/haplotag.log -j${THREADS} \
"${WHATSHAP} haplotag \
    --output ${PHASE_BAM_PATH}/{1}.bam \
    --reference ${REFERENCE_FILE_PATH} \
    --regions ${CHR_PREFIX}{1} \
    --ignore-read-groups \
    ${PHASE_VCF_PATH}/phased_{1}.vcf.gz \
    ${BAM_FILE_PATH}" ::: ${CHR[@]}

# Index the phased bam file using samtools
${PARALLEL} --joblog ${PHASE_BAM_PATH}/index.log -j ${THREADS} ${SAMTOOLS} index -@12 ${PHASE_BAM_PATH}/{1}.bam ::: ${CHR[@]}



# Split bed file regions according to the contig name and extend bed region
${PARALLEL} --joblog ${SPLIT_BED_PATH}/split_extend_bed.log -j${THREADS} \
"${PYPY} ${CLAIR3} SplitExtendBed \
    --bed_fn ${BED_FILE_PATH} \
    --output_fn ${SPLIT_BED_PATH}/{1} \
    --ctgName ${CHR_PREFIX}{1}" ::: ${CHR[@]}

#Get true variant label information from VCF file
${PARALLEL} --joblog ${VAR_OUTPUT_PATH}/get_truth.log -j${THREADS} \
"${PYPY} ${CLAIR3} GetTruth \
    --vcf_fn ${PHASE_VCF_PATH}/phased_{1}.vcf.gz \
    --ctgName ${CHR_PREFIX}{1} \
    --var_fn ${VAR_OUTPUT_PATH}/var_{1}" ::: ${CHR[@]}

CLAIR3=/autofs/bal36/jhsu/trio/Clair3-Nova_dev/clair3.py
${PARALLEL} --joblog ${OUTPUT_DIR}/unify_repre.log -j${THREADS} \
"${PYPY} ${CLAIR3} UnifyRepresentation \
    --bam_fn ${PHASE_BAM_PATH}/{1}.bam \
    --var_fn ${VAR_OUTPUT_PATH}/var_{1} \
    --ref_fn ${REFERENCE_FILE_PATH} \
    --bed_fn ${BED_FILE_PATH} \
    --extend_bed ${SPLIT_BED_PATH}/{1} \
    --output_vcf_fn ${VCF_OUTPUT_PATH}/vcf_{1}_{2} \
    --min_af ${MIN_AF} \
    --chunk_id {2} \
    --chunk_num ${chunk_num} \
    --platform ${PLATFORM} \
    --ctgName ${CHR_PREFIX}{1}" ::: ${CHR[@]} ::: ${CHUNK_LIST[@]} > ${OUTPUT_DIR}/RU.log
    

cat ${VCF_OUTPUT_PATH}/vcf_* | ${PYPY} ${CLAIR3} SortVcf --output_fn ${OUTPUT_DIR}/unified.vcf
bgzip -f ${OUTPUT_DIR}/unified.vcf
tabix -f -p vcf ${OUTPUT_DIR}/unified.vcf.gz


RU_VAR_OUTPUT_PATH="${OUTPUT_DIR}/var_ru"
mkdir -p ${RU_VAR_OUTPUT_PATH}

#Get true variant label information from VCF file
${PARALLEL} --joblog ${RU_VAR_OUTPUT_PATH}/get_truth.log -j${THREADS} \
"${PYPY} ${CLAIR3} GetTruth \
--vcf_fn ${OUTPUT_DIR}/unified.vcf.gz \
--ctgName ${CHR_PREFIX}{1} \
--var_fn ${RU_VAR_OUTPUT_PATH}/var_{1}" ::: ${CHR[@]}



${SAMTOOLS} merge -@48 ${OUTPUT_DIR}/merged.bam ${PHASE_BAM_PATH}/*.bam 
${SAMTOOLS} index -@48 ${OUTPUT_DIR}/merged.bam

docker run \
    --mount type=bind,source=${VCF_FILE_PATH},target=/true_vcf \
    --mount type=bind,source=${BED_FILE_PATH},target=/true_bed \
    -v "${OUTPUT_DIR}/happy":"/happy"  \
    -v `dirname ${REF_FILE_PATH}`:"/ref"  \
    -v "${OUTPUT_DIR}":"/input"  \
    pkrusche/hap.py /opt/hap.py/bin/hap.py \
    /true_vcf \
    /input/unified.vcf.gz \
    -f /true_bed \
    -r /ref/GCA_000001405.15_GRCh38_no_alt_analysis_set.fa \
    -o /happy/output \
    --engine=vcfeval \
    --pass-only \
    --threads=8


python3 /autofs/bal31/jhsu/home/projects/clair3_t/scripts/happy.py --happy_vcf_fn ${OUTPUT_DIR}/happy/output.vcf.gz
# will get around 0.999 F1-score if run correctly.
