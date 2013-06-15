use warnings;
use strict;
use FindBin;
use lib "$FindBin::RealBin/../lib";
use MyApps;
use Catalyst::Stats;

my $target = $ARGV[0] || '';

unless ($target eq 'getImages' || $target eq 'getThumbs') {
  print "invalid argument\n";
  exit;
}

my $app = MyApps->new(stats => Catalyst::Stats->new);
my @args = [];
my $res = $app->forward("/batch/$target", @args);
