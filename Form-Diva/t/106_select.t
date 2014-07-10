#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

#use 5.020;
use experimental;
use Storable qw(dclone);

use_ok('Form::Diva');

=pod Test Select Inputs

=cut

my $select1 = Form::Diva->new(
    form_name   => 'DIVA110',
    label_class => 'testclass',
    input_class => 'form-control',
    form        => [
        {   n => 'selecttest',
            t => 'select',
            v => [qw /American English Canadian/]
        },
    ],
);

my $datalist2 = Form::Diva->new(
    form_name   => 'DIVA110A',
    label_class => 'testclass',
    input_class => 'form-control',
    form        => [
        {   name   => 'checktest',
            type   => 'datalist',
            values => [qw /American English Canadian French Irish Russian/]
        },
    ],
);

my $select3 = Form::Diva->new(
    form_name   => 'DIVA110B',
    label_class => 'testclass',
    input_class => 'form-control',
    form        => [
        {   name    => 'checktest',
            type    => 'select',
            default => 'French',
            values  => [
                qw /Argentinian American English Canadian French Irish Russian/
            ]
        },
    ],
);

my ($newform) = &Form::Diva::_expandshortcuts( $select1->{form} );

is( $newform->[0]{type}, 'select', 'check _expandshortcuts type is select' );

TODO: {
    local $TODO = 'select is completely unimplimented';

    my $input_select3_default
        = q |<SELECT name="checktest"  class="form-control">
 <option value="Argentinian" >Argentinian</option>
 <option value="American" >American</option>
 <option value="English" >English</option>
 <option value="Canadian" >Canadian</option>
 <option value="French" selected >French</option>
 <option value="Irish" >Irish</option>
 <option value="Russian" >Russian</option>
</SELECT>|;


    unlike( $select1->_select( $select1->{form}[0], undef ),
        qr/selected/,
        'select1 does not have a default, with no data nothing is selected' );
    like(
        $select1->_select( $select1->{form}[0], 'English' ),
        qr/English" selected/,
        'select1 with English as data it is now selected'
    );

    my $input2 = $datalist2->_select( $datalist2->{form}[0], 'Canadian', );
    note($input2);

    my $input3a = $select3->_select( $select3->{form}[0], undef, );
    is( $input3a, $input_select3_default, 'A full example.' );

}
done_testing();
