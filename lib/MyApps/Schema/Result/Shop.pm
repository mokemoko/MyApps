use utf8;
package MyApps::Schema::Result::Shop;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

MyApps::Schema::Result::Shop

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<artists>

=cut

__PACKAGE__->table("shops");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 tel

  data_type: 'varchar'
  is_nullable: 1
  size: 12

=head2 flg

  data_type: 'integer'
  is_nullable: 0
  default_valu: 0

=head2 passcode

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 created_at

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "tel",
  { data_type => "varchar", is_nullable => 1, size => 12 },
  "flg",
  { data_type => "integer", is_nullable => 0, default_value => 0 },
  "passcode",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "created_at",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


