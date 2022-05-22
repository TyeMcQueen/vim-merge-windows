How to resolve a merge conflict
=

Follow the instructions in [INSTALL.text](INSTALL.text).  Then run
"git mergetool" and vim will launch showing 4 windows with differences
highlighted.  The code to be committed that has merge conflict indications
in it will be to the left with the cursor in it.  You can return to this
configuration of windows at any time by typing:

    :M mlbr

Search for the first conflict:

    /<<<<

Delete that "<<<<" line to make the differences line up better.  Make
edits so that the code in the left window includes the changes that are
either only in the 2nd (Local) or only in the 4th (Remote) window.  Changes
that are in the 3rd (Base) window as well as either the 2nd or 4th should
not be kept.

If some of the changes are not easily discernable, then find the most
obvious change and make that change to the 2 windows (Base plus either Local
or Remote) that don't already have it.  It can be more obvious that you have
done this correctly if you just look at the last 3 windows:

    :M lbr

When you have finished with that conflict, be sure to delete extra lines
up-to and including the ending ">>>>" line.

Repeat this process for the next conflict.

Once you have finished with every conflict, double check your work as
follows.  If you made any changes in any windows other than the first
one, then move to each window and undo all of your changes:

    :M l
    :e!

Now look at how your end results compare to the "local" version of the
file:

    :M ml

Compare that view to the differences that are shown after:

    :M rb

After a successful resolution, those sets of differences should be
identical or nearly so.

Then look at:

    :M mr

and compare it to:

    :M lb

Those sets of differences should also be identical or nearly so.

When you are satisfied:

    :xa
