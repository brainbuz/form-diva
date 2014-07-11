#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Storable qw(dclone);

use_ok('Form::Diva');

=pod Test Select Inputs

=cut

my $select1 = Form::Diva->new(
    form_name   => 'SELECT1',
    label_class => 'testclass',
    input_class => 'form-control',
    form        => [
        {   n => 'selecttest',
            t => 'select',
            v => [qw /usa:American uk:English can:Canadian/],
        },
    ],
);

my $select2 = Form::Diva->new(
    form_name   => 'SELECT2',
    label_class => 'testclass',
    input_class => 'form-control',
    form        => [
        {   n => 'empty',
            t => 'select',
            v => [],
        },
    ],
);

my $select3 = Form::Diva->new(
    form_name   => 'SELECT3',
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

my $input_select3_default = 
 q |<SELECT name="checktest" id="checktest"  class="form-control">
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

my $empty_input_nodata = 
    qq|<SELECT name="empty" id="empty"  class="form-control">\n</SELECT>|;
is( $select2->_select( $select2->{form}[0] ) ,
    $empty_input_nodata ,
    'select2 has no values provided and returns with no option elements');
my $select2_no_data = $select2->generate ;
is( $select2_no_data->[0]{label}, 
    '<LABEL for="empty" class="testclass">Empty</LABEL>',
    'Check the label on the empty one');
# remove extra space because generate does.
$empty_input_nodata =~ s/\s//g;
my $generated_empty_input = $select2_no_data->[0]{input};
$generated_empty_input =~ s/\s//g;
is( $generated_empty_input, 
    $empty_input_nodata,
    'Generate returned input of a few tests ago, with some space removed' );

my $input3a = $select3->_select( $select3->{form}[0], undef, );
is( $input3a, $input_select3_default, 
    'A select with different labels than values.' );

my $over_ride2 = $select2->_select( 
    $select2->{form}[0], undef, [ qw / yellow orange red / ] );
like( $over_ride2, qr/red/, 
    'Empty Select with Override now has one of the new vaues' )   ;
unlike( $over_ride2, qr/selected/, 
    'Empty Select with Override has no selected because it was given undef' )   ;

my $over_ride3 = $select3->_select( 
    $select3->{form}[0], 'pear', [ qw / apple orange pear / ] );
unlike ( $over_ride3, qr/French/, 
    'Select with Override does not contain an original option value');
like( $over_ride3, qr/apple/, 
    'Select with Override does contain one of the new values' )   ;
like( $over_ride3, qr/<option value="pear" selected >/,
    'pear is selected in the Override select');

my $over_ride4 = $select3->generate( 
    { checktest  => 'banana' , pet => 'poodle' },
    { checktest => [ qw / banana grape peach plum / ] } );

like( $over_ride4->[0]{input} , qr/banana/,
    'banana is in the new list from generate');
unlike( $over_ride4->[0]{input} , qr/Canadian/, 'Canadian has been removed' );


done_testing();
