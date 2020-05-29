DISCLAIMER:
-----------

You may not assume that this software is fit for any kind of job you might think it would do. I will not be responible for any loss of data.
Please form your own opinion about it's fitness by studying the source code. And remember: always have a recent backup of your data available. (And speaking of backups: always encrypt your backups. ;) )

# lnj
replace multiple copies of a file by hard links to save disk space

Usage:
------

cd to the common parent dir of all files you'd like to link

call lnj with all filenames to consider; these filenames must not be used for other files

### example:

cd ~/.eclipse ;

lnj ecplipse_update_120.jpg

# extractDigikamPres.pl
copy all pictures mentioned in a Digikam-presentation into a specified dir, prefixing them with (or renaming to) a letter code to maintain presentation order as lexicographical filename order

you may have to install XML::Simple, in case your perl installation is missing it

Usage:
------

save presentation to a file ([jwd]/pres.xml) from within Digikam

call extractDigikamPres.pl with file and optional target dir

### example:

extractDigikamPres.pl --target ~/my-pres [jwd]/pres.xml

ls ~/my-pres

# activerel.pl
treat Hopkins CoViD19 data to show active cases with gnuplot

you'll need data from https://github.com/CSSEGISandData/COVID-19.git

