INPUTBAM_PATH="/autofs/bal36/jhsu/trio/output/6_test_bam/"

SAMPLE=(
HG002
HG003
HG004
)

DEPTH=(
10
20
30
40
50
60
)

DEPTH=(
30
)


TOOLS='clair3'
_tmp_dir="ori"

INPUTBAM_PATH="/autofs/bal36/jhsu/trio/output/6_test_bam/ALL/"
_tmp_dir="ori_wg_t"
_RST_PATH=/autofs/bal36/jhsu/trio/output/7_test_results/${TOOLS}/${_tmp_dir}/
mkdir $_RST_PATH
cd $_RST_PATH

# run clair3-trio

for _DEPTH in ${DEPTH[@]}
do

# echo ${_DEPTH}
# echo ${_SAMPLE_N}

# CALL
_THREADS=64
_THREADS=36

HOME_DIR="/autofs/bal36/jhsu/r10"
_REF="${HOME_DIR}/input/GCA_000001405.15_GRCh38_no_alt_analysis_set.fa"

_BAM_C=${INPUTBAM_PATH}/${SAMPLE[0]}/${SAMPLE[0]}_${_DEPTH}.bam
_BAM_P1=${INPUTBAM_PATH}/${SAMPLE[1]}/${SAMPLE[1]}_${_DEPTH}.bam
_BAM_P2=${INPUTBAM_PATH}/${SAMPLE[2]}/${SAMPLE[2]}_${_DEPTH}.bam

_SAMPLE_C=${SAMPLE[0]}
_SAMPLE_P1=${SAMPLE[1]}
_SAMPLE_P2=${SAMPLE[2]}

_OUTPUT_DIR=${_RST_PATH}/${_DEPTH}
mkdir -p $_OUTPUT_DIR
# _OUTPUT_NAME=${_SAMPLE_N}_${_DEPTH}.vcf.gz

echo $_BAM
echo $_OUTPUT_NAME

INPUT_DIR=${INPUTBAM_PATH}
OUTPUT_DIR=${_OUTPUT_DIR}

_MODEL_NAME=r1041_e82_400bps_sup_v430
_MODEL_PATH=/autofs/bal36/jhsu/r10/models

#TAR_SAMPLE=${SAMPLE[0]}
#mkdir -p ${_OUTPUT_DIR}/${TAR_SAMPLE}
#docker run -it \
#  -v "${INPUTBAM_PATH}":"/input" \
#  -v "${_OUTPUT_DIR}":"/output" \
#  -v "${_MODEL_PATH}":"/model" \
#  -v "/autofs/bal36/jhsu/r10/input/":"/reference" \
#  hkubal/clair3:latest \
#  /opt/bin/run_clair3.sh \
#  --bam_fn="/input/${TAR_SAMPLE}/${TAR_SAMPLE}_${_DEPTH}.bam" \
#  --ref_fn=/reference/GCA_000001405.15_GRCh38_no_alt_analysis_set.fa \
#  --threads=${_THREADS} \
#  --sample_name=${TAR_SAMPLE} \
#  --platform="ont" \
#  --model_path="/model/${_MODEL_NAME}" \
#  --output=/output/${TAR_SAMPLE}/
#
#TAR_SAMPLE=${SAMPLE[1]}
#mkdir -p ${_OUTPUT_DIR}/${TAR_SAMPLE}
#docker run -it \
#  -v "${INPUTBAM_PATH}":"/input" \
#  -v "${_OUTPUT_DIR}":"/output" \
#  -v "${_MODEL_PATH}":"/model" \
#  -v "/autofs/bal36/jhsu/r10/input/":"/reference" \
#  hkubal/clair3:latest \
#  /opt/bin/run_clair3.sh \
#  --bam_fn="/input/${TAR_SAMPLE}/${TAR_SAMPLE}_${_DEPTH}.bam" \
#  --ref_fn=/reference/GCA_000001405.15_GRCh38_no_alt_analysis_set.fa \
#  --threads=${_THREADS} \
#  --sample_name=${TAR_SAMPLE} \
#  --platform="ont" \
#  --model_path="/model/${_MODEL_NAME}" \
#  --output=/output/${TAR_SAMPLE}/
#
#TAR_SAMPLE=${SAMPLE[2]}
#mkdir -p ${_OUTPUT_DIR}/${TAR_SAMPLE}
#docker run -it \
#  -v "${INPUTBAM_PATH}":"/input" \
#  -v "${_OUTPUT_DIR}":"/output" \
#  -v "${_MODEL_PATH}":"/model" \
#  -v "/autofs/bal36/jhsu/r10/input/":"/reference" \
#  hkubal/clair3:latest \
#  /opt/bin/run_clair3.sh \
#  --bam_fn="/input/${TAR_SAMPLE}/${TAR_SAMPLE}_${_DEPTH}.bam" \
#  --ref_fn=/reference/GCA_000001405.15_GRCh38_no_alt_analysis_set.fa \
#  --threads=${_THREADS} \
#  --sample_name=${TAR_SAMPLE} \
#  --platform="ont" \
#  --model_path="/model/${_MODEL_NAME}" \
#  --output=/output/${TAR_SAMPLE}/
#exit 0;
_CLAIR3_DIR=/autofs/bal36/jhsu/tools/Clair3
_MODEL_DIR_C3="/autofs/bal36/jhsu/trio/models/rerio/clair3_models/r1041_e82_400bps_sup_v430/"


${_CLAIR3_DIR}/run_clair3.sh \
  --bam_fn=${_BAM_C} \
  --output=${_OUTPUT_DIR}/${SAMPLE[0]} \
  --ref_fn=${_REF} \
  --threads=${_THREADS} \
  --model_path="${_MODEL_DIR_C3}" \
  --sample_name=${_SAMPLE_C} \
  --platform="ont" \


  --ctg_name=chr20

${_CLAIR3_DIR}/run_clair3.sh \
  --bam_fn=${_BAM_P1} \
  --output=${_OUTPUT_DIR}/${SAMPLE[1]} \
  --ref_fn=${_REF} \
  --threads=${_THREADS} \
  --model_path="${_MODEL_DIR_C3}" \
  --sample_name=${_SAMPLE_P1} \
  --platform="ont" \

  --ctg_name=chr20

${_CLAIR3_DIR}/run_clair3.sh \
  --bam_fn=${_BAM_P2} \
  --output=${_OUTPUT_DIR}/${SAMPLE[2]} \
  --ref_fn=${_REF} \
  --threads=${_THREADS} \
  --model_path="${_MODEL_DIR_C3}" \
  --sample_name=${_SAMPLE_P2} \
  --platform="ont" \

  --ctg_name=chr20

done



#my_func2() {
#
#TOOLS='clair3'
#_tmp_dir="ori"
#_RST_PATH=/autofs/bal36/jhsu/trio/output/7_test_results/${TOOLS}/${_tmp_dir}/
#
#ALL_SAMPLE=(
#HG002
#HG003
#HG004
#)
#
#ALL_SAMPLE_N=3
#
#GIAB_DIR="/autofs/bal31/jhsu/home/data/giab/"
#BASELINE_VCF_FILE_PATH_C="${GIAB_DIR}/HG002_GRCh38_1_22_v4.2.1_benchmark.vcf.gz"
#BASELINE_BED_FILE_PATH_C="${GIAB_DIR}/HG002_GRCh38_1_22_v4.2.1_benchmark_noinconsistent.bed"
#BASELINE_VCF_FILE_PATH_P1="${GIAB_DIR}/HG003_GRCh38_1_22_v4.2.1_benchmark.vcf.gz"
#BASELINE_BED_FILE_PATH_P1="${GIAB_DIR}/HG003_GRCh38_1_22_v4.2.1_benchmark_noinconsistent.bed"
#BASELINE_VCF_FILE_PATH_P2="${GIAB_DIR}/HG004_GRCh38_1_22_v4.2.1_benchmark.vcf.gz"
#BASELINE_BED_FILE_PATH_P2="${GIAB_DIR}/HG004_GRCh38_1_22_v4.2.1_benchmark_noinconsistent.bed"
#REF_SDF_FILE_PATH=/autofs/bal36/jhsu/r10/input/GCA_000001405.15_GRCh38_no_alt_analysis_set.sdf
#
#ALL_TRUE_BED=(
#${BASELINE_BED_FILE_PATH_C}
#${BASELINE_BED_FILE_PATH_P1}
#${BASELINE_BED_FILE_PATH_P2}
#)
#
#ALL_TRUE_VCF=(
#${BASELINE_VCF_FILE_PATH_C}
#${BASELINE_VCF_FILE_PATH_P1}
#${BASELINE_VCF_FILE_PATH_P2}
#)
#
#
#_DEPTH=$1
#_N=$2
#
#TAR_SAMPLE_ID=${ALL_SAMPLE[_N-1]}
#TAR_EVALUATE_BED=${ALL_TRUE_BED[_N-1]}
#TAR_EVALUATE_VCF=${ALL_TRUE_VCF[_N-1]}
#TAR_EVALUATE_SDF=${REF_SDF_FILE_PATH}
#
#echo ${_N} 
#echo ${TAR_SAMPLE_ID} 
#echo ${TAR_EVALUATE_BED} 
#echo ${TAR_EVALUATE_VCF} 
#echo ${TAR_EVALUATE_SDF} 
#
#
## # index
#
## # happy
#
#_OUTPUT_DIR=${_RST_PATH}/${_DEPTH}
#
#out_dir="${_OUTPUT_DIR}/${TAR_SAMPLE_ID}/happy"
#tar_vcf="${_OUTPUT_DIR}/${TAR_SAMPLE_ID}/merge_output.vcf.gz"
#echo $out_dir
#mkdir -p ${out_dir}
#
#
#
#docker run \
#--mount type=bind,source=${TAR_EVALUATE_VCF},target=/true_vcf \
#--mount type=bind,source=${TAR_EVALUATE_BED},target=/true_bed \
#--mount type=bind,source=${tar_vcf},target=/tar_vcf \
#-v "/autofs/bal36/jhsu/r10/input/":"/reference" \
#-v "${out_dir}":"/happy"  \
#pkrusche/hap.py /opt/hap.py/bin/hap.py \
#/true_vcf \
#/tar_vcf \
#-f /true_bed \
#-r /reference/GCA_000001405.15_GRCh38_no_alt_analysis_set.fa \
#-o /happy/${TAR_SAMPLE_ID}.output \
#--engine=vcfeval \
#-l chr20 \
#--pass-only \
#--threads=8
#
#}
#
#
#export -f my_func2
## DEPTH=(
## 50
## 60
## 70
## )
#ALL_SAMPLE_N=3
#parallel -j 30 my_func2 ::: ${DEPTH[@]} ::: `seq ${ALL_SAMPLE_N}`
#
#TOOLS='clair3'
#_tmp_dir="ori"
#_RST_PATH=/autofs/bal36/jhsu/trio/output/7_test_results/${TOOLS}/${_tmp_dir}/
#
#
#parallel --keep-order \
#"echo -n {2},{1}x, ; python3 /autofs/bal31/jhsu/home/projects/clair3_t/scripts/happy.py --happy_vcf_fn ${_RST_PATH}/{1}/{2}/happy/{2}.output.vcf.gz" \
#::: ${DEPTH[@]} ::: ${SAMPLE[@]} 
#
#
##set -x;
#
#BCFTOOLS=bcftools
#RTG=rtg
#_TRIO_PED=/autofs/bal31/jhsu/home/data/giab/trio.ped
#REF_SDF_FILE_PATH=/autofs/bal36/jhsu/r10/input/GCA_000001405.15_GRCh38_no_alt_analysis_set.sdf
#_TRIO_BED_PATH=/autofs/bal31/jhsu/home/data/giab/020304.bed
#_TRIO_GIAB_MERGED=/autofs/bal31/jhsu/home/data/giab/trio/HG002_TRIO_z.vcf.gz
#
#for _DEPTH in ${DEPTH[@]}
#do
#mkdir -p ${_RST_PATH}/${_DEPTH}/trio
#M_VCF=${_RST_PATH}/${_DEPTH}/trio/${SAMPLE[0]}_TRIO.vcf.gz
#M_VCF_annotated=${_RST_PATH}/${_DEPTH}/trio/${SAMPLE[0]}_TRIO_ann.vcf.gz
#
#${BCFTOOLS} merge ${_RST_PATH}/${_DEPTH}/${SAMPLE[0]}/merge_output.vcf.gz \
#${_RST_PATH}/${_DEPTH}/${SAMPLE[1]}/merge_output.vcf.gz \
#${_RST_PATH}/${_DEPTH}/${SAMPLE[2]}/merge_output.vcf.gz \
#--threads 32 -f PASS -0 -m all| ${BCFTOOLS} view -O z -o ${M_VCF}
#
#${BCFTOOLS} index ${M_VCF}
#${BCFTOOLS} view ${M_VCF} -H | wc -l
#
#${RTG} mendelian -i ${M_VCF} -o ${M_VCF_annotated} --pedigree ${_TRIO_PED} -t ${REF_SDF_FILE_PATH} |& tee ${_RST_PATH}/${_DEPTH}/trio/MDL.log
#
#
#PYPY=pypy
#_CLAIR3_TRIO_DIR=/autofs/bal31/jhsu/home/projects/git/clair3-trio-clean
#${PYPY} ${_CLAIR3_TRIO_DIR}/clair3.py Check_de_novo --call_vcf ${M_VCF} --ctgName chr20 --bed_fn $_TRIO_BED_PATH --true_vcf $_TRIO_GIAB_MERGED |& tee ${_RST_PATH}/${_DEPTH}/trio/denovo_rst
#done
#
#
## parallel --keep-order "grep 'violation of Mendelian constraints' ${CALL_PATH}/trio/{1}_MDL.log" :::  ${DEPTH[@]} | cut -d ' ' -f 1,2  | tr -d '(|)'
#parallel --keep-order "grep 'violation of Mendelian constraints' ${_RST_PATH}/{1}/trio/MDL.log;" :::  ${DEPTH[@]} | cut -d ' ' -f 1,2  | tr -d '(|)' | cut -d '/' -f 1
#parallel --keep-order "grep 'violation of Mendelian constraints' ${_RST_PATH}/{1}/trio/MDL.log; echo ; echo ;" :::  ${DEPTH[@]} | cut -d ' ' -f 1,2  | tr -d '(|)' | cut -d '/' -f 1
#echo 'FN, TP, FP'
#parallel --keep-order "grep 'TP' ${_RST_PATH}/{1}/trio/denovo_rst" :::  ${DEPTH[@]} | cut -d ':' -f 2 
#parallel --keep-order "grep 'TP' ${_RST_PATH}/{1}/trio/denovo_rst; echo ; echo ;" :::  ${DEPTH[@]} | cut -d ':' -f 2 



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

# # happy
_OUTPUT_DIR=${_RST_PATH}/${_DEPTH}

out_dir="${_OUTPUT_DIR}/happy"

#tar_vcf="${_OUTPUT_DIR}/${TAR_SAMPLE_ID}/merge_output.vcf.gz"
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
-l chr1,chr2,chr3,chr4,chr5,chr6,chr7,chr8,chr9,chr10,chr11,chr12,chr13,chr14,chr15,chr16,chr17,chr18,chr19,chr21,chr22 \
--pass-only \
--threads=8

#-l chr20 \
}
export -f my_func2
# DEPTH=(
# 50
# 60
# 70
# )

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
M_VCF_annotated=${_RST_PATH}/${_DEPTH}/trio/${SAMPLE[0]}_TRIO_ann.vcf.gz
denovo_VCF=${_RST_PATH}/${_DEPTH}/${SAMPLE[0]}_TRIO_denovo.vcf.gz
denovo_VCF_s=${_RST_PATH}/${_DEPTH}/${SAMPLE[0]}_TRIO_denovo_s.vcf.gz
denovo_VCF_sf=${_RST_PATH}/${_DEPTH}/${SAMPLE[0]}_TRIO_denovo_sf.vcf.gz


#tar_vcf="${_OUTPUT_DIR}/${TAR_SAMPLE_ID}/merge_output.vcf.gz"
_TAR_SAMPLE=${SAMPLE[0]}
cp ${_RST_PATH}/${_DEPTH}/${_TAR_SAMPLE}/merge_output.vcf.gz ${_RST_PATH}/${_DEPTH}/${_TAR_SAMPLE}.vcf.gz 
${BCFTOOLS} index ${_RST_PATH}/${_DEPTH}/${_TAR_SAMPLE}.vcf.gz
_TAR_SAMPLE=${SAMPLE[1]}
cp ${_RST_PATH}/${_DEPTH}/${_TAR_SAMPLE}/merge_output.vcf.gz ${_RST_PATH}/${_DEPTH}/${_TAR_SAMPLE}.vcf.gz 
${BCFTOOLS} index ${_RST_PATH}/${_DEPTH}/${_TAR_SAMPLE}.vcf.gz
_TAR_SAMPLE=${SAMPLE[2]}

cp ${_RST_PATH}/${_DEPTH}/${_TAR_SAMPLE}/merge_output.vcf.gz ${_RST_PATH}/${_DEPTH}/${_TAR_SAMPLE}.vcf.gz 
${BCFTOOLS} index ${_RST_PATH}/${_DEPTH}/${_TAR_SAMPLE}.vcf.gz

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


#tabix -p vcf ${denovo_VCF}

PYPY=pypy
_CLAIR3_TRIO_DIR=/autofs/bal31/jhsu/home/projects/git/clair3-trio-clean
${PYPY} ${_CLAIR3_TRIO_DIR}/clair3.py Check_de_novo --call_vcf ${M_VCF} --ctgName chr20 --bed_fn $_TRIO_BED_PATH --true_vcf $_TRIO_GIAB_MERGED |& tee ${_RST_PATH}/${_DEPTH}/trio/denovo_rst
done


# parallel --keep-order "grep 'violation of Mendelian constraints' ${CALL_PATH}/trio/{1}_MDL.log" :::  ${DEPTH[@]} | cut -d ' ' -f 1,2  | tr -d '(|)'
parallel --keep-order "grep 'violation of Mendelian constraints' ${_RST_PATH}/{1}/trio/MDL.log;" :::  ${DEPTH[@]} | cut -d ' ' -f 1,2  | tr -d '(|)' | cut -d '/' -f 1
parallel --keep-order "grep 'violation of Mendelian constraints' ${_RST_PATH}/{1}/trio/MDL.log; echo ; echo ;" :::  ${DEPTH[@]} | cut -d ' ' -f 1,2  | tr -d '(|)' | cut -d '/' -f 1
echo 'FN, TP, FP'
parallel --keep-order "grep 'TP' ${_RST_PATH}/{1}/trio/denovo_rst" :::  ${DEPTH[@]} | cut -d ':' -f 2 
parallel --keep-order "grep 'TP' ${_RST_PATH}/{1}/trio/denovo_rst; echo ; echo ;" :::  ${DEPTH[@]} | cut -d ':' -f 2 



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
HG002_TRIO_denovo_s
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

#parallel -j 30 my_func2 ::: ${DEPTH[@]} ::: `seq ${ALL_SAMPLE_N}` :::+ ${ALL_RST_PATH}
parallel -j 30 my_func2 ::: ${DEPTH[@]} ::: ${SAMPLE[@]} :::+ ${ALL_TRUE_BED[@]} :::+ ${ALL_TRUE_VCF[@]} :::+ ${ALL_RST_PATH[@]}


parallel --keep-order \
"echo -n {2},{1}x, ; python3 /autofs/bal31/jhsu/home/projects/clair3_t/scripts/happy.py --oz 2 --happy_vcf_fn ${_RST_PATH}/{1}/happy/{2}.output.vcf.gz" \
::: ${DEPTH[@]} ::: ${SAMPLE[@]} 






