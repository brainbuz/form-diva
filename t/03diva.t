#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use 5.018;
use Storable qw(dclone);

use_ok('Form::Diva');

my $diva1 = Form::Diva->new(
    label_class => 'testclass',
    input_class => 'form-control',
    form        => [
        { n => 'name', t => 'text', p => 'Your Name', l => 'Full Name' },
        { name => 'phone', type => 'tel', extra => 'required' },
        {qw / n email t email l Email c form-email /},
        { name => 'our_id', type => 'number', extra => 'disabled' },
        { name => 'biography', type => 'textarea' },
    ],
);

my $data1_diva1 = {
        name   => 'Maria Callas',
        phone  => '212-MU5-3767',
        email  => 'maria@yahoo.com',
        our_id => 1487,
    };

my @f1_d1 = @{ $diva1->generate( $data1_diva1 ) };

for ( @f1_d1 ) { note( "$_->{label} $_->{input}" ) }

done_testing();
