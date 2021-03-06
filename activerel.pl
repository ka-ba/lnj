#!/usr/bin/perl

use strict;
use warnings;
use v5.16;
#use Data::Dumper;
use List::Util qw(maxstr);
use Getopt::Long qw(GetOptions);
Getopt::Long::Configure qw(gnu_getopt);

sub getdata {
  my $line = shift @_;
  $line =~ s/"[^"]+"/XXX/;
  my @fields = split /\s*,\s*/, $line, -1;
  my $date;
  my $active;
  given( scalar @fields ) {
    when( 6 ) { undef $date; } # ignore silently
    when( 8 ) { $date=$fields[2]; $active=($fields[3]-$fields[4])-$fields[5]; }
    when( 12 ) { $date=$fields[4]; $active=$fields[10]; }
#    when( 13 ) { $date=$fields[4]; $active=$fields[10]; }
    when( 14 ) { $date=$fields[4]; $active=$fields[10]; }
#    when( 15 ) { $date=$fields[4]; $active=$fields[10]; }
    default { undef $date; print " X ", $line, "\n"; }
  }
  if( defined $date ) { # fiddle with date
    my @d = split /[ T]/, $date, 2;
    $date = $d[0];
    if( $date =~ /\// ) {
      undef $date;
    }
  }
  $active=0 if( $active eq "" );
#  print "    ---- ", $date, " -- ", $active, "  ---- ", $fields[2], " - ", $fields[3], "\n";
  return ( $date, $active );
}

#main

my %regions;
my $base = 10000;
GetOptions(
	'region|r=i%' => \%regions,
	'base|b=i' => \$base
) or die "usage: $0 [--base num]? [--region name=population]* files...\n";

#print Dumper(\%regions);

open( DATAFH, '>', 'hopkins.data' ) or die $!;
print DATAFH '#date';
foreach my $reg (sort keys %regions) {
	print DATAFH "   $reg";
}
print DATAFH "\n";

my %actives;
foreach my $reg (keys %regions) {
	$actives{$reg} = 0;
}
my @dates;

while(<>) {
  foreach my $reg (keys %regions) {
  	if( /$reg/ ) {
      my @data = getdata( $_ );
      if( (defined $data[0]) && ($data[1]>=0) ) { # $data[1]: compensate for strange US county "Recovered" with negative active case numbers >:/
        push @dates, $data[0];
        $actives{$reg} += ( $data[1] * $base ) / $regions{$reg};
      }
  	}
  }
  if( eof ) {
    my $date = maxstr( @dates );
    @dates = ();
#    print "    ---- ", $ARGV, " -- ", $date, "\n";
  	if( defined $date ) {
      print DATAFH "$date";
      undef $date;
      foreach my $reg (sort keys %regions) {
  		print DATAFH ( $actives{$reg}==0 ? "   ''" : "   $actives{$reg}" );
	    $actives{$reg} = 0;
  	  }
  	print DATAFH "\n";
  	}
  }
}
close( DATAFH );

open( GPLFH, '>', 'hopkins.gpl' ) or die $!;
print GPLFH <<EOT;
set xdata time
set timefmt "%Y-%m-%d"
set ylabel "per $base"

EOT
my $plot=0;
foreach my $reg (sort keys %regions) {
	print GPLFH ($plot?", \\\n     ":"plot ");
	$plot++;
	print GPLFH "'hopkins.data' using 1:",($plot+1)," title '$reg / $regions{$reg}' with linespoints"
}
print GPLFH <<EOT;


pause mouse close
EOT