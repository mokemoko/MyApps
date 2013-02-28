use strict;
use warnings;
use Test::More;


use Catalyst::Test 'MyApps';
use MyApps::Controller::Diary;

ok( request('/diary')->is_success, 'Request should succeed' );
done_testing();
