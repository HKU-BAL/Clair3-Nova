# Training trio model
PYTHON3=/autofs/bal31/jhsu/home/_env/anaconda3/envs/py38_3090/bin/python
PLATFORM="ont"
# Clair3-Nova's path
CLAIR3_TRIO="/autofs/bal36/jhsu/trio/Clair3-Nova/clair3.py"      

# bins folder for training
ALL_BINS_FOLDER_PATH="/autofs/bal36/jhsu/trio/r1041_hac/4_build_tensors/build/merged_bins_dn/"
TRAIN_FOLDER_PREFIX="/autofs/bal36/jhsu/trio/r1041_hac/5_train/"

# train on all data init model, 3090
TRAIN_N="ALL_SUB_1236_NM"
TRAIN_N="ALL_SUB_1368_NM_DN"
MODEL_FOLDER_PATH="${TRAIN_FOLDER_PREFIX}/${TRAIN_N}/"                        
mkdir -p ${MODEL_FOLDER_PATH}
cd ${MODEL_FOLDER_PATH}

# training setting
BATCH_SIZE="1600"  #training batch size, e.g. 800
add_indel_length=1
MODEL_ARC=NN
IF_ADD_MCV_LOSS=0
MCVLOSS_ALPHA=0

# A single GPU is used for model training
export CUDA_VISIBLE_DEVICES="0"


MODEL_ALS="Clair3_Trio_Out3_denovo"
time ${PYTHON3} ${CLAIR3_TRIO} Train_Trio \
--bin_fn ${ALL_BINS_FOLDER_PATH} \
--ochk_prefix ${MODEL_FOLDER_PATH} \
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
--train_denovo 1\
 |& tee ${MODEL_FOLDER_PATH}/train_log
#
##IF_ADD_MCV_LOSS=1
##MCVLOSS_ALPHA=1
#
#PRETRAINED_MODEL=/autofs/bal36/jhsu/guppy5/5_train/train/ALL_no_mcv.15
##PRETRAINED_MODEL=/autofs/bal36/jhsu/guppy5/5_train/train/ALL_data_m2/.15
#echo "[INFO] Model finetune"
#time ${PYTHON3} ${CLAIR3_TRIO} Train_Trio \
#    --bin_fn ${ALL_BINS_FOLDER_PATH} \
#    --ochk_prefix ${MODEL_FOLDER_PATH} \
#    --add_indel_length ${add_indel_length} \
#    --platform ${PLATFORM} \
#    --validation_dataset \
#    --learning_rate 1e-5 \
#    --maxEpoch 10 \
#    --model_arc ${MODEL_ARC} \
#    --batch_size ${BATCH_SIZE} \
#    --chkpnt_fn ${PRETRAINED_MODEL} \
#    --add_mcv_loss ${IF_ADD_MCV_LOSS} \
#    --mcv_alpha ${MCVLOSS_ALPHA} \
#     |& tee ${MODEL_FOLDER_PATH}/train_log
