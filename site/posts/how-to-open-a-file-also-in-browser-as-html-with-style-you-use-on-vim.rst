.. title: How to open a file also in browser as HTML with style you use on Vim
.. slug: how-to-open-a-file-also-in-browser-as-html-with-style-you-use-on-vim
.. date: 2018-10-02 18:56:04 UTC
.. tags: HTML, Vim
.. category: Programming
.. link:
.. description:
.. type: text

TLDR: you can do it with some plugins like this. This opens the README.md in
Vim (raw and HTML) and also in browser (HTML).

.. code:: zsh

  % vim README.md -c "%TOhtml|b2|call quickrun#run()|q"

  # with `zO` (foldings)
  % vim README.md -c "%foldopen!|%TOhtml|b2|call quickrun#run()|q"


You need:

* `tryu/open-browser.vim`_
* `thinca/quickrun`_

.. _tryu/open-browser.vim: https://github.com/tyru/open-browser.vim
.. _thinca/quickrun: https://github.com/thinca/vim-quickrun


.. image:: /attachments/how-to-open-a-file-also-in-browser-as-html-with-style-you-use-on-vim-20181002.png
   :alt: Screenshot of this article's reStructuredText as HTML on browser

Vim commands from command line
------------------------------

``Vim`` takes 2 type options for commands,

According help,

* ``--cmd <command>`` execute <command> before loading any vimrc file
* ``-c <command>`` execute <command> after loading the first file


In this case, we need `-c <command>` because we want to handle the target file.


Vim Commands
------------

Let's look the parts of ``%TOhtml|b2|call quickrun#run()|q``, one by one.

%foldopen!
----------

This is optional.

Without this command, if you have some `fold` (s) in the file, it will be
converted exactly look like.

e.g. HTML of My .vimrc (without ``%foldopen!``)

.. image:: /attachments/my-vimrc-with-foldings-as-html-20181002.png
   :alt: My .vimrc with foldings as HTML

``%`` means whole content, ``!`` means ``foldopen`` works recursively.


%TOhtml
~~~~~~~

``:[range]TOhtml`` is a standard plugin. (included in Vim)

You can specify ``%`` as range for entire file content (same as for ``foldopen``).

This command converts current Text into HTML with your current color scheme.

b2
~~

``b``, ``bu``, ``buf``, ``buffer`` are all same.

``b2`` is a switching to second buffer, because ``TOhtml`` opens converted HTML
file into second (next) buffer.


call quickrun#run()
~~~~~~~~~~~~~~~~~~~

quickrun_ is a plugin to do something to current file.

I have settings for HTML file type in vimrc like this:

.. code:: vim

   let g:quickrun_config['html'] = {
   \ 'command': 'cat',
   \ 'outputter': 'browser',
   \ 'exec': "%c %s",
   \}

For ``browser`` outputter, you need also `open-browser.vim`_.

If you have above settings, you can just run `QuickRun` command to open current
HTML file in browser. (I like to just type ``<leader>r``.)

You can set various behaviors for any filetype.

To avoid some errors, I use ``quickrun#run()`` function via ``call`` instead of
``QuickRun`` here.

.. _open-browser.vim: `tryu/open-browser.vim`_
.. _quickrun: `thinca/quickrun`_

q
~

Finally, ``q`` will close only HTML buffer. But HTML file is also still in
there.

.. code:: text

  :buffers
  1 %a   "/path/to/file"         line 3
  2 #h + "/path/to/file.html"    line 2

HTML will be appeared in your browser, but original file is also still opend
in Vim ;)


Scripts
-------

There are scripts I named it `"often"` (Open File as hTml via Editor commaNd)

Without ``%foldopen!`` (simple version):

.. code:: sh

   #!/bin/sh
   vim "$1" -c "%TOhtml|b2|call quickrun#run()|q"


With `-zO` (same ``%foldopen!``) option (full version):

.. code:: sh

   #!/bin/sh

   options=zO

   _=`getopt --name "${0}" \
   --options "${options}" --unquoted -- "${@}"`

   if [ $? -ne 0 ]; then
     exit 2
   fi

   with_foldopen=0
   target_file="${0}" # default

   while [ $# -gt 0 ]; do
     case "${1}" in
       -zO)
         echo "${1}"
         with_foldopen=1
         shift
         ;;
       *)
         target_file="${1}"
         shift
         ;;
     esac
   done

   commands="%TOhtml|b2|call quickrun#run()|q"
   if [ $with_foldopen -eq 1 ]; then
     commands="%foldopen!|${commands}"
   fi

   vim "${target_file}" -c "${commands}"


You can do this (open often script itself!):

.. code:: zsh

   # simple version
   % often /path/to/often

   # full version
   % often
   % often -zO /path/to/often

If you use browser in fullscreen mode, you may be confused.
I often try to edit the HTML file, accidentaly ;)

.. image:: /attachments/often-often-20181002.png
   :alt: Result of `often /path/to/often`
