#!/usr/bin/env python

from setuptools import find_packages, setup

# Some duplication of properties here and in package.xml.
# Make sure to update them both.
d = setup(
    name='kobuki_documentation',
    # update package.xml, setup.py, conf.py
    # if it's a minor/major update
    #   - update source build wget branch in software.rst
    #   - update the build_sources workflow
    #   - create a new release branch
    version='1.0.0',
    packages=find_packages(exclude=['tests*', 'docs*']),
    author='Daniel Stonier',
    maintainer='Daniel Stonier <d.stonier@gmail.com>',
    url='http://github.com/kobuki-base/kobuki_documentation',
    keywords='robotics',
    zip_safe=True,
    description="documentation for the kobuki platform",
    long_description="Documentation for the kobuki platform.",
    license='BSD',
)
