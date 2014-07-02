#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use 5.014;
use Storable qw(dclone);

use_ok('Form::Diva');

# need to test field level class over-ride in here.

my $diva1 = Form::Diva->new(
    form_name   => 'DIVA1',
    label_class => 'testclass',
    input_class => 'form-control',
    form        => [
        { n => 'fullname', t => 'text', p => 'Your Name', l => 'Full Name' },
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
        },
        {   n => 'longtext',
            type => 'TextArea',
            placeholder => 'Type some stuff here',
        }
    ],
);

my @fields = @{ $diva1->{FormMap} };
my $data1  = {
    fullname  => 'Baloney',
    phone => '232-432-2744',
};
my $data2 = {
    name   => 'Salami',
    email  => 'salami@yapc.org',
    our_id => 91,
    longtext => 'I typed things in here!',
};

my $name_no_data_tr = $diva1->_input( $fields[0], undef ) ;
# There seems like extra space in some of the qr//, this is deliberate
# to ensure that there is space between elements.
note( "Input Element for name_no_data_tr\n$name_no_data_tr" );
like( $name_no_data_tr, qr/^<INPUT type="text"/, 
    'begins with: <input type="text"');
like( $name_no_data_tr, qr/>$/, 'ends with >');
like( $name_no_data_tr, qr/value=""/, 'Empty Value: value="" ');
like( $name_no_data_tr, qr/name="fullname"/, 
    'has fieldname: name="fullname"');
like( $name_no_data_tr, qr/ placeholder="Your Name"/,
    'PlaceHolder is set: placeholder="Your Name"');
unlike( $name_no_data_tr, qr/placeholder="placeholder/, 
    'Bug Test: this should not be: placeholder="placeholder' );

my $name_data1_tr = $diva1->_input( $fields[0], $data1) ;
note( "Input Element for name_data1_tr: $name_data1_tr" );
unlike( $name_data1_tr, qr/placeholder/,
    'Input with data has no placeholder');
like( $name_data1_tr, qr/ value="Baloney"/, 'Value set: value="Baloney" ');

my $ourid_no_data_tr = $diva1->_input( $fields[3] );
note( "Input Element for Our_ID no Data $ourid_no_data_tr");
like( $ourid_no_data_tr, qr/ type="number" /, 'input type is number');
like( $ourid_no_data_tr, qr/value="57"/, 'Value defaulted: value="57"');
like( $ourid_no_data_tr, qr/disabled/, 'Extra specified disabled');

my $ourid_no_data2_tr = $diva1->_input( $fields[3], $data2 );
note( "Input Element for Our_ID Data2 $ourid_no_data2_tr");
like( $ourid_no_data2_tr, qr/value="91"/, 
    'Value is not default but actual value: value="91"');
like( $ourid_no_data2_tr, qr/form="DIVA1"/, 
    'Form is named: form="DIVA1"');

my $textarea_tr = $diva1->_input( $fields[4],  );
note( "Input Element for textarea $textarea_tr");
like( $textarea_tr, qr/^<TEXTAREA/, 'tag is TEXTAREA');
my $textarea_data2_tr = $diva1->_input( $fields[4], $data2 );
note( "Input Element for textarea with data2 $textarea_data2_tr");
like(   $textarea_data2_tr, 
        qr/>I typed things in here!<\/TEXTAREA>/, 
        'TextArea has value and closing tag');


done_testing;
