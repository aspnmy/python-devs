# CI Images for Python

This is an official Docker image containing various stable and in-development
Python releases.  It is based on [Ubuntu 20.04 LTS](http://releases.ubuntu.com/20.04/).

There are two images to choose from, `active` and `latest` (a.k.a. `main`).
Both images contain all the currently active versions of Python, including:

<!---
It would be great if we could create this list dynamically, since it's the
we already auto-detect the active versions from the git tags.
--->

* [Python 3.11.0b1](https://www.python.org/downloads/release/python-311b1/)
* [Python 3.10.4](https://www.python.org/downloads/release/python-3104/)
* [Python 3.9.12](https://www.python.org/downloads/release/python-3912/)
* [Python 3.8.13](https://www.python.org/downloads/release/python-3813/)
* [Python 3.7.13](https://www.python.org/downloads/release/python-3713/)

The `latest` image also includes these EOL'd versions:

* [Python 3.6.15](https://www.python.org/downloads/release/python-3615/)
* [Python 3.5.10](https://www.python.org/downloads/release/python-3510/)
* [Python 2.7.18](https://www.python.org/downloads/release/python-2718/)

Feel free to help us by submitting
[merge requests](https://gitlab.com/python-devs/ci-images/merge_requests) or
[issues](https://gitlab.com/python-devs/ci-images/issues).

We are publishing these Docker images on
[GitLab](https://gitlab.com/python-devs/ci-images/container_registry).

You can use these images to test something in a supported version of Python,
e.g. (substituting `latest` for `active` if you need EOL'd versions):

```
$ docker run registry.gitlab.com/python-devs/ci-images:active python3.9 -c "import sys; print(sys.version)"
```

You can pull the resulting containers with this command:

```
$ docker pull registry.gitlab.com/python-devs/ci-images:active
```

If you want to use this image in your own CI pipelines (e.g. a
[.gitlab-ci.yml](https://gitlab.com/help/ci/yaml/README.md) file for a GitLab
shared runner), use this URL to refer to the image:

```
registry.gitlab.com/python-devs/ci-images:active
```

Here's [an example](https://gitlab.com/warsaw/flufl.lock/-/blob/main/.gitlab-ci.yml).
