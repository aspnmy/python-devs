#! /usr/bin/env python3
import os
import urllib.request
from bs4 import BeautifulSoup
from packaging import version

SERIES = ['2.7', '3.5', '3.6', '3.7', '3.8', '3.9']


def get_release_page():
    with urllib.request.urlopen('http://python.org/downloads') as response:
        html = response.read()
    return html


def get_all_versions(html):
    soup = BeautifulSoup(html, features="html.parser")
    versions = soup.find_all('span', class_='release-number')
    versions = (version.parse(v.get_text().split()[-1])
                for v in versions
                if v.get_text() != 'Release version')
    return list(versions)


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
    html = get_release_page()
    all_versions = get_all_versions(html)
    latest_versions = get_latest_version(all_versions)

    with open('version.txt', 'w') as fd:
        for key, value in latest_versions.items():
            print(f'{key} Series: {value}')
            print(value, file=fd)

if __name__ == "__main__":
    main()
