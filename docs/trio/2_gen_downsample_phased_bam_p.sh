tar_dir="/autofs/bal36/jhsu/fast5/r1041/hac/1_ru/"
#_SAMPLE_N='HG002'

# example input
# $DEPTHS_N=(10 30 60)
# $DEPTHS=(156 469 938)
# bash 2_gen_downsample_phased_bam_p.sh HG004 "${DEPTHS_N[*]}" "${DEPTHS[*]}" 
# or bash 2_gen_downsample_phased_bam_p.sh HG004 "10 30 60" "156 469 938"  

# for coverage 71x
# $DEPTHS_N=(10 30 60)
# $DEPTHS=(140 421 842)

# for coverage 80.84x
# $DEPTHS_N=(10 30 60)
# $DEPTHS=(124 371 742)

_SAMPLE_N="$1"
DEPTHS_N=($2)
DEPTHS=($3)

echo ${_SAMPLE_N} ${DEPTHS_N[@]} ${DEPTHS[@]}

# Other parameters
THREADS=8
PARALLEL='parallel'
SAMTOOLS='samtools'

SUBSAMPLED_BAMS_FOLDER_PATH="/autofs/bal36/jhsu/trio/r1041_hac/2_bam/${_SAMPLE_N}/"
mkdir -p ${SUBSAMPLED_BAMS_FOLDER_PATH}

echo ${_SAMPLE_N}
BAM_FILE_PATH=${tar_dir}/${_SAMPLE_N}/merged.bam

cd ${tar_dir}/${_SAMPLE_N}

# setting depth to downsample and their FRAC code in samtools view -s 
# for example if you have data coverage of 64x, you can downsample your data to 10x, 30x, 60x
# via following code
# DEPTHS_N=(10 30 60)
# DEPTHS=(156 469 938)

# note 1, you can check your data coverage via mosdepth`:
# mosdepth -t 5 -n -x --quantize 0:15:150: ${_SAMPLE_N}_phased ${BAM_FILE_PATH}
# note 2, the samtools view -s code can be genrate via following python script:
# ```python
#tar_d = "10 30 60".split()
#max_d = 64
#' '.join([['%.3f' % (float(i) / max_d)][0][2:] for i in tar_d])


# Subsample BAM to specific depths in parallel
${PARALLEL} -j${THREADS} "${SAMTOOLS} view -@12 -s 42.{1} -b -o ${SUBSAMPLED_BAMS_FOLDER_PATH}/${_SAMPLE_N}_{2}.bam ${BAM_FILE_PATH}"  ::: ${DEPTHS[@]}  :::+ ${DEPTHS_N[@]}
${PARALLEL} -j${THREADS} "${SAMTOOLS} index ${SUBSAMPLED_BAMS_FOLDER_PATH}/${_SAMPLE_N}_{1}.bam" ::: ${DEPTHS_N[@]}

cp ${BAM_FILE_PATH} ${SUBSAMPLED_BAMS_FOLDER_PATH}/${_SAMPLE_N}_80.bam
${SAMTOOLS} index ${SUBSAMPLED_BAMS_FOLDER_PATH}/${_SAMPLE_N}_80.bam 
##
###DEPTHS_N=(10 20 30 40 50 60 70 80)
#cd ${SUBSAMPLED_BAMS_FOLDER_PATH}
${PARALLEL} -j ${THREADS} "mosdepth -t 5 -n -x --quantize 0:15:150: ${_SAMPLE_N}_{1} ${SUBSAMPLED_BAMS_FOLDER_PATH}/${_SAMPLE_N}_{1}.bam " ::: ${DEPTHS_N[@]}

