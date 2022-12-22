import ranger.api
import sys
import os

old_hook_init = ranger.api.hook_init


def hook_init(fm):

    def on_cd():
        if fm.thisdir:
            sys.stderr.write("\033]0;ranger - " +
                             os.path.basename(fm.thisdir.path) + "\007")
            sys.stderr.flush()

    fm.signal_bind('cd', on_cd)
    return old_hook_init(fm)


ranger.api.hook_init = hook_init
