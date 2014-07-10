#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

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
            v => [qw /usa:American uk:English can:Canadian/]
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

my $input_select3_default = q |<SELECT name="checktest"  class="form-control">
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
my $uk_selected = $select1->_select( $select1->{form}[0], 'uk' );
like(
    $uk_selected,
    qr/uk" selected/,
    'select1 with uk as data English is now selected'
);
like(
    $uk_selected,
    qr/usa" >American/,
    'select1 with uk as data "usa">American has tag and not selected'
);

my $input3a = $select3->_select( $select3->{form}[0], undef, );
is( $input3a, $input_select3_default, 'A full example.' );

done_testing();
