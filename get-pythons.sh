#!/bin/sh

set -ex

cleanup_after_install () {
    find /usr/local -depth -type d -a  -name test -o -name tests -o  -type f -a -name '*.pyc' -o -name '*.pyo' -exec rm -rf '{}' +
    rm -rf /usr/src/python
}


get_install () {
    PY_VERSION=$1
    PY_DIR=${2:-$1}
    cd /tmp
    wget -q https://www.python.org/ftp/python/$PY_DIR/Python-$PY_VERSION.tgz
    tar xzf Python-$PY_VERSION.tgz
    cd /tmp/Python-$PY_VERSION
    ./configure -C && make && make -j4 altinstall
    cd /tmp
    rm Python-$PY_VERSION.tgz && rm -r Python-$PY_VERSION
}


# Install tagged Python releases.
while read ver; do
    get_install $ver
done <versions.txt


# Get and install Python rolling devel from the latest git install.
cd  /tmp/
wget -q https://github.com/python/cpython/archive/main.zip
unzip -qq main.zip
cd /tmp/cpython-main
./configure -C && make && make -j4 altinstall
# Remove the git clone.
rm -r /tmp/cpython-main && rm /tmp/main.zip

# After we have installed all the things, we cleanup tests and unused files
# like .pyc and .pyo
cleanup_after_install
