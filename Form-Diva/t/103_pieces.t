#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
#use 5.014;
use Storable qw(dclone);

use_ok('Form::Diva');

# Test some of the smaller pieces that weren't tested earlier

my $diva1 = Form::Diva->new(
    form_name   => 'DIVA1',
    label_class => 'testclass',
    input_class => 'form-control',
    form        => [
        { n => 'name', t => 'text', p => 'Your Name', l => 'Full Name' },
        {   name  => 'phone',
            type  => 'tel',
            extra => 'required',
            id    => 'not name',
        },
        {qw / n email t email l Email c form-email placeholder doormat/},
        {   name    => 'our_id',
            type    => 'number',
            extra   => 'disabled',
            default => 57,
            class => 'other-class shaded-green',
        },
        {   n => 'longtext',
            type => 'TextArea',
            placeholder => 'Type some stuff here',
        }        
    ],
);

my @fields = @{ $diva1->{FormMap} };
my $data1  = {
    name  => 'Baloney',
    phone => '232-432-2744',
};
my $data2 = {
    name   => 'Salami',
    email  => 'salami@yapc.org',
    our_id => 91,
    longtext => 'I typed things in here!',
};

note( 'testing _class_input');
is( $diva1->_class_input(), 'class="form-control"', 'bare' );
is( $diva1->_class_input( $diva1->{form}[1] ), 'class="form-control"', 
    'with field that uses default class' );
is( $diva1->_class_input( $diva1->{form}[2] ), 'class="form-email"',
    'with field that uses over-ride class' );


done_testing;
