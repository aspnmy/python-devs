#!/usr/bin/env python3

import sys
import pprint
import subprocess


testables = {}

with open('/usr/local/bin/versions.txt', encoding='utf-8') as fp:
    # Each line will contain either one entry, in which case that's the exact
    # version and series to use, or two lines where the first word is the
    # exact version and the second word is the series.  This latter is mostly
    # to handle pre-release versions.  E.g.
    #
    # 3.9.6
    # 3.10.0rc1 3.10.0
    #
    # What we want is the major.minor version so we can invoke the
    # interpreter, and the value that will be returned by `pythonX.Y -V`.
    # We'll use those to compare in the test.
    for line in fp.read().splitlines():
        words = line.split()
        if len(words) == 1:
            version = series = words[0]
        else:
            assert len(words) == 2
            version, series = words
        major, minor = series.split('.')[:2]
        testables[f'python{major}.{minor}'] = f'Python {version}'


FAIL = []
PASS = []

for exe, output in testables.items():
    proc = subprocess.run([exe, '-V'], capture_output=True, text=True)
    # Python 2.7 prints its version string to stderr, Python 3 to stdout.
    version = proc.stdout.strip() + proc.stderr.strip()
    if proc.returncode != 0:
        FAIL.append(exe)
    elif version != output:
        FAIL.append(exe)
    else:
        PASS.append(exe)


print(f'PASS: {PASS}')
print(f'FAIL: {FAIL}')

if len(FAIL) > 0:
    pprint.pprint(testables)


sys.exit(len(FAIL))
