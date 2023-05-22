# CI Images for Python

This is an official Docker image containing various stable and in-development
Python releases.  It is based on [Ubuntu 22.04 LTS](http://releases.ubuntu.com/22.04/).

The `active` (a.k.a. `main`) image contains all of the currently maintained
versions of Python. None of the [EOL'd](https://endoflife.date/python)
versions are built or are available for testing purposes. Note that we
recommend against using `main` as it may soon be
[deprecated](https://gitlab.com/python-devs/ci-images/-/issues/20).  These are
the current versions that are available:

<!---
It would be great if we could create this list dynamically, since it's the
we already auto-detect the active versions from the git tags.
--->

* [Python 3.12.0b1](https://www.python.org/downloads/release/python-3120b1/)
* [Python 3.11.3](https://www.python.org/downloads/release/python-3113/)
* [Python 3.10.11](https://www.python.org/downloads/release/python-31011/)
* [Python 3.9.16](https://www.python.org/downloads/release/python-3916/)
* [Python 3.8.16](https://www.python.org/downloads/release/python-3816/)
* [Python 3.7.16](https://www.python.org/downloads/release/python-3716/)

Feel free to help us by submitting
[merge requests](https://gitlab.com/python-devs/ci-images/merge_requests) or
[issues](https://gitlab.com/python-devs/ci-images/issues).

We are publishing this Docker image on
[GitLab](https://gitlab.com/python-devs/ci-images/container_registry).

For example:

```
$ docker run registry.gitlab.com/python-devs/ci-images:active python3.10 -c "import sys; print(sys.version)"
```

You can pull the container with this command:

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
