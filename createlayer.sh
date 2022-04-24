#!/bin/bash

CURRENT=`pwd`

if [ "$1" != "" ] || [$# -gt 1]; then
	echo "Creating layer compatible with python version $1"
	docker run -v "$PWD":/var/task "lambci/lambda:build-python$1" /bin/sh -c "pip install -r requirements.txt -t python/lib/python$1/site-packages/; exit"

	# Clean unused stuff
	cd "python/lib/python$1/site-packages/"
	rm -rf easy-install*
	rm -rf wheel*
	rm -rf setuptools*
	rm -rf virtualenv*
	rm -rf pip*
	find . -type d -name "tests" -exec rm -rf {} +
	find . -type d -name "test" -exec rm -rf {} +
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -name '*.pyc' -delete
	echo "Final layer size: $(du -sh . | cut -f1)"
	cd "$CURRENT"
	zip -r layer.zip python > /dev/null
	rm -r python
	echo "Done creating layer!"
	ls -lah layer.zip

else
	echo "Enter python version as argument - ./createlayer.sh 3.6"
fi
