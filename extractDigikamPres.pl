#!/usr/bin/perl

use Getopt::Long qw(GetOptions);
use XML::Simple;
use File::Fetch;
use File::Basename;
use Data::Dumper;
Getopt::Long::Configure qw(gnu_getopt);

############################ usage ############################

# usage(string)
sub usage {
  my $msg = shift;
  print $msg."\n" if $msg ne "";
  print "Usage:\n";
  print $my_name." [options] [src file name]\n";
  print "  -t, --target  specify target dir\n";
  print "  -p            generate pure code-names (i.e. dont use old filename)\n";
  print "  -v            be verbose\n";
 die;
}

############################ code gen ############################
# TODO: rewrite as class

$cg_len=-1;
$cg_inc=-1;
$cg_last=0;
$cg_pure=false;

# cg_init(int,int,bool)
sub cg_init {
  my $count = shift;
  $cg_inc = 1 + shift;
  $cg_pure = shift;
  my $max = ($cg_inc) * ($count+1);
  $cg_len = log($max) / log(26);  # log_26(max)=log(max)/log(26)
  $cg_len = int($cg_len) + 1;
  #print 'calculated code length of '.$cg_len." chars\n";
}

sub cg_code {
  my $num = shift;
  my @buf = ();
  for( my $i=0; $i<$cg_len; $i++ ) {
    use integer;
    my $rest = $num;
    if( $num > 25 ) {
      $rest = $num % 26;
    }
    unshift @buf, chr( ord('a')+$rest );
    $num = $num / 26;
  }
  return join( '', @buf );
}

# string cg_next(Fetch)
sub cg_next {
  my $where = shift;
  $cg_last += $cg_inc;
  $fcode = cg_code($cg_last);
  my ($fname,$fpath,$fext) = fileparse( $where, qr/\.[^.]+/ );
  if($cg_pure) {
    return $fpath.$fcode.$fext;
  } else {
    return $fpath.$fcode.'-'.$fname.$fext;
  }
}

############################ main ############################

$my_name = $0;

# parse args
my $source_file = 'list.xml';
my $target_dir = '.';
my $verbose;
my $pure_name;

GetOptions(
  'target|t=s' => \$target_dir,
  'p' => \$pure_name,
  'v' => \$verbose ) or die usage();
$source_file = shift @ARGV if scalar(@ARGV)>0;
die usage('too many arguments') if scalar(@ARGV)>0;

#print $source_file ."\n";
#print $target_dir ."\n";

$xml = new XML::Simple;

$pres = $xml->XMLin( $source_file );
@images = @{$pres->{Image}};

cg_init( scalar(@images), 3, $pure_name );  # count, gap
if($verbose) {
  print 'digikam presentation contains '.scalar(@images)." pictures\n";
}
#print Dumper($pres);

foreach $i (@images) {
  my $ff = File::Fetch->new( uri => $i->{url} );
  my $where = $ff->fetch( to => $target_dir ) or print $ff->error;
  if( $where ) {
    my $newname = cg_next($where);
    if($verbose) {
      print $newname.' <- '.$where.' <- '.$i->{url}."\n";
    }
    rename $where, $newname;
  }
}

############################ references ############################

# XML::Simple usage:
# https://www.techrepublic.com/article/parsing-xml-documents-with-perls-xmlsimple/

# Getopt::Long usage
# https://perlmaven.com/how-to-process-command-line-arguments-in-perl

# File::Fetch usage:
# http://perldoc.perl.org/File/Fetch.html
