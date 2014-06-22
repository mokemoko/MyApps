package MyApps::Model::Twillio;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'MyApps::Schema',
    
    connect_info => {
        dsn => 'dbi:mysql:twillio',
        user => 'root',
        password => '',
    }
);

=head1 NAME

MyApps::Model::Twillio - Catalyst DBIC Schema Model

=head1 SYNOPSIS

See L<MyApps>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<MyApps::Schema>

=head1 GENERATED BY

Catalyst::Helper::Model::DBIC::Schema - 0.6

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
