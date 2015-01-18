use warnings;
use strict;
use FindBin;
use lib "$FindBin::RealBin/../lib";
use MyApps;
use Catalyst::Stats;

my $target = shift(@ARGV) || '';

my $allow = {
  getImages => 1,
  getThumbs => 1,
  getStocks => 1,
  doTransrate => 1,
};

unless ($allow->{$target}) {
  print "invalid argument\n";
  exit;
}

my $app = MyApps->new(stats => Catalyst::Stats->new);
my $res = $app->forward("/batch/$target", [@ARGV]);
