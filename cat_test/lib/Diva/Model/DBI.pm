package Diva::Model::DBI;

use strict;
use warnings;
use parent 'Catalyst::Model::DBI';

__PACKAGE__->config(
  dsn           => 'dbi:SQLite:myapp.db',
  user          => 'on_connect_do=PRAGMA foreign_keys = ON',
  password      => '',
  options       => {},
);



my $author_query = q/select * from author where id = ?/;
sub Author {
    my $self = shift ;
    my $id = shift ;
    return $self->dbh->selectrow_hashref( $author_query, {}, $id );
}


=head1 NAME

Diva::Model::DBI - DBI Model Class

=head1 SYNOPSIS

See L<Diva>

=head1 DESCRIPTION

DBI Model Class.

=head1 AUTHOR

John Karr

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
