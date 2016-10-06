# lnj
replace multiple copies of a file by hard links to save disk space

DISCLAIMER:
-----------

You may not assume that this software is fit for any kind of job you might think it would do. I will not be responible for any loss of data.
Please form your own opinion about it's fitness by studying the source code. And remember: always have a recent backup of your data available. (And speaking of backups: always encrypt your backups. ;) )

Usage:
------

cd to the common parent dir of all files you'd like to link
call lnj with all filenames to consider; these filenames must not be used for other files

example:

cd ~/.eclipse
lnj ecplipse_update_120.jpg
