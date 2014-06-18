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
        { name => 'phone', type => 'tel', extra => 'required' },
        {qw / n email t email l Email c form-email placeholder doormat/},
        { name => 'our_id', type => 'number', extra => 'disabled' },
    ],
);

my @fields = @{$diva1->{ FormMap }} ;

my %name_no_data = $diva1->_field_bits( $fields[0] );
for ( keys %name_no_data ) { note( $_ )}
is( $name_no_data{label_tag}, 'Full Name', 
	"name_no_data label_tag $name_no_data{label_tag}" );
is( $name_no_data{label_class}, 'class="testclass"', 
	"name_no_data label_class $name_no_data{label_class}" );
is( $name_no_data{input_class}, 'class="form-control"', 
	"name_no_data input_class $name_no_data{input_class}" );
ok(1);
done_testing;