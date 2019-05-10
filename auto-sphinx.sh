#!/bin/bash

#How to use this shell script:

# This shell script will auto generate sphinx documentation.
# To generate entirely new documentation make sure that the
# working directory contains only a directory containing the code
# that is to be documented (hapi), the sphinx-answers
# file and this script. If this is what is required the directory
# should look like this:

	# [sean@eigg sphinx_hapi]$ ls
	# acq400_hapi  auto-sphinx.sh  sphinx-answers
        # This works, but be careful:
        # ls | grep -v hapi | grep -v auto-sphinx.sh | grep -v sphinx-answers | xargs rm -rf

# If documentation has already been created then this
# script can be used to generate new documentation without
# the need to rerun sphinx-quickstart. Just run this script and
# new html will be generated. Note that this will not change
# the project name inside conf.py.

# Terminal Example: source auto-sphinx.sh
# The following parameter is taken by this script.

which_docs_to_build=$1 # Take the first arg from the command line
if [ "$which_docs_to_build" = "" ]; then
	echo "Please specify which docs you wish to build."
	echo "Relevant commands to build docs:"
	echo "./auto-sphinx acq400_hapi"
	echo "./auto-sphinx user_apps"
	exit
fi

SDIR=$(dirname $0)
ANS=$SDIR/sphinx-answers

find_hapi_dirs()
{
# find_hapi_dirs looks in the directory that this script is run
# from and checks if a hapi or hapi_tests directory exists.
# If both hapi and hapi_tests exist then it will choose hapi by default
if [ "$which_docs_to_build" =  "acq400_hapi" ]; then
	echo "DEBUG 1"
	sed '3s/.*/acq400_hapi/' $ANS > $ANS.active
	docs_name="acq400_hapi"
elif [ "$which_docs_to_build" = "user_apps" ]; then
	echo "DEBUG 2"
	sed '3s/.*/user_apps/' $ANS > $ANS.active
	docs_name="user_apps"
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
	sphinx-quickstart < $ANS.active
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

sed -i -e '19 i\smartquotes = False' ./conf.py
sed -i -e 's/alabaster/default/g' ./conf.py
sed -i -e 's/# import os/import os/g' ./conf.py
sed -i -e 's/# import sys/import sys/g' ./conf.py

if [ "$which_docs_to_build" = "user_apps" ]; then
    sed -i -e 's|# sys.path.insert(0, os.path.abspath('"'"'.'"'"'))|for path in [x[0] for x in os.walk("'$current_dir'/acq400_hapi/user_apps/")]: sys.path.insert(0, path)|g' ./conf.py
fi

if [ "$which_docs_to_build" = "acq400_hapi" ]; then
    sed -i -e 's:# sys.path.insert(0, os.path.abspath('"'"'.'"'"')):sys.path.insert(0, os.path.abspath('"'"''$current_dir'/acq400_hapi/acq400_hapi/'"'"')):g' ./conf.py
fi

make html
if [ "$which_docs_to_build" = "acq400_hapi" ]; then
	sphinx-apidoc -o ./rst ./$docs_name
	cp rst/modules.rst rst/index.rst
elif [ "$which_docs_to_build" = "user_apps" ]; then
	sphinx-apidoc -o ./rst/ ./$docs_name/acq400
	cat ./rst/modules.rst >> ./rst/index.rst; rm ./rst/modules.rst
	sphinx-apidoc -o ./rst/ ./$docs_name/acq1001
	cat ./rst/modules.rst >> ./rst/index.rst; rm ./rst/modules.rst
	sphinx-apidoc -o ./rst/ ./$docs_name/acq2106
	cat ./rst/modules.rst >> ./rst/index.rst; rm ./rst/modules.rst
	sphinx-apidoc -o ./rst/ ./$docs_name/acq1014
	cat ./rst/modules.rst >> ./rst/index.rst; rm ./rst/modules.rst
	sphinx-apidoc -o ./rst/ ./$docs_name/special
	cat ./rst/modules.rst >> ./rst/index.rst; rm ./rst/modules.rst
	sphinx-apidoc -o ./rst/ ./$docs_name/analysis
	cat ./rst/modules.rst >> ./rst/index.rst; rm ./rst/modules.rst
	sphinx-apidoc -o ./rst/ ./$docs_name/hil
	cat ./rst/modules.rst >> ./rst/index.rst; rm ./rst/modules.rst
	sphinx-apidoc -o ./rst/ ./$docs_name/utils
	cat ./rst/modules.rst >> ./rst/index.rst; rm ./rst/modules.rst
fi

cd rst
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
