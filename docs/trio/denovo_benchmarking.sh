```sh
BCFTOOLS=bcftools
RTG=rtg
_TRIO_PED=XXX/giab/trio.ped                                                 # trio ped
REF_SDF_FILE_PATH=XXX/GCA_000001405.15_GRCh38_no_alt_analysis_set.sdf       # reference sdf
_TRIO_BED_PATH=/autofs/bal31/jhsu/home/data/giab/020304.bed                 # trio bed
DEPTH=(
10
20
30
40
50
60
)
SAMPLE=(
HG002
HG003
HG004
)
_RST_PATH="XXX"                                                             # vcf dir with ${_RST_PATH}/${SAMPLE[0]}/merge_output.vcf.gz, etc.


CLAIR3_NOVA_PATH="XXX"


#define hap.py function
# input $tar_vcf and $TAR_EVALUATE_VCF
# ouput hap.py 
happy_func() {

REF_SDF_FILE_PATH=XXX/GCA_000001405.15_GRCh38_no_alt_analysis_set.sdf
TAR_EVALUATE_SDF=${REF_SDF_FILE_PATH}

_DEPTH=$1
TAR_SAMPLE_ID=$2
TAR_EVALUATE_BED=$3
TAR_EVALUATE_VCF=$4
_RST_PATH=$5


echo ${TAR_SAMPLE_ID} 
echo ${TAR_EVALUATE_BED} 
echo ${TAR_EVALUATE_VCF} 
echo ${TAR_EVALUATE_SDF} 

# # happy
_OUTPUT_DIR=${_RST_PATH}/${_DEPTH}

out_dir="${_OUTPUT_DIR}/happy"

tar_vcf="${_OUTPUT_DIR}/${TAR_SAMPLE_ID}.vcf.gz"
mkdir -p ${out_dir}
echo $out_dir

# update "/autofs/bal36/jhsu/r10/input/" tp reference sdf dir
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
-l chr1,chr2,chr3,chr4,chr5,chr6,chr7,chr8,chr9,chr10,chr11,chr12,chr13,chr14,chr15,chr16,chr17,chr18,chr19,chr20,chr21,chr22 \
--pass-only \
--threads=8

}
export -f happy_func

for _DEPTH in ${DEPTH[@]}
do

mkdir -p ${_RST_PATH}/${_DEPTH}/trio
M_VCF=${_RST_PATH}/${_DEPTH}/trio/${SAMPLE[0]}_TRIO.vcf.gz
M_VCF_annotated=${_RST_PATH}/${_DEPTH}/trio/${SAMPLE[0]}_TRIO_ann.vcf.gz
denovo_VCF=${_RST_PATH}/${_DEPTH}/${SAMPLE[0]}_TRIO_denovo.vcf.gz
denovo_VCF_s=${_RST_PATH}/${_DEPTH}/${SAMPLE[0]}_TRIO_denovo_s.vcf.gz

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

parallel -j 30 happy_func ::: ${DEPTH[@]} ::: ${SAMPLE[@]} :::+ ${ALL_TRUE_BED[@]} :::+ ${ALL_TRUE_VCF[@]} :::+ ${ALL_RST_PATH[@]}


SAMPLE=(
HG002
HG003
HG004
)
parallel --keep-order \
"echo -n {2},{1}x, ; python3 ${CLAIR3_NOVA_PATH}/scripts/happy.py --happy_vcf_fn ${_RST_PATH}/{1}/happy/{2}.output.vcf.gz" \
::: ${DEPTH[@]} ::: ${SAMPLE[@]} 


SAMPLE=(
HG002_TRIO_denovo_s
)
parallel --keep-order \
"echo -n {2},{1}x, ; python3 ${CLAIR3_NOVA_PATH}/scripts/happy.py --oz 2 --happy_vcf_fn ${_RST_PATH}/{1}/happy/{2}.output.vcf.gz" \
::: ${DEPTH[@]} ::: ${SAMPLE[@]} 
```
