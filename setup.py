import os
import sys

from setuptools import setup, find_packages

# pylint: disable=invalid-name
DESCRIPTION = ''

here = os.path.abspath(os.path.dirname(__file__))
with open(os.path.join(here, 'CHANGELOG')) as f:
    CHANGELOG = f.read()

requires = [
    'Nikola',
]

development_requires = [
    'ws4py',
    'watchdog',
]

testing_requires = [
]

production_requires = [
]

setup(
    name='Grauwoelfchen\'s Canvas',
    version='0.0.1',
    description='',
    long_description=DESCRIPTION + '\n\n' + CHANGELOG,
    classifiers=[
        "Programming Language :: Python",
        "Topic :: Internet :: WWW/HTTP",
        "Topic :: Internet :: WWW/HTTP :: WSGI :: Application",
    ],
    author='Yasuhiro Asaka',
    author_email='yasuhiro.asaka@grauwoelfchen.net',
    url='https://grauwoelfchen.at',
    keywords='web',
    packages=find_packages(),
    include_package_data=True,
    zip_safe=False,
    extras_require={
        'development': development_requires,
        'testing': testing_requires,
        'production': production_requires,
    },
    install_requires=requires,
)
