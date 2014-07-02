package Diva::Controller::Author;
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

# For now the diva array goes here.
# n (name) #required
# i (id) defaults to name.
# t (type) default 'text'
# e (extra) strings to be inserted into form element
# -- e is used for single element values like required and disabled
# -- it is also used for extra parameters like min and max in a range field.
# l (label) The default label is ucfirst of name, use this value instead.
# p (placeholder) # sets a placeholder that will display until input
# d (default) # sets an initial default value if no data is provided.
 my $author_fields = [
{ n => 'id', t => 'number', e => 'disabled' },
{ n => 'first_name', t => 'text', e => 'required', l => 'First Name' },
{ n => 'last_name', t => 'text', e => 'required', l => 'Last Name' },
];




sub show :Local {
    # Retrieve the usual Perl OO '$self' for this object. $c is the Catalyst
    # 'Context' that's used to 'glue together' the various components
    # that make up the application
    my ($self, $c) = @_;
 
    # Retrieve all of the book records as book model objects and store
    # in the stash where they can be accessed by the TT template
    #$c->stash(books => [$c->model('DB::Book')->all]);
 
    # Set the TT template to use.  You will almost always want to do this
    # in your action methods (action methods respond to user input in
    # your controllers).
    $c->stash(template => 'author.tt2');
    $c->stash( author => $c->model('DBI')->Author(7) );
}

__PACKAGE__->meta->make_immutable;

1;
