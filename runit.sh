#This script starts the net with weights learned through imagenet training

./build/tools/caffe train \
	--solver=TRAINING_FILES/NETFILES/solver.prototxt \
	--weights=TRAINING_FILES/bvlc_reference_caffenet.caffemodel
