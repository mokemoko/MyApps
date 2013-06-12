use warnings;
use strict;
use FindBin;
use lib "$FindBin::RealBin/../lib";
use MyApps;
use Catalyst::Stats;

my $app = MyApps->new(stats => Catalyst::Stats->new);
my @args = [];
my $res = $app->forward('/batch/getImages', @args);
