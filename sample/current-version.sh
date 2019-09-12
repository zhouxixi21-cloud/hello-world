#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo `/usr/bin/python lib/deployer-version.py ${DIR}`
