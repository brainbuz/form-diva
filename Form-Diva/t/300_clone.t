#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Storable qw(dclone);

use_ok('Form::Diva');

my $diva1 = Form::Diva->new(
    label_class => 'testclass',
    input_class => 'form-control',
    form_name => 'diva1',
    form        => [
        { n => 'name', t => 'text', p => 'Your Name', l => 'Full Name' },
        { name => 'phone', type => 'tel', extra => 'required' },
        {qw / n email t email l Email c form-email placeholder doormat/},
        { name => 'our_id', type => 'number', extra => 'disabled' },
    ],
);

isa_ok($diva1, 'Form::Diva', 'Original object is a Form::Diva');
my $diva2 = $diva1->clone({ 
    neworder => ['our_id', 'email'] });
isa_ok($diva2, 'Form::Diva', 'New object is a Form::Diva');
is( scalar @{$diva2->{FormMap}}, 2, 'new object only has 2 rows in form');
undef $diva1 ;
note(  'deleting original obj should not affect subsequent tests');
is( $diva2->{FormMap}[1]{name}, 'email', 'last row in copy is email');
#is( $diva2->form_name, 'diva1', 'The new obj inherited the old name');

my $diva3 = $diva2->clone({ 
    neworder => ['phone', 'name'],
    form_name => 'newform',
    input_class => 'different' });
is( $diva3->{FormMap}[1]{name}, 'name', 'our next copy has name as a field');
#is( $diva3->form_name, 'newform', 'The new form has the new name');
is( $diva3->input_class, 'different', 'The new input_class is in effect');
is( $diva3->label_class, 'testclass', 'but we didnt change label_class');

done_testing();
