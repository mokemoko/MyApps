use strict;
use warnings;

use MyApps;

my $app = MyApps->apply_default_middlewares(MyApps->psgi_app);
$app;

