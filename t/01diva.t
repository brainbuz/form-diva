#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use 5.018;

use_ok( 'Form::Diva' );

my $diva = Form::Diva->new( 
label_class => '',
input_class => 'form-control',
form        => [ 
    { n => 'name', t => 'text', p => 'Your Name', l => 'Full Name' },
    { name => 'phone', type => 'tel', extra => 'required' },
    { qw / n email t email l Email / },
    { name => 'our_id', type => 'number', extra => 'disabled' }, 
    ], );

my $newform = &Form::Diva::_expandshortcuts( $diva->{form} );
is( $newform->[0]{p}, undef, 'record 0 p is undef' );
is( $newform->[0]{label}, 'Full Name', 'record 0 label is Full Name' );
is( $newform->[0]{placeholder}, 'Your Name', 'value from p got moved to placeholder' );
is( $newform->[3]{name}, 'our_id', 'last record in test is named our_id' );
is( $newform->[3]{extra}, 'disabled', 'last record extra field has value disabled' );

done_testing();
