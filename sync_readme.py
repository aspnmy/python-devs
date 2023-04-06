#!/usr/bin/env python3

"""Synchronise README.

Updates Python versions listed in README from 'versions.txt' (output
from `get_versions.py`.
"""

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

with open('README.md', 'r') as fp:
    readme_text = fp.read()

versions_start_marker = '<!-- BEGIN VERSIONS -->\n'
versions_start_index = readme_text.index(versions_start_marker)
versions_start_index += len(versions_start_marker)

versions_end_marker = '<!-- END VERSIONS -->\n'
versions_end_index = readme_text.index(versions_end_marker)

readme_text = (
    readme_text[:versions_start_index]
    + versions_text
    + readme_text[versions_end_index:]
)

with open('README.md', 'w') as fp:
    fp.write(readme_text)
