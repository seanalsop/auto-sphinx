#!/bin/bash

#How to use this shell script:

# This shell script will auto generate sphinx documentation.
# To generate entirely new documentation make sure that the 
# directory contains only a directory of the code that is 
# to be documented (hapi or hapi_tests), the sphinx-answers file
# and this script. 

# If documentation has already been created then this 
# script can be used to generate new documentation without 
# the need to rerun sphinx-quickstart. Just run this script and 
# new html will be generated. Note that this will not change
# the project name inside conf.py.

# Terminal Example: ./auto-sphinx.sh 
# No parameters are taken by this script. 


find_hapi_dirs()
{
# find_hapi_dirs looks in the directory that this script is run 
# from and checks if a hapi or hapi_tests directory exists.
# If both hapi and hapi_tests exist then it will choose hapi by default 
if [ -d "./acq400_hapi" ]; then
	sed -i '3s/.*/acq400_hapi/' ./sphinx-answers
	docs_name="acq400_hapi"
elif [ -d "./acq400_hapi_tests" ]; then
	sed -i '3s/.*/acq400_hapi_tests/' ./sphinx-answers
	docs_name="acq400_hapi_tests"
fi
}


run_sphinx_quickstart()
{
# run_sphinx_quickstart will check if a sphinx conf.py file
# exists and if one does not then the sphinx-quickstart utility 
# will be run. 
if [ -f "conf.py" ]; then
	echo "Sphinx conf found. Skipping sphinx-quickstart."
else
	echo "Sphinx conf not found. Running sphinx-quickstart now!"
	sphinx-quickstart < sphinx-answers
fi
}


run_sphinx_build()
{
# run_sphinx_build will always execute when this script is 
# called from the command line. It removes any default html and 
# rst files, makes sure that the correct paramters exist inside conf.py 
# and runs sphinx-apidoc and sphinx-build. 
echo ""
echo "Sphinx Build Starting"
echo ""

rm -rf ./html
mkdir html
rm -rf ./rst
mkdir rst

sed -i -e 's/alabaster/default/g' ./conf.py
sed -i -e 's/# import os/import os/g' ./conf.py
sed -i -e 's/# import sys/import sys/g' ./conf.py

if [ -d "./acq400_hapi_tests" ]; then
    sed -i -e 's:# sys.path.insert(0, os.path.abspath('"'"'.'"'"')):sys.path.insert(0, os.path.abspath('"'"''$current_dir'/acq400_hapi_tests'"'"')):g' ./conf.py
fi

if [ -d "./acq400_hapi" ]; then
    sed -i -e 's:# sys.path.insert(0, os.path.abspath('"'"'.'"'"')):sys.path.insert(0, os.path.abspath('"'"''$current_dir'/acq400_hapi'"'"')):g' ./conf.py
fi

make html
sphinx-apidoc -o ./rst ./$docs_name
cd rst
cp modules.rst index.rst
cp ../conf.py .
mkdir _static
cd ..
sphinx-build -b html ./rst ./html

echo ""
echo "Sphinx Build Finished"
echo ""
}


current_dir=`pwd`

find_hapi_dirs

run_sphinx_quickstart

run_sphinx_build
