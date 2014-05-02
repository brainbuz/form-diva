package Diva::View::HTML;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    render_die => 1,
);

=head1 NAME

Diva::View::HTML - TT View for Diva

=head1 DESCRIPTION

TT View for Diva.

=head1 SEE ALSO

L<Diva>

=head1 AUTHOR

John Karr

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
