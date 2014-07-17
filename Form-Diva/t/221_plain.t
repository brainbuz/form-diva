use strict;
use warnings;
use Test::More;
use Storable qw(dclone);

use_ok('Form::Diva');

my $diva = Form::Diva->new(
    label_class => 'testclass',
    input_class => 'form-control',
    form_name => 'diva1',
    form        => [
        { n => 'foodname', t => 'text', p => 'Your Name', l => 'Full_Name' },
        { name => 'phone', type => 'tel', extra => 'required' },
        {qw / n email t email l Email c form-email placeholder doormat/},
        { name => 'our_id', type => 'number', extra => 'disabled' },
    ],
);

my $data1 = {
    foodname   => 'spaghetti',
    our_id => 41,
    email  => 'dinner@food.food',
};

my $nodata = $diva->plain ;
my $withdata = $diva->plain( $data1 ) ;
my $skipempty = $diva->plain( $data1, 'skipempty' );

is ( $nodata->[0]{name}, 'foodname', 'checked name of 0 row');
is( $nodata->[1]{type}, 'tel', 'row 1 type');
is( $nodata->[3]{extra}, 'disabled', 'row 3 extra');

is( scalar( @$nodata), 4, 'nodata form returned 4 rows');
is( scalar( @$withdata), 4, 'withdata form returned 4 rows');
is( scalar( @$skipempty), 3, 'skipempty nodata form returned 3 rows');
is( $skipempty->[2]{value}, 41, 'skipempty last row value is 41');
is( $withdata->[2]{value}, 'dinner@food.food', 'withdata provided value for email');

is( $nodata->[0]{label}, 'Full_Name', 'nodata label is correct');
is( $withdata->[3]{label}, 'Our_id', 'withdata label was created from name');
is( $skipempty->[1]{label}, 'Email', 'skipempty field 1 is Email because a record was deliberately skipped');


done_testing();
