#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
#use 5.014;
use Storable qw(dclone);

use_ok('Form::Diva');

# need to test field level class over-ride in here.

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

my %name_no_data  = $diva1->_field_bits( $fields[0] );
my %name_data1    = $diva1->_field_bits( $fields[0], $data1 );
my %name_data2    = $diva1->_field_bits( $fields[0], $data2 );
my %phone_no_data = $diva1->_field_bits( $fields[1] );
my %phone_data1   = $diva1->_field_bits( $fields[1], $data1 );
my %phone_data2   = $diva1->_field_bits( $fields[1], $data2 );
my %email_no_data = $diva1->_field_bits( $fields[2] );
my %email_data1   = $diva1->_field_bits( $fields[2], $data1 );
my %email_data2   = $diva1->_field_bits( $fields[2], $data2 );
my %ourid_no_data = $diva1->_field_bits( $fields[3] );
my %ourid_data1   = $diva1->_field_bits( $fields[3], $data1 );
my %ourid_data2   = $diva1->_field_bits( $fields[3], $data2 );
my %TextArea      = $diva1->_field_bits( $fields[4] );
my %TextAreaData2 = $diva1->_field_bits( $fields[4], $data2 );

sub tester {
    my $test_results = shift;
    my $test_name    = shift;
    my $test0        = shift;
    my $test1        = shift;
    my $note1        = $test1 || qq!ZERO or NULL VALUE!;
    is( $test_results->{$test0}, $test1, "$test_name : $test0 : $note1" );
}

foreach my $nametest (
    [ 'input_class',       'class="form-control"' ],
    [ 'placeholder',       'placeholder="Your Name"' ],
    [ 'rawvalue',          '' ],
    [ 'value',             'value=""' ],
    [ 'textarea',          0 ],
    )
{
    tester( \%name_no_data, 'Name No Data', $nametest->[0], $nametest->[1] );
}

foreach my $test (
    [ 'input_class',       'class="form-control"' ],
    [ 'placeholder',       '' ],
    [ 'rawvalue',          'Baloney' ],
    [ 'value',             'value="Baloney"' ],
    )
{
    tester( \%name_data1, 'name_data1', $test->[0], $test->[1] );
}
foreach my $test (
    [ 'placeholder', '' ],
    [ 'rawvalue',    'Salami' ],
    [ 'value',       'value="Salami"' ],
    )
{
    tester( \%name_data2, 'name_data2', $test->[0], $test->[1] );
}

foreach my $phonetest (
    [ 'type',              'type="tel"' ],
    [ 'extra',             'required' ],
    [ 'name',              'name="phone"' ],
    [ 'id',                'id="not name"' ],
    )
{
    tester( \%phone_no_data, 'Phone No Data',
        $phonetest->[0], $phonetest->[1] );
}

tester( \%phone_data1, 'phone_data1', 'rawvalue', '232-432-2744' );
tester( \%phone_data2, 'phone_data2', 'rawvalue', '' );
tester( \%phone_data1, 'phone_data1', 'value',    'value="232-432-2744"' );
tester( \%phone_data2, 'phone_data2', 'value',    'value=""' );
tester( \%phone_data2, 'phone_data2', 'id',       'id="not name"' );

foreach my $emailtest (
    [ 'type',        'type="email"' ],
    [ 'placeholder', 'placeholder="doormat"' ],
    [ 'value',       'value=""' ],
    )
{
    tester( \%email_no_data, 'Email No Data',
        $emailtest->[0], $emailtest->[1] );
}

foreach my $emailtest2 (
    [ 'type',        'type="email"' ],
    [ 'placeholder', '' ],
    [ 'id',          'id="email"' ],
    [ 'name',        'name="email"' ],
    [ 'rawvalue',    'salami@yapc.org' ],
    [ 'value',       'value="salami@yapc.org"' ],
    )
{
    tester( \%email_data2, 'email_data2',
        $emailtest2->[0], $emailtest2->[1] );
}

foreach my $ouridtest (
    [ 'type',     'type="number"' ],
    [ 'extra',    'disabled' ],
    [ 'name',     'name="our_id"' ],
    [ 'rawvalue', 57 ],
    [ 'value',    'value="57"' ],
    [ 'input_class', 'class="other-class shaded-green"' ],
    )
{
    tester( \%ourid_no_data, 'OurId No Data',
        $ouridtest->[0], $ouridtest->[1] );
}
tester( \%ourid_data2, 'ourid_data2', 'rawvalue', 91 );
tester( \%ourid_data2, 'ourid_data2', 'value',    'value="91"' );
tester( \%TextArea, 'textarea', 'textarea', 1 );
tester( \%TextArea, 'textarea', 'placeholder', 
    'placeholder="Type some stuff here"' );
tester( \%TextAreaData2, 'textarea data2', 'rawvalue', 
    'I typed things in here!' );

done_testing;
