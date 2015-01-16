use utf8;
package MyApps::Schema::Result::Image;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

MyApps::Schema::Result::Image

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

=head1 TABLE: C<images>

=cut

__PACKAGE__->table("images");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 aid

  data_type: 'integer'
  is_nullable: 1

=head2 gid

  data_type: 'integer'
  is_nullable: 1

=head2 path

  data_type: 'varchar'
  is_nullable: 1
  size: 256

=head2 original_url

  data_type: 'varchar'
  is_nullable: 1
  size: 512

=head2 thumb_url

  data_type: 'varchar'
  is_nullable: 1
  size: 512

=head2 stat

  data_type: 'integer'
  default_value: 1
  is_nullable: 0

=head2 posted_at

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "aid",
  { data_type => "integer", is_nullable => 1 },
  "gid",
  { data_type => "integer", is_nullable => 1 },
  "path",
  { data_type => "varchar", is_nullable => 1, size => 256 },
  "original_url",
  { data_type => "varchar", is_nullable => 1, size => 512 },
  "thumb_url",
  { data_type => "varchar", is_nullable => 1, size => 512 },
  "stat",
  { data_type => "integer", default_value => 1, is_nullable => 0 },
  "posted_at",
  {
    data_type => "timestamp",
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


# Created by DBIx::Class::Schema::Loader v0.07035 @ 2015-01-11 20:20:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:UACcveK90ImkQN/LMWtfAQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
