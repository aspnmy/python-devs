#! /usr/bin/env python3
import os
import json
import urllib.request
from packaging import version

SERIES = ['2.7', '3.5', '3.6', '3.7', '3.8', '3.9', '3.10']


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
                version.parse(item.get('ref').replace('refs/tags/v', ''))
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

def main():
    # html = get_release_page()
    # all_versions = get_all_versions(html)
    gh_response = get_tags_from_github()
    all_versions = get_version_from_tags(gh_response)
    latest_versions = get_latest_version(all_versions)

    with open('version.txt', 'w') as fd:
        for key, value in latest_versions.items():
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
