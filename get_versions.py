#!/usr/bin/env python3

"""Get the active Python versions from the repo's git tags.

One downside is that we can't get the version of the main branch before the
first alpha release of the in-development version.  There are no tags until
the first alpha.
"""

import os
import sys
import json
import urllib.request

from datetime import date
from enum import Enum, auto
from packaging import version as pkg_version


# For production.
SERIES = ['3.8', '3.9', '3.10', '3.11', '3.12', '3.13']

# For testing.  This should match Dockerfile app version of Python.
#SERIES = ['3.10']


class Auto(Enum):
    def _generate_next_value_(name, start, count, last_values):
        return name


class Series(Auto):
    latest = auto()
    active = auto()


def get_tags_from_github():
    with urllib.request.urlopen(
            'https://api.github.com/repos/python/cpython/git/refs/tags'
    ) as response:
        val = response.read()
    res = json.loads(val)
    return res


def get_version_from_tags(tags):
    versions = []
    for item in tags:
        if item.get('ref').startswith('refs/tags/v'):
            versions.append(
                pkg_version.parse(item.get('ref').replace('refs/tags/v', ''))
                )
    return versions


def get_latest_version(all_versions):
    # mapping from series to latest.
    latest = {}
    for version in all_versions:
        series = f'{version.major}.{version.minor}'
        if series in latest:
            if latest.get(series) < version:
                latest[series] = version
        else:
            latest[series] = version
    return {key: value for key, value in latest.items() if key in SERIES}


def get_version_eols():
    with urllib.request.urlopen(
        'https://endoflife.date/api/python.json'
    ) as response:
        val = response.read()
    res = json.loads(val)
    # all we care about is the MAJOR.MINOR->EOL date mapping
    return {
        release['cycle']: date.fromisoformat(release['eol'])
        for release in res
    }


def which_series():
    # For the latest/main series, we build every version of Python that we can
    # build, at least as specified in the `SERIES` variable above.  For the
    # active series, we only build that set of Pythons that have not EOL'd.
    # The .gitlab-ci.yml file passes the commit and merge request target
    # branches to the Dockerfile, which sets environment variables that this
    # script can use to determine which series to build.
    #
    # This environment variable will be passed in from the .gitlab-ci-yml file
    # to the Dockerfile to us.
    requested = os.environ.get('SERIES')
    try:
        series = Series[requested]
    except KeyError:
        print(f'Run with SERIES={"|".join(Series.__members__)}')
        sys.exit(1)
    print(f'Building for series: {series}')
    return series


def main():
    gh_response = get_tags_from_github()
    all_versions = get_version_from_tags(gh_response)
    latest_versions = get_latest_version(all_versions)
    version_eols = get_version_eols()

    today = date.today()
    series = which_series()

    with open('versions.txt', 'w') as fd:
        # Build latest to oldest, primarily for better testing of the new free-threading builds.
        for key, value in reversed(latest_versions.items()):
            # for the `active` branch, filter out any eol'd versions.
            if series is Series.active and not value.is_prerelease:
                if (eol := version_eols.get(key)) is None:
                    print(f'No EOL data for {key}... assume active')
                elif today > eol:
                    continue
            print(f'{key} Series: {value}')
            if value.is_prerelease:
                # pre-releases are under directory which skips the pre-release
                # markers, so print the directory path.
                print(f'{value} {value.major}.{value.minor}.{value.micro}',
                      file=fd)
            else:
                print(value, file=fd)


if __name__ == "__main__":
    main()
