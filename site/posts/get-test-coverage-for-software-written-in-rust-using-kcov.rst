.. title: Get test coverage for software written in Rust using Kcov
.. slug: get-test-coverage-for-software-written-in-rust-using-kcov
.. date: 2018-01-31 12:04:00 UTC
.. tags: Rust
.. category: Programming
.. link:
.. description:
.. type: text

To get test coverage for your Rust code, you can use `kcov`_.

.. code:: zsh

  % cargo test
  % kcov --include-path ./src ./target/coverage target/debug/<name>-*


It generates pretty HTML and JSON report files that include also coverage score.  
And, this one liner can extract percentage value from ``index.json``, if you want.

.. code:: zsh

  % grep -oE 'covered":"([0-9]*\.[0-9]*|[0-9]*)"' target/coverage/index.json | \
      grep -oE '[0-9]*\.[0-9]*|[0-9]*'
  4.5


Ohh, ``4.5%`` .. !!!
Anyway, if you run the test on GitLab CI, there is pattern matching on general settings,
So we can just like this:

.. code:: zsh

  : in .gitlab-ci.yml
  % cat target/coverage/index.json

And then, use pattern something like this:

.. code:: text

  "covered":"(\d+(?:\.\d+)?)",


This seems that it usually works well. But I faced still some problems on CI.


Trouble Shooting
----------------

SIGSEGV
~~~~~~~

According to `issue #212 (SimonKagstrom/kcov)`_, you can pass ``--include-path`` to avoid
this SIGSEGV error.

.. _`issue #212 (SimonKagstrom/kcov)`: https://github.com/SimonKagstrom/kcov/issues/212


With this option, it worked fine also on my code. But, for now, in some project,
it seems that it might not work, properly. I found `pull request #55 (sagiegurari/cargo-make)`_.

.. _`pull request #55 (sagiegurari/cargo-make)`: https://github.com/sagiegurari/cargo-make/pull/55


Cannot open linux-vdso.so.1
~~~~~~~~~~~~~~~~~~~~~~~~~~~

In local machine (Gentoo Linux, 64bit), ``kcov`` which is installed via Portage, works fine with my Rust code, 
but I faced this error on GitLab CI (Debian). This problem also discussed on `issue #26 (SimonKagstrom/kcov)`_.

.. _`issue #26 (SimonKagstrom/kcov)`: https://github.com/SimonKagstrom/kcov/issues/26


I've installed kcov via ``apt-get`` (with cache configuration).

.. code:: yaml

  test:
    stage: test
    image: rust:latest
    ...
    variables:
      APT_CACHE_DIR: apt-cache
    before_script:
      # this lines install kcov
      - mkdir -pv $APT_CACHE_DIR && apt-get -qq update
      - apt-get -qq -o dir::cache::archives="$APT_CACHE_DIR" install -y kcov
    ...
    cache:
      untracked: true
      paths:
        - apt-cache
    ...


.. code:: yaml

  test:
    ...
    after_script:
      - kcov --include-path src target/coverage target/debug/<name>-*
      - cat target/coverage/index.json
    ...


.. raw:: bash

  : output on GitLab CI
  $ kcov --include-path src target/coverage target/debug/20min-*

  running 0 tests

  test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 1 filtered out

  Error: Cannot open linux-vdso.so.1


Hmm, it seems that kcov on Debian is a little bit old (11.1?). And it does not have
even `--version` option.

So, finally, I wrote a build script using newest version (version 34) with
cache support on CI.


Build Script
------------

This is a small bash script to build/install kcov into *kcov* directory on project root.

.. code:: bash

  #!/bin/bash
  set -eu

  # NOTE:
  # if set KCOV_DISCARD_CACHE=true, then it will force installing kcov)

  renew="${KCOV_DISCARD_CACHE:-false}"

  kcov_dir="kcov"
  kcov_bin="${kcov_dir}/bin/kcov"
  kcov_url="https://github.com/SimonKagstrom/kcov/archive"
  kcov_ver="v34"

  if [[ -f "${kcov_bin}" && "${renew}" != "true" ]]; then
    echo "kcov already installed in ${kcov_bin}"
  else
    rm -fr $kcov_dir
    mkdir $kcov_dir
    cd $kcov_dir
    curl -sLO ${kcov_url}/${kcov_ver}.tar.gz
    mkdir $kcov_ver
    tar zxvf ${kcov_ver}.tar.gz -C $kcov_ver --strip-components=1
    cd $kcov_ver
    mkdir build
    cmake \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/
    make
    make install DESTDIR=../
  fi

And ``.gitlab-ci.yml`` will be something like this (
In addition to dependencies listed in INSTALL.md of kcov, you need also ``cmake``):

.. code:: yaml

  test:
    stage: test
    image: rust:latest
    variables:
      KCOV_DISCARD_CACHE: "false"
      APT_CACHE_DIR: apt-cache
    before_script:
      - mkdir -pv $APT_CACHE_DIR && apt-get -qq update
      - apt-get -qq -o dir::cache::archives="$APT_CACHE_DIR" install -y
        binutils-dev libcurl4-openssl-dev zlib1g-dev libdw-dev libiberty-dev
        cmake
      - ./bin/build-kcov
      - rustc --version
      - cargo --version
      - ./kcov/bin/kcov --version
    script:
      - cargo test
    after_script:
      - ./kcov/bin/kcov --include-path src target/coverage target/debug/20min-*
      - cat target/coverage/index.json
    cache:
      untracked: true
      paths:
        - apt-cache
        - kcov
    except:
      - tags

Set ``KCOV_DISCARD_CACHE`` as ``true``, if you need to force re:install kcov.
The kcov directory will be normally cached on GitLab CI!

I made also `make cov`_ target to check it on local, and a `ci-runner`_ script run CI docker container on local.

Check it out on my small project repo `grauwoelfchen/20min`_ ;)

.. _`make cov`: https://gitlab.com/grauwoelfchen/20min/blob/master/Makefile
.. _`ci-runner`: https://gitlab.com/grauwoelfchen/20min/blob/master/bin/ci-runner
.. _`grauwoelfchen/20min`: https://gitlab.com/grauwoelfchen/20min


References
----------

* `kcov`_
* `INSTALL.md (SimonKagstrom/kcov)`_ (master)
* `.gitlab-ci.yml (imp/libcratesio-rs)`_
* `commit 8870402a (victor-engmark/rust-intro)`_


.. _`kcov`: https://github.com/SimonKagstrom/kcov
.. _`INSTALL.md (SimonKagstrom/kcov)`: https://github.com/SimonKagstrom/kcov/blob/master/INSTALL.md
.. _`.gitlab-ci.yml (imp/libcratesio-rs)`: https://gitlab.com/imp/libcratesio-rs/blob/master/.gitlab-ci.yml
.. _`commit 8870402a (victor-engmark/rust-intro)`: https://gitlab.com/victor-engmark/rust-intro/commit/8870402abaca8e50691ce4b1a96d825dc2dda6d8#587d266bb27a4dc3022bbed44dfa19849df3044c
