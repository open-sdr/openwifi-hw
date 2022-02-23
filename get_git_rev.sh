#!/bin/bash

# xianjun.jiao@imec.be

if git log -1 > /dev/null 2>&1; then
	GIT_REV=$(git log -1 --pretty=%h)
else
	GIT_REV=ffffffff
fi

echo $GIT_REV
