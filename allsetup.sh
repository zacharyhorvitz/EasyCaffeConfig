#!/bin/sh
#This script should configure the net for training. This needs to be ran sudo from caffe root directory




#make lmdbs from images in TRAINING_FILES/PUTDATAHERE/:


######all stuff for user to configure#################
DATALOCATION=TRAINING_FILES/PUTDATAHERE #where lmdbs are saved
NETFILELOCATION=TRAINING_FILES/NETFILES #should probably not change; where solver,train_val prototxt, and other important filesa are
TRAINTEXTFILE=TRAINING_FILES/PUTDATAHERE/train.txt #text file with training images labeled (image name then number indicating category)
VALTEXTFILE=TRAINING_FILES/PUTDATAHERE/val.txt #text file with validation images
#TRAIN_DATA_ROOT=$DATALOCATION/train/ #directory of training images if different
#VAL_DATA_ROOT=$DATALOCATION/val/ #directory of validation images if different
TRAIN_DATA_ROOT=TRAINING_FILES/PUTDATAHERE/alldata/ #if directories for both val and train are the same
VAL_DATA_ROOT=TRAINING_FILES/PUTDATAHERE/alldata/
SOLVERLOCATION=$NETFILELOCATION/solver.prototxt
NETLOCATION=$NETFILELOCATION/train_val.prototxt
MAKELMDBS=true
MAKEMEAN=true
CONFIGSOLVER=true
CONFIGNET=true
NUMBEROFCLASSES=2
LEARNRATE=0.005
SNAPSHOTNAME=snapshot
######################################### Make lmdbs
if $MAKELMDBS; then
	sudo rm -r $DATALOCATION/train_lmdb #clear directories if they already exist
	sudo rm -r $DATALOCATION/val_lmdb
	#below data script from caffe/examples/create_imagenet.sh
	###################

	# Set RESIZE=true to resize the images to 256x256. Leave as false if images have
	# already been resized using another tool.
	RESIZE=true 
	if $RESIZE; then
  	RESIZE_HEIGHT=256
  	RESIZE_WIDTH=256
	else
  	RESIZE_HEIGHT=0
  	RESIZE_WIDTH=0
	fi

	if [ ! -d "$TRAIN_DATA_ROOT" ]; then
 	  echo "Error: TRAIN_DATA_ROOT is not a path to a directory: $TRAIN_DATA_ROOT"
	  echo "Set the TRAIN_DATA_ROOT variable in create_imagenet.sh to the path" \
	       "where the ImageNet training data is stored."
	  exit 1
	fi

	if [ ! -d "$VAL_DATA_ROOT" ]; then
	  echo "Error: VAL_DATA_ROOT is not a path to a directory: $VAL_DATA_ROOT"
	  echo "Set the VAL_DATA_ROOT variable in create_imagenet.sh to the path" \
	       "where the ImageNet validation data is stored."
	  exit 1
	fi

	echo "Creating train lmdb..."
	    GLOG_logtostderr=1 build/tools/convert_imageset \
	    --resize_height=$RESIZE_HEIGHT \
	    --resize_width=$RESIZE_WIDTH \
	    --shuffle \
	    $TRAIN_DATA_ROOT \
	    $TRAINTEXTFILE \
	    $DATALOCATION/train_lmdb

	echo "Creating val lmdb..."

	    GLOG_logtostderr=1 build/tools/convert_imageset \
	    --resize_height=$RESIZE_HEIGHT \
	    --resize_width=$RESIZE_WIDTH \
	    --shuffle \
	    $VAL_DATA_ROOT \
	    $VALTEXTFILE \
	    $DATALOCATION/val_lmdb

	echo "lmdb generation complete:"
fi
########################################

#################################### Make train image mean:
if $MAKEMEAN; then
	build/tools/compute_image_mean $DATALOCATION/train_lmdb $DATALOCATION/train_mean_image.binaryproto
	echo "Made train image mean"
fi
#################################### Config solver and net
if $CONFIGNET; then 	
        stringreplace0='\"pathtotrain_lmdb\"'
	stringreplacewith0='\"TRAINING_FILES\/PUTDATAHERE\/train_lmdb"'
        stringreplace1='\"pathtoval_lmdb\"'
	stringreplacewith1='\"TRAINING_FILES\/PUTDATAHERE\/val_lmdb"'
        stringreplace2='\"pathtomean.binaryproto\"'
        stringreplacewith2='\"TRAINING_FILES\/PUTDATAHERE\/train_mean_image.binaryproto\"'

                                                                                    
	#stringreplacewith="source: \/train.lmdb" need to make it variable instead
        sudo  cp $NETFILELOCATION/train_valorig.prototxt $NETFILELOCATION/train_val.prototxt
	sudo sed -i "s/$stringreplace0/$stringreplacewith0/" $NETFILELOCATION/train_val.prototxt
	sudo sed -i "s/$stringreplace1/$stringreplacewith1/" $NETFILELOCATION/train_val.prototxt
        sudo sed -i "s/$stringreplace2/$stringreplacewith2/" $NETFILELOCATION/train_val.prototxt
        sudo sed -i "321s/num_output: 4/num_output: $NUMBEROFCLASSES/" $NETFILELOCATION/train_val.prototxt
fi                                                                                           

if $CONFIGSOLVER; then
	stringreplace0='\"path\/to\/train_val.prototxt\"'
        stringreplacewith0='\"TRAINING_FILES\/NETFILES\/train_val.prototxt"'
	sudo cp $NETFILELOCATION/solverorig.prototxt $NETFILELOCATION/solver.prototxt
        sudo sed -i "s/base_lr: 0.005/base_lr: $LEARNRATE/" $NETFILELOCATION/solver.prototxt
        sudo sed -i "s/$stringreplace0/$stringreplacewith0/" $NETFILELOCATION/solver.prototxt
        sudo sed -i "s/snapshot_prefix: \"path\/to\/snapshotsavelocation\"/snapshot_prefix: \"TRAINING_FILES\/NETFILELOCATION\/$SNAPSHOTNAME\"/" $NETFILELOCATION/solver.prototxt
	#change net to address of net,change snapshot, maybe learn rate`
fi















