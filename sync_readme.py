#!/usr/bin/env python3

"""Synchronise README.

Updates Python versions listed in README from 'versions.txt' (output
from `get_versions.py`.
"""

import os

from packaging import version as pkg_version

with open('versions.txt', 'r') as fp:
    versions_text = fp.read()

versions = []
for line in versions_text.splitlines():
    words = line.split()
    versions.append(words[0])
versions.sort(key=pkg_version.parse, reverse=True)

versions_lines = ['']
for version in versions:
    version_id = version.replace('.', '')
    versions_lines.append(
        f'* [Python {version}]'
        f'(https://www.python.org/downloads/release/python-{version_id}/)'
    )
versions_lines.append('')
versions_lines.append('')
versions_text = '\n'.join(versions_lines)

with open('README.md', 'r') as fp, open('README.md.swap', 'w') as fpo:
    for line in fp:
        fpo.write(line)
        if line == '<!-- BEGIN VERSIONS -->\n':
            break

    fpo.write(versions_text)

    for line in fp:
        if line == '<!-- END VERSIONS -->\n':
            fpo.write(line)
            break

    for line in fp:
        fpo.write(line)

os.rename('README.md.swap', 'README.md')
