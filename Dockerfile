FROM ubuntu:20.04
MAINTAINER Barry Warsaw <barry@python.org>

# Enable source repositories so we can use `apt build-dep` to get all the
# build dependencies for Python 2.7 and 3.5+.
RUN sed -i -- 's/#deb-src/deb-src/g' /etc/apt/sources.list && \
    sed -i -- 's/# deb-src/deb-src/g' /etc/apt/sources.list

ADD get-pythons.sh /usr/local/bin/get-pythons.sh
ADD get_versions.py /usr/local/bin/get_versions.py
ADD test_pythons.py /usr/local/bin/test_pythons.py

# Set Debian front-end to non-interactive so that apt doesn't ask for
# prompts later.
ENV  DEBIAN_FRONTEND=noninteractive

RUN useradd runner --create-home && \
    # Create and change permissions for builds directory.
    mkdir /builds && \
    chown runner /builds && \
    export LC_ALL=C.UTF-8 && export LANG=C.UTF-8

# Use a new layer here so that these static changes are cached from above
# layer.  Update Xenial and install the build-deps.
RUN apt -qq -o=Dpkg::Use-Pty=0 update && \
    apt -qq -o=Dpkg::Use-Pty=0 -y dist-upgrade && \
    # Use python3.8 build-deps for Ubuntu 20.04
    apt -qq -o=Dpkg::Use-Pty=0 build-dep -y python3.8 && \
    apt -qq -o=Dpkg::Use-Pty=0 install -y python3-pip wget unzip git && \
    # Remove apt's lists to make the image smaller.
    rm -rf /var/lib/apt/lists/*
# Get and install all versions of Python.
RUN ./usr/local/bin/get_versions.py && ./usr/local/bin/get-pythons.sh > /dev/null
    # Install some other useful tools for test environments.
    # Require a newer version of six until an issue with
    # pip dependency resolution when required package versions conflict is resolved.
    # See: https://github.com/pypa/virtualenv/issues/1551 for context.
RUN pip3 install mypy codecov tox "six>=1.14.0"
ADD /versions.txt /usr/local/bin/versions.txt

# Switch to runner user and set the workdir.
USER runner
WORKDIR /home/runner
