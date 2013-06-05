use strict;
use warnings;
use Test::More;


use Catalyst::Test 'MyApps';
use MyApps::Controller::Batch;

ok( request('/batch')->is_success, 'Request should succeed' );
done_testing();
