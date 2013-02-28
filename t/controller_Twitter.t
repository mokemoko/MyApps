use strict;
use warnings;
use Test::More;


use Catalyst::Test 'MyApps';
use MyApps::Controller::Twitter;

ok( request('/twitter')->is_success, 'Request should succeed' );
done_testing();
