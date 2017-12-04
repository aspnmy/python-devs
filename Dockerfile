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

# Update Xenial and install the build-deps
RUN apt update && apt dist-upgrade --yes && \
	apt build-dep --yes python2.7 && apt build-dep --yes python3.5 && \
	# Installing tox should give us everything else we need.  Do we need a newer
	# version of tox?
	apt install --yes git python-tox python3-pip wget curl && \
	# Remove apt's lists to make the image smaller.
	rm -rf /var/lib/apt/lists/*	 && \
	# For the qa test and codecov.
	pip3 install mypy \
		 		 codecov

# Use a new layer here so that these static changes are cached.
RUN useradd runner --create-home && \
	# Create and change permissions for builds directory
	mkdir /builds && \
	chown runner /builds && \
	export LC_ALL=C.UTF-8 && export LANG=C.UTF-8

WORKDIR /tmp/
# Install Python 3.7 from git head.  Clone with depth only one, no need for the
# entire repo to install the latest commit version.
RUN git clone https://github.com/python/cpython.git --depth 1 && \
	cd /tmp/cpython && \
	./configure && make && make altinstall && \
	cd /tmp/ && \
	# Remove the git clone.
	rm -r cpython && \
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
	 rm Python-2.7.13.tgz && rm -r Python-2.7.13

# Switch to runner user and set the workdir
USER runner
WORKDIR /home/runner
