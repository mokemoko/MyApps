use utf8;
package MyApps::Schema::Result::Mecab;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

MyApps::Schema::Result::Mecab

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

=head1 TABLE: C<mecab>

=cut

__PACKAGE__->table("mecab");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 word

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 num

  data_type: 'integer'
  is_nullable: 1

=head2 domain

  data_type: 'varchar'
  is_nullable: 0
  size: 256

=head2 posted_at

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "word",
  { data_type => "varchar", is_nullable => 0, size => 32 },
  "num",
  { data_type => "integer", is_nullable => 1 },
  "domain",
  { data_type => "varchar", is_nullable => 0, size => 256 },
  "posted_at",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-02-28 23:36:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:HBXUa8pkKeyT9uxWA/LBvw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
