#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use 5.018;

use_ok( 'Form::Diva' );

my $diva = Form::Diva->new( 
label_class => 'testclass',
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

#my $rehashed = &Form::Diva::_map_form_as_hash( $newform );
#my @rhkeys = keys %{$rehashed};
#note ( "@rhkeys" );

my $data1 = {
        name => 'spaghetti', 
        our_id => 1,
        email => 'dinner@food.food', };

my $test1 = $diva->generate( $data1 );
for( @{$test1} ) { note( $_->{label}, "\n", $_->{input} ); } 
my $test2 = $diva->generate(  );
for( @{$test2} ) { note( $_->{label}, "\n", $_->{input} ); } 

done_testing();
