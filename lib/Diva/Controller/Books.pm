package Diva::Controller::Books;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=encoding utf-8
=head2 list
 
Fetch all book objects and pass to books/list.tt2 in stash to be displayed
 
=cut
 
sub list :Local {
    # Retrieve the usual Perl OO '$self' for this object. $c is the Catalyst
    # 'Context' that's used to 'glue together' the various components
    # that make up the application
    my ($self, $c) = @_;
 
    # Retrieve all of the book records as book model objects and store
    # in the stash where they can be accessed by the TT template
    $c->stash(books => [$c->model('DB::Book')->all]);
 
    # Set the TT template to use.  You will almost always want to do this
    # in your action methods (action methods respond to user input in
    # your controllers).
    $c->stash(template => 'books/list.tt2');
}

__PACKAGE__->meta->make_immutable;

1;
