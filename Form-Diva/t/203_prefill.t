#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Storable qw(dclone);

use_ok('Form::Diva');

my $diva1 = Form::Diva->new(
    label_class => 'testclass',
    input_class => 'form-control',
    form_name => 'diva1',
    form        => [
        { n => 'name', t => 'text', p => 'Your Name', l => 'Full Name' },
        { name => 'phone', type => 'tel', extra => 'required', 
            comment => 'phoney phooey', default => 'say Hello' },
        {qw / n email t email l Email c form-email placeholder doormat/},
        { name => 'our_id', type => 'number', 
                extra => 'disabled', placeholder => 11 },
        {  name => 'onemore', default => 'old college try' },
    ],
);

note( 'a few example tests with some small data.');
my $data1 = {
    name   => 'spaghetti',
    email  => 'dinner@food.food',
};

# my $nodatagenerate = $diva1->generate ;
# my $nodataprefill = $diva1->prefill ;

# is_deeply( $nodataprefill, $nodatagenerate, 
#     "With no data prefill and generate return the same" );

TODO: {
    local $TODO = 'Prefill';
    my $data_prefill = $diva1->prefill( $data1 );
    
    like( $data_prefill->[0]{input}, qr/value="spaghetti"/,
        'prefilled name with value spaghetti is set' );

    like( $data_prefill->[1]{input}, qr/value="say Hello"/,
        'prefilled with no value for phone gets default' );

    like( $data_prefill->[2]{input}, qr/value="dinner\@food.food"/,
        'prefilled email with value dinner@food.food is set' );

    like( $data_prefill->[3]{input}, 
        qr/value=""/,
        'prefilled our_id with no value gets no value' );  
    like( $data_prefill->[3]{input}, 
        qr/placeholder="11"/,
        'prefilled our_id with no value gets placeholder of 11' );    

    like( $data_prefill->[4]{input}, 
        qr/value="old college try"/,
        'prefilled with no value for onemore gets default' );
}




done_testing();
