use strict;
use warnings;
use Test::More;


use Catalyst::Test 'MyApps';
use MyApps::Controller::image;

ok( request('/image')->is_success, 'Request should succeed' );
done_testing();
