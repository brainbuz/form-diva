#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use 5.018;
use Storable qw(dclone);

use_ok('Form::Diva');

my $diva1 = Form::Diva->new(
    form_name   => 'DIVA1',
    label_class => 'testclass',
    input_class => 'form-control',
    form        => [
        { n => 'name', t => 'text', p => 'Your Name', l => 'Full Name' },
        { name => 'phone', type => 'tel', extra => 'required', id => 'not name' },
        {qw / n email t email l Email c form-email placeholder doormat/},        
        { name => 'our_id', type => 'number', extra => 'disabled', default => 57 },
    ],
);

my @fields = @{ $diva1->{FormMap} };

my %name_no_data  = $diva1->_field_bits( $fields[0] );
my %phone_no_data = $diva1->_field_bits( $fields[1] );
my %email_no_data = $diva1->_field_bits( $fields[2] );
my %ourid_no_data = $diva1->_field_bits( $fields[3] );
for ( keys %name_no_data ) { note($_) }

foreach my $nametest (
    [ 'label_displaytext', 'Full Name' ],
    [ 'label_class',       'class="testclass"' ],
    [ 'input_class',       'class="form-control"' ],
    [ 'placeholder',       'placeholder="Your Name"' ],
    [ 'value', 57 ],
    )
{
    my $testf = $nametest->[0];
    my $testv = $nametest->[1];
    is( $name_no_data{$testf}, $testv, "name_no_data $testf = $testv" );
}
TODO: {
local $TODO = 'Dont have type yet.';

foreach my $phonetest ( 
	[ 'type', 'tel' ], 
	[ 'extra', 'required' ], 		
    [ 'name' , 'phone'],	
    [ 'id' , 'not name'],
    [ 'label_displaytext', 'Phone'],
	) {
    my $testf = $phonetest->[0];
    my $testv = $phonetest->[1];
    is( $phone_no_data{$testf}, $testv, "phone_no_data $testf = $testv" );
}
}
TODO: {
local $TODO = 'EMAIL.';

foreach my $emailtest ( 
	[ 'type', 'email' ], 
	[ 'label_class', 'class="form-email"' ], 
	[ 'placeholder', 'placeholder="doormat"'],
	[ 'id', 'email'],
	[ 'name', 'email'],	
	) {
    my $testf = $emailtest->[0];
    my $testv = $emailtest->[1];
    is( $email_no_data{$testf}, $testv, "email_no_data $testf = $testv" );
}
}

TODO: {
local $TODO = 'OURID.';

foreach my $ouridtest ( 
	[ 'type', 'number' ], 
	[ 'extra', 'disabled'],
	) {
    my $testf = $ouridtest->[0];
    my $testv = $ouridtest->[1];
    is( $ourid_no_data{$testf}, $testv, "email_no_data $testf = $testv" );
}
}

done_testing;

#value needs data