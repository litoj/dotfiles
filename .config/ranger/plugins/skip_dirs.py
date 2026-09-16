from __future__ import absolute_import, division, print_function

import ranger.container.directory as dir_mod
from ranger.api.commands import Command

# Default skip list. Override from rc.conf without editing this file:
# skip_dirs .git,node_modules,bin,out
SKIP_DIRS = frozenset((".git", "node_modules", "bin", "out"))

_orig_walklevel = dir_mod.walklevel


def walklevel(some_dir, level):
    skip = SKIP_DIRS
    for root, dirs, files in _orig_walklevel(some_dir, level):
        dirs[:] = [d for d in dirs if d not in skip]
        yield root, dirs, files


dir_mod.walklevel = walklevel


class skip_dirs(Command):
    """:skip_dirs dir1,dir2,...

    Set folder names that flat view never enters.
    Use commas or spaces. No paths, only names.
    Run with no args to show the current list.
    """

    def execute(self):
        global SKIP_DIRS
        raw = self.rest(1).replace(",", " ")
        names = frozenset(part for part in raw.split() if part)
        if not names:
            self.fm.notify("skip_dirs: %s" % ", ".join(sorted(SKIP_DIRS)))
            return
        SKIP_DIRS = names
        self.fm.reload_cwd()
