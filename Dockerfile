FROM ubuntu:16.04
MAINTAINER Barry Warsaw <barry@python.org>

# Enable source repositories so we can use `apt build-dep` to get all the
# build dependencies for Python 2.7 and 3.5.
RUN sed -i -- 's/#deb-src/deb-src/g' /etc/apt/sources.list && \
    sed -i -- 's/# deb-src/deb-src/g' /etc/apt/sources.list

# Change these variables to update the version of Python installed.
ENV PYTHON_34_VER=3.4.7 \
    PYTHON_35_VER=3.5.4 \
    PYTHON_36_VER=3.6.3 \
    PYTHON_27_VER=2.7.13 \
    # Set debian front-end to non-interactive so that apt doesn't ask for
    # prompts later.
    DEBIAN_FRONTEND=noninteractive

RUN useradd runner --create-home && \
    # Create and change permissions for builds directory
    mkdir /builds && \
    chown runner /builds && \
    export LC_ALL=C.UTF-8 && export LANG=C.UTF-8

# Use a new layer here so that these static changes are cached from above layer.
# Update Xenial and install the build-deps
RUN apt update && \
    apt install -y python3-pip wget unzip && \
    # Remove apt's lists to make the image smaller.
    rm -rf /var/lib/apt/lists/*  && \
    cd  /tmp/ && \
    # Install Python 3.7 from git head.
    wget https://github.com/python/cpython/archive/master.zip  && \
	unzip master.zip && \
	cd /tmp/master && \
    ./configure && make && make altinstall && \
    cd /tmp/ && \
    # Remove the git clone.
    rm -r master && rm master.zip\
    # Install Python 3.6 from source.
    wget https://www.python.org/ftp/python/$PYTHON_36_VER/Python-$PYTHON_36_VER.tgz && \
    tar xzf Python-$PYTHON_36_VER.tgz && \
    cd /tmp/Python-$PYTHON_36_VER && \
    ./configure && make && make altinstall && \
    cd /tmp && \
    rm Python-$PYTHON_36_VER.tgz && rm -r Python-$PYTHON_36_VER && \
    # Install Python 3.5
    wget https://www.python.org/ftp/python/$PYTHON_35_VER/Python-$PYTHON_35_VER.tgz && \
    tar xzf Python-$PYTHON_35_VER.tgz && \
    cd  /tmp/Python-$PYTHON_35_VER && \
    ./configure && make && make altinstall && \
    cd /tmp/ && \
    rm Python-$PYTHON_35_VER.tgz && rm -r Python-$PYTHON_35_VER && \
    # Install Python 3.4 from source.
    wget https://www.python.org/ftp/python/$PYTHON_34_VER/Python-$PYTHON_34_VER.tgz && \
    tar zxf Python-$PYTHON_34_VER.tgz && \
    cd /tmp/Python-$PYTHON_34_VER && \
    ./configure && make && make altinstall && \
    cd /tmp/ && \
    rm Python-$PYTHON_34_VER.tgz && rm -r Python-$PYTHON_34_VER && \
    wget https://www.python.org/ftp/python/2.7.13/Python-2.7.13.tgz && \
     tar zxf Python-2.7.13.tgz && \
     cd /tmp/Python-2.7.13 && \
     ./configure && make && make altinstall && \
     cd /tmp/ && \
     rm Python-2.7.13.tgz && rm -r Python-2.7.13 && \
     # For the qa test and codecov.
     pip3 install mypy \
                  codecov \
                  tox

# Switch to runner user and set the workdir
USER runner
WORKDIR /home/runner
