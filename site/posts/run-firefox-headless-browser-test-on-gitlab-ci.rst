.. title: Run Firefox Headless Browser tests on GitLab CI
.. slug: run-firefox-headless-browser-tests-on-gitlab-ci
.. date: 2018-03-18 06:18:04 UTC
.. tags: Testing, JavaScript
.. category: Programming
.. link:
.. description:
.. type: text

| You have some tests on Firefox Headless mode, and that would work fine on  
| your local machine. For example, using Karma:

.. code:: zsh

  % npm run karma

  : run just it like normal
  % ./node_modelus/.bin/karma start karma.conf.js


| I wanted here to use `karma-firefox-runner`_ as ``"FirefoxHeadless"`` for the
| tests. (e.g. my project `Vergil`_)

.. _`karma-firefox-runner`: https://github.com/karma-runner/karma-firefox-launcher
.. _`Vergil`: https://gitlab.com/grauwoelfchen/vergil/blob/6a2db271e96d9be342ec8921a336fd5728696c75/karma.conf.js#L25


It succeeded well on my local machine. But I faced some issues to run it on CI
(GitLab CI).

This is a note to resolve the issues.


Browser is missing
------------------

.. code:: text

  : on CI
  $ npm run karma

  > <PACKAGE-NAME>@0.0.1 karma /builds/grauwoelfchen/<PACKAGE-NAME>
  > karma start karma.conf.js


  # tests 0

  tests 0
  # pass  0

  pass  0
  # ok
  ✓ oknpm ERR! code ELIFECYCLE
  npm ERR! errno 1
  npm ERR! <PACKAGE-NAME>@0.0.1 karma: `karma start karma.conf.js`
  npm ERR! Exit status 1
  npm ERR! ...

This error is likely happend on a situation, that the script can't find
the certain browser installed there.
In my case, I just forgot to install the Firefox on this environment,
and installed it on strange location ;)

| So, update ``.gitlab-ci.yml``. It will look like this.
| (This sample is on Node.js image, just installes ``firefox-esr`` on Debian)

.. code:: yaml

  test:
    stage: test
    image: node:8.9.4
    services:
    variables:
      NODE_ENV: test
      APT_CACHE_DIR: apt-cache
    before_script:
      - mkdir -pv $APT_CACHE_DIR && apt-get -qq update
      - apt-get -qq -o dir::cache::archives="$APT_CACHE_DIR" install -y
        firefox-esr
      - firefox --version
      - node --version
      - npm --version
      - npm install
      - npm run build
    script:
      - npm run karma
    cache:
      untracked: true
      paths:
        - apt-cache
        - node_modules
    except:
      - tags


GDK_BACKEND does not match
--------------------------

.. code:: text

  : on CI
  $ firefox --version
  Mozilla Firefox 52.7.2

The browser (Firefox) is now installed, However it won't run tests, and fail
to start it on CI environment, because it does not have ``GDK`` for the UI and
``DISPLAY``.

.. code:: text

  18 03 2018 06:45:30.601:ERROR [launcher]: Cannot start FirefoxHeadless
          Error: GDK_BACKEND does not match available displays

  18 03 2018 06:45:30.604:ERROR [launcher]: FirefoxHeadless stdout: 
  18 03 2018 06:45:30.605:ERROR [launcher]: FirefoxHeadless stderr: Error: GDK_BACKEND does not match available displays

  18 03 2018 06:45:30.638:ERROR [launcher]: Cannot start FirefoxHeadless
          Error: GDK_BACKEND does not match available displays

  18 03 2018 06:45:30.638:ERROR [launcher]: FirefoxHeadless stdout: 
  18 03 2018 06:45:30.638:ERROR [launcher]: FirefoxHeadless stderr: Error: GDK_BACKEND does not match available displays

  18 03 2018 06:45:30.668:ERROR [launcher]: Cannot start FirefoxHeadless
          Error: GDK_BACKEND does not match available displays

  18 03 2018 06:45:30.669:ERROR [launcher]: FirefoxHeadless stdout: 
  18 03 2018 06:45:30.669:ERROR [launcher]: FirefoxHeadless stderr: Error: GDK_BACKEND does not match available displays

  18 03 2018 06:45:30.670:ERROR [launcher]: FirefoxHeadless failed 2 times (cannot start). Giving up.
  # tests 0
  # pass  0
  ✓ ok


Hmm, these tests work on **HEADLESS** browser. Why does it need those
libraries for UI components?

Appearantly, it seems that for right now, Firefox Headless requires
some those dependencies what are not even used.

See: https://developer.mozilla.org/en-US/Firefox/Headless_mode

(from "Troubleshooting and further help" section)

    On Linux, certain libraries are currently required on your system, even
    though headless mode doesn't use them, as Firefox links against them.
    See bug 1372998, for more details and progress towards a fix.


This little bit confused me. I didn't notice that the issue on my local,
because it already have those libraries.


On Bugzilla: https://bugzilla.mozilla.org/show_bug.cgi?id=1372998

They reported this issue, and talked.

    GLib may be unavoidable, but GTK+ and especially Xvfb (and any another X11
    implementation) should be optional for Linux systems that run Firefox
    headlessly.


This comment helped me. It seems that **xvfb** is needed, at least, for now.

| So let's run tests using `Xvfb` (xvfb-run).  
| Install `xvfb-run` for Gentoo Linux, `xvfb` for Debian.

.. code:: zsh

    : on Gentoo Linux
    ❯❯❯ equery l -po xvfb-run
     * Searching for xvfb-run ...
    [--O] [  ] x11-misc/xvfb-run-1.18.4_p2:0
    [I-O] [  ] x11-misc/xvfb-run-1.19.3_p2:0


And check it on local machine (especially to run it fine on Docker container
like CI environment).

Run tests xvfb-run on local
~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code:: text

  : check it on local
  % xvfb-run npm run karma


Run tests on local GitLab CI Container
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

I always do it with local runner using following scripts.


At first, Install runner binary provided from GitLab.  

NOTE
  This runner is still old version. I should migrate it to new one.
  But it's next time ;)

.. code:: zsh

  #!/bin/sh
  set -eu

  bin_dir=$(dirname $(readlink -f "${0}"))
  name="gitlab-ci-multi-runner"
  platform="linux-amd64"
  version="latest"

  indent() {
    sed -u 's/^/       /'
  }

  echo "Platform: ${platform}"
  echo "Version: ${version}"
  echo ""
  echo "-----> Installing into: ${bin_dir}"

  location_base="https://gitlab-ci-multi-runner-downloads.s3.amazonaws.com"
  location="${location_base}/${version}/binaries/${name}-${platform}"

  curl -sL $location -o $bin_dir/$name

  chmod +x $_

  echo "Done" | indent


And start docker.  
As next, create `ci-runner` script like below.

.. code:: zsh

  #!/bin/sh
  set -x

  dir_name=$(dirname $(dirname $(readlink -f $0)))
  job_name="${1}"
  env_file="${ENV_FILE:-.env.ci}"
  env_opts="";

  if [ -z "${job_name}" ]; then
    echo "Please specify job name in .gitlab-ci.yml"
    exit 2
  fi

  if [ ! -f "${env_file}" ]; then
    echo "Please create \`${env_file}\` (cp ${env_file}.sample ${env_file})"
    exit 2
  fi

  while read line; do
  env_opts+=" --env ${line}"
  done < "${env_file}"

  # ci-runner <job>
  echo "${env_opts} ${job_name}" | \
    xargs $dir_name/bin/gitlab-ci-multi-runner exec docker \
    --cache-dir /cache \
    --docker-privileged \
    --docker-volumes $dir_name/tmp/_cache:/cache \
    --docker-volumes /var/run/docker.sock:/var/run/docker.sock


| Set secret environment variables in `.env` like you do on CI, as you need,
| then just run it.

.. code:: zsh

   % cp .env.ci.sample .env.ci

   : this script takes job name as argument
   % ./bin/ci-runner <JOB-NAME>


It will run tests almost same as GitLab CI. You can check it before pushing it
on the remote.


Conclusion
----------

* Use `xvfb` (xvfb-run) for test on Firefox Headless on CI (Firefox 52, 18. March 2018)
* Check it to run on your local machine same with the CI

Finally, my `.gitlab-ci.yml` looks like this:

.. code:: yaml

  test:
    stage: test
    image: node:8.9.4
    services:
    variables:
      NODE_ENV: test
      APT_CACHE_DIR: apt-cache
    before_script:
      - mkdir -pv $APT_CACHE_DIR && apt-get -qq update
      - apt-get -qq -o dir::cache::archives="$APT_CACHE_DIR" install -y
        xvfb firefox-esr
      - firefox --version
      - node --version
      - npm --version
      - npm install
      - npm run build
    script:
      - xvfb-run npm run karma
    cache:
      untracked: true
      paths:
        - apt-cache
        - node_modules
    except:
      - tags


Thank you Gitlab, for the great runner, and Mozilla, for Firefox Headless!

Happy testing ;)


References
----------

* `Using Headless Mode in Firefox – Mozilla Hacks – the Web developer blog`_
* `Headless mode - Mozilla | MDN`_
* `1372998 - don't require X11, GTK+, and (if possible) GLib in headless mode`_


.. _`Using Headless Mode in Firefox – Mozilla Hacks – the Web developer blog`: https://hacks.mozilla.org/2017/12/using-headless-mode-in-firefox/
.. _`Headless mode - Mozilla | MDN`: https://developer.mozilla.org/en-US/Firefox/Headless_mode
.. _`1372998 - don't require X11, GTK+, and (if possible) GLib in headless mode`: https://bugzilla.mozilla.org/show_bug.cgi?id=1372998
