#!/usr/bin/env perl
use strict;
use warnings;
use Test::More 1.00;
#use 5.014;
use Storable qw(dclone);
use Test::Exception 0.32;
use Data::Printer;
use Data::Dump;

use_ok('Form::Diva');

my $diva1 = Form::Diva->new(
    label_class => 'testclass',
    input_class => 'form-control',
    form        => [
        { n => 'name', t => 'text', p => 'Your Name', l => 'Full Name' },
        { name => 'phone', type => 'tel', extra => 'required', id => 'phonefield' },
        {qw / n email t email l Email c form-email placeholder doormat/},
        { name => 'our_id', type => 'number', extra => 'disabled' },
    ],
);

my $diva2 = Form::Diva->new(
    label_class => 'testclass',
    input_class => 'form-control',
    form        => [
        { n => 'something' },
    ],
);

dies_ok(
    sub { my $baddiva = Form::Diva->new(
    label_class => 'testclass',
    input_class => 'form-control',
    form        => [{qw /t email l Email /}, ],
    ) }, 'Dies: Not providing a Field Name is Fatal' );

dies_ok(
    sub { my $baddiva = Form::Diva->new(
    input_class => 'form-control',
    form        => [{qw /t email n Email /}, ],
    ) }, 'Dies: Not providing label_class is fatal' );

dies_ok(
    sub { my $baddiva = Form::Diva->new(
    label_class => 'form-control',
    form        => [{qw /t email n Email /}, ],
    ) }, 'Dies: Not providing input_class is fatal' );

my ($newform) = &Form::Diva::_expandshortcuts( $diva1->{form} );
is( $newform->[0]{label}, 'Full Name', 'record 0 label is Full Name' );
is( $newform->[0]{p},     undef,       'record 0 p is undef' );
is( $newform->[0]{placeholder},
    'Your Name', 'value from p got moved to placeholder' );
is( $newform->[2]{placeholder},
    'doormat', 'placeholder set for the email field too' );
is( $newform->[3]{name}, 'our_id', 'last record in test is named our_id' );
is( $newform->[3]{extra},
    'disabled', 'last record extra field is: disabled' );

my $form2 = $diva2->{form};
is( $form2->[0]{name}, 'something', 
    'Second form has a name: something');
is( $form2->[0]{type}, 'text', 
    'Second form: field type defaulted to text');



done_testing();
