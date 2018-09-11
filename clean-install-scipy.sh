#!/usr/bin/env bash

/usr/bin/anaconda/envs/py35/bin/pip uninstall numpy scipy -y
/usr/bin/anaconda/envs/py35/bin/pip uninstall scikit-learn -y
/usr/bin/anaconda/envs/py35/bin/conda install numpy scipy scikit-learn -y
