_MODEL_DIR_C3="/autofs/bal36/jhsu/trio/Clair3-Nova/models/clair3_models/r1041_e82_400bps_hac_v430/"
_MODEL_DIR_C3T="/autofs/bal36/jhsu/trio/Clair3-Nova/models/clair3_nova_models/r1041_e82_400bps_hac_nova/"
_TRIO_M_PREFIX='nova'
_CLAIR3_TRIO_DIR="/autofs/bal36/jhsu/trio/Clair3-Nova"      

_BAM_C=/autofs/bal36/jhsu/trio/r1041_hac/6_test_bam/HG002/HG002_60.bam        
_BAM_P1=/autofs/bal36/jhsu/trio/r1041_hac/6_test_bam/HG003/HG003_60.bam        
_BAM_P2=/autofs/bal36/jhsu/trio/r1041_hac/6_test_bam/HG004/HG004_60.bam        
_SAMPLE_C="HG002"
_SAMPLE_P1="HG003"
_SAMPLE_P2="HG004"
_REF=/autofs/bal36/jhsu/r10/input/GCA_000001405.15_GRCh38_no_alt_analysis_set.fa
_THREADS="36"                
_CONTIGS="chr20"

_OUTPUT_DIR=/autofs/bal36/jhsu/trio/output/demo

source /autofs/bal36/jhsu/trio/script/data_config_trio.sh

SAMPLE=(
HG002
HG003
HG004
)

DEPTH=(
60
)

TOOLS='clair3-nova'
_tmp_dir="demo"
#_tmp_dir="t1"
#_tmp_dir="t_with_4khz"
#_tmp_dir="ALL_28"
INPUTBAM_PATH="/autofs/bal36/jhsu/trio/r1041_hac/6_test_bam/"
_RST_PATH=/autofs/bal36/jhsu/trio/output/demo/${TOOLS}/${_tmp_dir}/
mkdir -p $_RST_PATH
cd $_RST_PATH


for _DEPTH in ${DEPTH[@]}
do

_THREADS=36

_BAM_C=${INPUTBAM_PATH}/${SAMPLE[0]}/${SAMPLE[0]}_${_DEPTH}.bam
_BAM_P1=${INPUTBAM_PATH}/${SAMPLE[1]}/${SAMPLE[1]}_${_DEPTH}.bam
_BAM_P2=${INPUTBAM_PATH}/${SAMPLE[2]}/${SAMPLE[2]}_${_DEPTH}.bam
_BAM_C=/autofs/bal36/jhsu/fast5/r1041/hac/1_ru/HG002/phased_bam/3.bam
_BAM_P1=/autofs/bal36/jhsu/fast5/r1041/hac/1_ru/HG003/phased_bam/3.bam
_BAM_P2=/autofs/bal36/jhsu/fast5/r1041/hac/1_ru/HG004/phased_bam/3.bam

_SAMPLE_C=${SAMPLE[0]}
_SAMPLE_P1=${SAMPLE[1]}
_SAMPLE_P2=${SAMPLE[2]}

_OUTPUT_DIR=${_RST_PATH}/${_DEPTH}
mkdir -p $_OUTPUT_DIR

_CONTIGS="chr20"
START_POS=100000
END_POS=300000

_CONTIGS="chr3"
START_POS=16902579
END_POS=16904879


echo -e "${_CONTIGS}\t${START_POS}\t${END_POS}" > quick_demo.bed


/usr/bin/time -v ${_CLAIR3_TRIO_DIR}/run_clair3_nova.sh \
  --bam_fn_c=${_BAM_C} \
  --bam_fn_p1=${_BAM_P1} \
  --bam_fn_p2=${_BAM_P2} \
  --output=${_OUTPUT_DIR} \
  --ref_fn=${_REF} \
  --threads=${_THREADS} \
  --model_path_clair3="${_MODEL_DIR_C3}" \
  --model_path_clair3_nova="${_MODEL_DIR_C3T}" \
  --nova_model_prefix="${_TRIO_M_PREFIX}" \
  --sample_name_c=${_SAMPLE_C} \
  --sample_name_p1=${_SAMPLE_P1} \
  --sample_name_p2=${_SAMPLE_P2} \
  --gvcf \
  --gq_bin_size=5 \
  --base_err=0.01 \
  --bed_fn=quick_demo.bed


  #--ctg_name=chr20 \
 

#  --enable_phasing \
#  --enable_output_haplotagging

done





my_func2() {

_DEPTH=$1
TAR_SAMPLE_ID=$2
TAR_EVALUATE_BED=$3
TAR_EVALUATE_VCF=$4
_RST_PATH=$5

REF_SDF_FILE_PATH=/autofs/bal36/jhsu/r10/input/GCA_000001405.15_GRCh38_no_alt_analysis_set.sdf
TAR_EVALUATE_SDF=${REF_SDF_FILE_PATH}

echo ${TAR_SAMPLE_ID} 
echo ${TAR_EVALUATE_BED} 
echo ${TAR_EVALUATE_VCF} 
echo ${TAR_EVALUATE_SDF} 

_CONTIGS="chr20"
START_POS=10000
END_POS=90000

# # happy
_OUTPUT_DIR=${_RST_PATH}/${_DEPTH}

out_dir="${_OUTPUT_DIR}/happy"
tar_vcf="${_OUTPUT_DIR}/${TAR_SAMPLE_ID}.vcf.gz"
mkdir -p ${out_dir}
echo $out_dir

docker run \
--mount type=bind,source=${TAR_EVALUATE_VCF},target=/true_vcf \
--mount type=bind,source=${TAR_EVALUATE_BED},target=/true_bed \
--mount type=bind,source=${tar_vcf},target=/tar_vcf \
-v "/autofs/bal36/jhsu/r10/input/":"/reference" \
-v "${out_dir}":"/happy"  \
pkrusche/hap.py /opt/hap.py/bin/hap.py \
/true_vcf \
/tar_vcf \
-f /true_bed \
-r /reference/GCA_000001405.15_GRCh38_no_alt_analysis_set.fa \
-o /happy/${TAR_SAMPLE_ID}.output \
--engine=vcfeval \
-l ${_CONTIGS}:${START_POS}-${END_POS} \
--pass-only \
--threads=8

#-l chr20 \
}
export -f my_func2

BCFTOOLS=bcftools
RTG=rtg
_TRIO_PED=/autofs/bal31/jhsu/home/data/giab/trio.ped
REF_SDF_FILE_PATH=/autofs/bal36/jhsu/r10/input/GCA_000001405.15_GRCh38_no_alt_analysis_set.sdf
_TRIO_BED_PATH=/autofs/bal31/jhsu/home/data/giab/020304.bed
_TRIO_GIAB_MERGED=/autofs/bal31/jhsu/home/data/giab/trio/HG002_TRIO_z.vcf.gz
for _DEPTH in ${DEPTH[@]}
do

mkdir -p ${_RST_PATH}/${_DEPTH}/trio
M_VCF=${_RST_PATH}/${_DEPTH}/trio/${SAMPLE[0]}_TRIO.vcf.gz
# add mendelian annotation
M_VCF_annotated=${_RST_PATH}/${_DEPTH}/trio/${SAMPLE[0]}_TRIO_ann.vcf.gz
# only de novo variants
denovo_VCF=${_RST_PATH}/${_DEPTH}/${SAMPLE[0]}_TRIO_denovo.vcf.gz
# single sample for happy.py
denovo_VCF_s=${_RST_PATH}/${_DEPTH}/${SAMPLE[0]}_TRIO_denovo_s.vcf.gz
# single sample and high dp for happy.py
denovo_VCF_sf=${_RST_PATH}/${_DEPTH}/${SAMPLE[0]}_TRIO_denovo_sf.vcf.gz
denovo_VCF_hs=${_RST_PATH}/${_DEPTH}/${SAMPLE[0]}_TRIO_denovo_hs.vcf.gz

${BCFTOOLS} merge ${_RST_PATH}/${_DEPTH}/${SAMPLE[0]}.vcf.gz \
${_RST_PATH}/${_DEPTH}/${SAMPLE[1]}.vcf.gz \
${_RST_PATH}/${_DEPTH}/${SAMPLE[2]}.vcf.gz \
--threads 32 -f PASS -0 -m all| ${BCFTOOLS} view -O z -o ${M_VCF}

${BCFTOOLS} index ${M_VCF}
${BCFTOOLS} view ${M_VCF} -H | wc -l

${RTG} mendelian -i ${M_VCF} -o ${M_VCF_annotated} --pedigree ${_TRIO_PED} -t ${REF_SDF_FILE_PATH} |& tee ${_RST_PATH}/${_DEPTH}/trio/MDL.log

${BCFTOOLS} view -i 'INFO/MCV ~ "0/0+0/0->0/1"' ${M_VCF_annotated} -O z -o ${denovo_VCF}
${BCFTOOLS} index ${denovo_VCF}
${BCFTOOLS} view ${denovo_VCF} -s ${SAMPLE[0]} -O z -o ${denovo_VCF_s}
${BCFTOOLS} index ${denovo_VCF_s}

${BCFTOOLS} view -i "INFO/DNP>0.85" ${denovo_VCF} -O z -o ${denovo_VCF_hs}
${BCFTOOLS} index ${denovo_VCF_hs}

${BCFTOOLS} view -i "INFO/DNP>0.85" ${denovo_VCF} -s ${SAMPLE[0]} -O z -o ${denovo_VCF_sf}
${BCFTOOLS} index ${denovo_VCF_sf}

done


parallel --keep-order "grep 'violation of Mendelian constraints' ${_RST_PATH}/{1}/trio/MDL.log;" :::  ${DEPTH[@]} | cut -d ' ' -f 1,2  | tr -d '(|)' | cut -d '/' -f 1
parallel --keep-order "grep 'violation of Mendelian constraints' ${_RST_PATH}/{1}/trio/MDL.log; echo ; echo ;" :::  ${DEPTH[@]} | cut -d ' ' -f 1,2  | tr -d '(|)' | cut -d '/' -f 1
echo 'FN, TP, FP'


SAMPLE=(
HG002
HG003
HG004
HG002_TRIO_denovo_s
)

ALL_RST_PATH=(
${_RST_PATH}
${_RST_PATH}
${_RST_PATH}
${_RST_PATH}
)

GIAB_DIR="/autofs/bal31/jhsu/home/data/giab/"
BASELINE_VCF_FILE_PATH_C="${GIAB_DIR}/HG002_GRCh38_1_22_v4.2.1_benchmark.vcf.gz"
BASELINE_BED_FILE_PATH_C="${GIAB_DIR}/HG002_GRCh38_1_22_v4.2.1_benchmark_noinconsistent.bed"
BASELINE_VCF_FILE_PATH_P1="${GIAB_DIR}/HG003_GRCh38_1_22_v4.2.1_benchmark.vcf.gz"
BASELINE_BED_FILE_PATH_P1="${GIAB_DIR}/HG003_GRCh38_1_22_v4.2.1_benchmark_noinconsistent.bed"
BASELINE_VCF_FILE_PATH_P2="${GIAB_DIR}/HG004_GRCh38_1_22_v4.2.1_benchmark.vcf.gz"
BASELINE_BED_FILE_PATH_P2="${GIAB_DIR}/HG004_GRCh38_1_22_v4.2.1_benchmark_noinconsistent.bed"
BASELINE_VCF_FILE_PATH_TRIO="${GIAB_DIR}/trio/HG002_TRIO_z_ann_denovo_s.vcf.gz"
BASELINE_BED_FILE_PATH_TRIO="${GIAB_DIR}/020304.bed"

ALL_TRUE_BED=(
${BASELINE_BED_FILE_PATH_C}
${BASELINE_BED_FILE_PATH_P1}
${BASELINE_BED_FILE_PATH_P2}
${BASELINE_BED_FILE_PATH_TRIO}
)

ALL_TRUE_VCF=(
${BASELINE_VCF_FILE_PATH_C}
${BASELINE_VCF_FILE_PATH_P1}
${BASELINE_VCF_FILE_PATH_P2}
${BASELINE_VCF_FILE_PATH_TRIO}
)

parallel -j 30 my_func2 ::: ${DEPTH[@]} ::: ${SAMPLE[@]} :::+ ${ALL_TRUE_BED[@]} :::+ ${ALL_TRUE_VCF[@]} :::+ ${ALL_RST_PATH[@]}


SAMPLE=(
HG002
HG003
HG004
)
parallel --keep-order \
"echo -n {2},{1}x, ; python3 /autofs/bal31/jhsu/home/projects/clair3_t/scripts/happy.py --happy_vcf_fn ${_RST_PATH}/{1}/happy/{2}.output.vcf.gz" \
::: ${DEPTH[@]} ::: ${SAMPLE[@]} 



SAMPLE=(
HG002_TRIO_denovo_s
)
parallel --keep-order \
"echo -n {2},{1}x, ; python3 /autofs/bal31/jhsu/home/projects/clair3_t/scripts/happy.py --oz 2 --happy_vcf_fn ${_RST_PATH}/{1}/happy/{2}.output.vcf.gz" \
::: ${DEPTH[@]} ::: ${SAMPLE[@]} 





SAMPLE=(
HG002_TRIO_denovo_sf
)

ALL_RST_PATH=(
${_RST_PATH}
)

GIAB_DIR="/autofs/bal31/jhsu/home/data/giab/"
# single sample
BASELINE_VCF_FILE_PATH_TRIO="${GIAB_DIR}/trio/HG002_TRIO_z_ann_denovo_s.vcf.gz"
# single sample with filtered
BASELINE_VCF_FILE_PATH_TRIO="${GIAB_DIR}/trio/HG002_TRIO_z_ann_denovo_s_d.vcf.gz"
BASELINE_BED_FILE_PATH_TRIO="${GIAB_DIR}/020304.bed"

ALL_TRUE_BED=(
${BASELINE_BED_FILE_PATH_TRIO}
)

ALL_TRUE_VCF=(
${BASELINE_VCF_FILE_PATH_TRIO}
)

parallel -j 30 my_func2 ::: ${DEPTH[@]} ::: ${SAMPLE[@]} :::+ ${ALL_TRUE_BED[@]} :::+ ${ALL_TRUE_VCF[@]} :::+ ${ALL_RST_PATH[@]}


parallel --keep-order \
"echo -n {2},{1}x, ; python3 /autofs/bal31/jhsu/home/projects/clair3_t/scripts/happy.py --oz 2 --happy_vcf_fn ${_RST_PATH}/{1}/happy/{2}.output.vcf.gz" \
::: ${DEPTH[@]} ::: ${SAMPLE[@]} 








