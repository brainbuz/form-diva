#!/usr/bin/env perl
use strict;
use warnings; 
use Test::More;
use 5.014;
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
#for ( keys %name_no_data ) { note($_) }

sub tester {
    my $test_results = shift;
    my $test_name    = shift ;
    my $test0        = shift ;
    my $test1        = shift ;
    my $note1 = $test1 || 'undef' ;
    is( $test_results->{$test0}, $test1, "$test_name : $test0 : $note1" );
}

foreach my $nametest (
    [ 'label_displaytext', 'Full Name' ],
    [ 'label_class',       'class="testclass"' ],
    [ 'input_class',       'class="form-control"' ],
    [ 'placeholder',       'placeholder="Your Name"' ],
    [ 'value', undef ],
    )
{
    tester( \%name_no_data, 'Name No Data', 
            $nametest->[0], $nametest->[1] );
        }

# TODO: {
# local $TODO = 'Dont have type yet.';

foreach my $phonetest ( 
	[ 'type', 'tel' ], 
	[ 'extra', 'required' ], 		
    [ 'name' , 'phone'],	
    [ 'id' , 'not name'],
    [ 'label_displaytext', 'Phone'],
	) {
    tester( \%phone_no_data, 'Phone No Data', 
            $phonetest->[0], $phonetest->[1] );
        }

foreach my $emailtest ( 
	[ 'type', 'email' ], 
	[ 'label_class', 'class="form-email"' ], 
	[ 'placeholder', 'placeholder="doormat"'],
	[ 'id', 'email'],
	[ 'name', 'email'],	
	) 
	{
    tester( \%email_no_data, 'Email No Data', 
            $emailtest->[0], $emailtest->[1] );
        }
 
foreach my $ouridtest ( 
	[ 'type', 'number' ], 
	[ 'extra', 'disabled'],
	[ 'name', 'our_id'],
	[ 'value' , 57 ],  
	)
	{
    tester( \%ourid_no_data, 'OurId No Data', 
            $ouridtest->[0], $ouridtest->[1] );
        }
        
done_testing;

#value needs data