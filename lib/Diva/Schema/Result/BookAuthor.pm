use utf8;
package Diva::Schema::Result::BookAuthor;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Diva::Schema::Result::BookAuthor

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

=head1 TABLE: C<book_author>

=cut

__PACKAGE__->table("book_author");

=head1 ACCESSORS

=head2 book_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 author_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "book_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "author_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</book_id>

=item * L</author_id>

=back

=cut

__PACKAGE__->set_primary_key("book_id", "author_id");

=head1 RELATIONS

=head2 author

Type: belongs_to

Related object: L<Diva::Schema::Result::Author>

=cut

__PACKAGE__->belongs_to(
  "author",
  "Diva::Schema::Result::Author",
  { id => "author_id" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 book

Type: belongs_to

Related object: L<Diva::Schema::Result::Book>

=cut

__PACKAGE__->belongs_to(
  "book",
  "Diva::Schema::Result::Book",
  { id => "book_id" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-04-29 11:14:27
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:QPSUh+A7ZBPXuAwMcvQAUA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
