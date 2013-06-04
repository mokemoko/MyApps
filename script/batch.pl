use warnings;
use strict;
use MyApp;
use Catalyst::Stats;

# バッチ処理用スクリプト

my $app = MyApp->new( stats => Catayst::Stats->new );
my $res = $app->forward( '/path', [ "params" ] );
print $res;
