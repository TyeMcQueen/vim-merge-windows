Description
=

When using "vimdiff" to resolve a merge conflict, vim-merge-windows makes
it trivial to control the presentation of the windows for the different
instances of the conflicted file (the Merged end result, the Local version,
the Remote version, and the Base version of the file).  That is, you can
pick which buffers to show, in what order, and which ones are being 'diff'ed
and quickly change between arrangements.

vim-merge-windows also includes a small Perl script, pdiff, that allows
one to use git's implementation of "patience diff" as the diff engine for
vimdiff.  This can make a 'diff' much more useful by preventing it from
deciding that the important thing is how the *blank* lines line up together.

vim-merge-windows is a small, self-contained utility that is very light-
weight and easy to add to vim.  It currently is targetted only toward
being used from git-mergetool but it should be easy to extend to support
other conventions and so such support will likely be added in future.

The following optional (but standard) features of vim are required:

    +diff
    +eval
    +folding (not strictly required)
    +listcmds
    +vertsplit
    +windows

Basics
=

It is implemented as a single command, :M, that uses a single function,
MergeWindows, which is written in vimscript (so no non-default embedded
language is required).

No key bindings are set by default so you don't have to worry about it
messing up any of your custom key bindings.  The :M command is so simple and
terse to use, you might never decide to make your own, shorter key bindings.

A short sample of things you can do with the :M command:

    :M mlbr     # Show Merged, Local, Base, Remote in that order
    :M lb       # Show just Local and Base, diff'ing them
    :M Mrb      # Show Merge, Remote, Base but only diff'ing Remote, Base
    :M b        # Just move cursor to Base buffer (making it appear, if hidden)
    :M L        # Show only the Local buffer
    :M -        # Hide the current window
    :M =        # Turn off "diff" for the current window
    :M +        # Turn on "diff" for the current window
    :M -b       # Hide the Base buffer
    :M 2        # Move the current window to be 2nd-from-the-left
    :M 8        # Move the current window to be 2nd-from-the-right
    :M +m9      # Move/show Merged to be at the far right, turning on 'diff'
    :M -b+m2r9  # Do ":M -b", ":M +m2", and ":M +r9"
    :M .        # Re-initialize the letters to use based on current windows.
    :M .abcD    # Reset to use abcd for 4 current windows, diff all but last.

See Also
=

See [INSTALL](INSTALL.text) for installation instructions.

See [Usage](Usage.text) for more details about using ":M".

See [Merging](Merging.md) for more techniques for resolving merge conflicts.
