If you need a classifier trained, but don't want to bother with the lengthy net configuration, these scripts configure a pre-trained version of the alexnet CNN performs well on many vision problems, and converges particularily quickly on academic figures. *Note that caffe and dependencies must be installed prior scripts if ami not used.*

The script is built to run on the following AMI:

TEMPLATEFORCNNTRAINING

...So if you don't use it, you are on your own for path configuration,etc.


To run:

-put dataset in PUTDATAHERE folder (This would be a directory of two(train-val) and a list of all the files with their class (integer) following their name)
-edit allsetup.sh to point to the folder and select the number of classes
-double check allsetup.sh
-run ./allsetup.sh
-if everything works, run ./runit.sh

