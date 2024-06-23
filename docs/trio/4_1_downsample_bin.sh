BASE_DIR="/autofs/bal36/jhsu/trio/r1041_hac/4_build_tensors/build/"

new_dir="${BASE_DIR}/merged_bins_dn"
#
mkdir -p ${new_dir}
###rm ${new_dir}/*
##
ori_dir="${BASE_DIR}/ALL_1368_denovo/denovo_t_bins/"
#new_dir="/autofs/bal36/jhsu/trio/output/4_build_tensors/build/merged_bins_wg_nm_dn"
_dep=10
_chr=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 21 22)
parallel "ln -s ${ori_dir}/HG003_TRIO_${_dep}_{1}_{2} ${new_dir}/HG003_TRIO_${_dep}_{1}_{2}" ::: ${_chr[@]} ::: `seq 1 1 10`
_dep=80
_chr=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 21 22)
parallel "ln -s ${ori_dir}/HG003_TRIO_${_dep}_{1}_{2} ${new_dir}/HG003_TRIO_${_dep}_{1}_{2}" ::: ${_chr[@]} ::: `seq 1 1 10`
_dep=30
_chr=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 21 22)
parallel "ln -s ${ori_dir}/HG003_TRIO_${_dep}_{1}_{2} ${new_dir}/HG003_TRIO_${_dep}_{1}_{2}" ::: ${_chr[@]} ::: `seq 1 1 10`
_dep=60
_chr=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 21 22)
parallel "ln -s ${ori_dir}/HG003_TRIO_${_dep}_{1}_{2} ${new_dir}/HG003_TRIO_${_dep}_{1}_{2}" ::: ${_chr[@]} ::: `seq 1 1 10`



ori_dir="${BASE_DIR}/ALL_1368/denovo_t_bins/"
_dep=10
_chr=(1 2 3 4 5 6 7 8 9)
parallel "ln -s ${ori_dir}/HG002_TRIO_${_dep}_{1}_{2} ${new_dir}/HG002_TRIO_${_dep}_{1}_{2}" ::: ${_chr[@]} ::: `seq 1 3 10`

_chr=(10 11 12 13 14 15)
parallel "ln -s ${ori_dir}/HG002_TRIO_${_dep}_{1}_{2} ${new_dir}/HG002_TRIO_${_dep}_{1}_{2}" ::: ${_chr[@]} ::: `seq 2 3 10`

_chr=(16 17 18 19 21 22)
parallel "ln -s ${ori_dir}/HG002_TRIO_${_dep}_{1}_{2} ${new_dir}/HG002_TRIO_${_dep}_{1}_{2}" ::: ${_chr[@]} ::: `seq 3 3 10`


_dep=80
_chr=(10 11 12 13 14 15)
parallel "ln -s ${ori_dir}/HG002_TRIO_${_dep}_{1}_{2} ${new_dir}/HG002_TRIO_${_dep}_{1}_{2}" ::: ${_chr[@]} ::: `seq 1 3 10`

_chr=(16 17 18 19 21 22)
parallel "ln -s ${ori_dir}/HG002_TRIO_${_dep}_{1}_{2} ${new_dir}/HG002_TRIO_${_dep}_{1}_{2}" ::: ${_chr[@]} ::: `seq 2 3 10`

_chr=(1 2 3 4 5 6 7 8 9)
parallel "ln -s ${ori_dir}/HG002_TRIO_${_dep}_{1}_{2} ${new_dir}/HG002_TRIO_${_dep}_{1}_{2}" ::: ${_chr[@]} ::: `seq 3 3 10`



_dep=30
_chr=(10 11 12 13 14 15)
parallel "ln -s ${ori_dir}/HG002_TRIO_${_dep}_{1}_{2} ${new_dir}/HG002_TRIO_${_dep}_{1}_{2}" ::: ${_chr[@]} ::: `seq 1 3 10`

_chr=(1 2 3 4 5 6 7 8 9)
parallel "ln -s ${ori_dir}/HG002_TRIO_${_dep}_{1}_{2} ${new_dir}/HG002_TRIO_${_dep}_{1}_{2}" ::: ${_chr[@]} ::: `seq 2 3 10`

_chr=(16 17 18 19 21 22)
parallel "ln -s ${ori_dir}/HG002_TRIO_${_dep}_{1}_{2} ${new_dir}/HG002_TRIO_${_dep}_{1}_{2}" ::: ${_chr[@]} ::: `seq 3 3 10`



_dep=60
_chr=(16 17 18 7 8 9)
parallel "ln -s ${ori_dir}/HG002_TRIO_${_dep}_{1}_{2} ${new_dir}/HG002_TRIO_${_dep}_{1}_{2}" ::: ${_chr[@]} ::: `seq 1 3 10`

_chr=(1 2 3 4 5 6 19 21 22)
parallel "ln -s ${ori_dir}/HG002_TRIO_${_dep}_{1}_{2} ${new_dir}/HG002_TRIO_${_dep}_{1}_{2}" ::: ${_chr[@]} ::: `seq 2 3 10`

_chr=(10 11 12 13 14 15)
parallel "ln -s ${ori_dir}/HG002_TRIO_${_dep}_{1}_{2} ${new_dir}/HG002_TRIO_${_dep}_{1}_{2}" ::: ${_chr[@]} ::: `seq 3 3 10`



ori_dir="${BASE_DIR}/SUB_1368/denovo_t_bins/"

#new_dir="/autofs/bal36/jhsu/trio/output/4_build_tensors/build/merged_bins"


_dep=SUB_31
_chr=(7 10 13 16 19 21 22)
parallel "ln -s ${ori_dir}/HG002_TRIO_${_dep}_{1}_{2} ${new_dir}/HG002_TRIO_${_dep}_{1}_{2}" ::: ${_chr[@]} ::: `seq 1 3 10`

#_chr=(10 11 12 13 14 15)
#parallel "ln -s ${ori_dir}/HG002_TRIO_${_dep}_{1}_{2} ${new_dir}/HG002_TRIO_${_dep}_{1}_{2}" ::: ${_chr[@]} ::: `seq 2 3 10`
#
#_chr=(16 17 18 19 21 22)
#parallel "ln -s ${ori_dir}/HG002_TRIO_${_dep}_{1}_{2} ${new_dir}/HG002_TRIO_${_dep}_{1}_{2}" ::: ${_chr[@]} ::: `seq 3 3 10`



_dep=SUB_61
_chr=(10 11 12 13 14 15)
_chr=(1 4 7 10 13 21 22)
parallel "ln -s ${ori_dir}/HG002_TRIO_${_dep}_{1}_{2} ${new_dir}/HG002_TRIO_${_dep}_{1}_{2}" ::: ${_chr[@]} ::: `seq 1 3 10`

#_chr=(16 17 18 19 21 22)
#parallel "ln -s ${ori_dir}/HG002_TRIO_${_dep}_{1}_{2} ${new_dir}/HG002_TRIO_${_dep}_{1}_{2}" ::: ${_chr[@]} ::: `seq 2 3 10`
#
#_chr=(1 2 3 4 5 6 7 8 9)
#parallel "ln -s ${ori_dir}/HG002_TRIO_${_dep}_{1}_{2} ${new_dir}/HG002_TRIO_${_dep}_{1}_{2}" ::: ${_chr[@]} ::: `seq 3 3 10`



_dep=SUB_81
#_chr=(10 11 12 13 14 15)
#parallel "ln -s ${ori_dir}/HG002_TRIO_${_dep}_{1}_{2} ${new_dir}/HG002_TRIO_${_dep}_{1}_{2}" ::: ${_chr[@]} ::: `seq 1 3 10`

#_chr=(1 2 3 4 5 6 7 8 9)
#parallel "ln -s ${ori_dir}/HG002_TRIO_${_dep}_{1}_{2} ${new_dir}/HG002_TRIO_${_dep}_{1}_{2}" ::: ${_chr[@]} ::: `seq 2 3 10`

_chr=(16 17 18 19 21 22)
_chr=(1 4 7 10 19 21 22)
parallel "ln -s ${ori_dir}/HG002_TRIO_${_dep}_{1}_{2} ${new_dir}/HG002_TRIO_${_dep}_{1}_{2}" ::: ${_chr[@]} ::: `seq 3 3 10`



_dep=SUB_13
_chr=(16 17 18 7 8 9)
_chr=(1 10 13 16 19 21 22)
parallel "ln -s ${ori_dir}/HG002_TRIO_${_dep}_{1}_{2} ${new_dir}/HG002_TRIO_${_dep}_{1}_{2}" ::: ${_chr[@]} ::: `seq 1 3 10`
