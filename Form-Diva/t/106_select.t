#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
#use 5.014;
use Storable qw(dclone);

use_ok('Form::Diva');

=pod Test Select Inputs

=cut

my $select1 = Form::Diva->new(
    form_name   => 'DIVA110',
    label_class => 'testclass',
    input_class => 'form-control',
    form        => [
        { n => 'selecttest', t => 'select', 
        v => [ qw /American English Canadian/ ] },
    ],
);

my $select2 = Form::Diva->new(
    form_name   => 'DIVA110A',
    label_class => 'testclass',
    input_class => 'form-control',
    form        => [
        { name => 'checktest', type => 'select', 
        values => [ qw /American English Canadian French Irish Russian/ ] },
    ],
);

my $select3 = Form::Diva->new(
    form_name   => 'DIVA110B',
    label_class => 'testclass',
    input_class => 'form-control',
    form        => [ 
           { name => 'checktest', type => 'select', default => 'French',
        values => [ qw /Argentinian American English Canadian French Irish Russian/ ] },

    ],
);

my ($newform) = &Form::Diva::_expandshortcuts( $select1->{form} );

my $testselect1values = $newform->[0]{values};
is( $newform->[0]{type}, 'select', 
		'check _expandshortcuts type is select');
is( $testselect1values->[2], 'Canadian', 'Test _expandshortcuts for values' );

TODO: {
local $TODO = 'select is completely unimplimented';



my $input = $select1->_select(
                $select1->{form}[0],
                $select1->_class_input($select1->{form}[0]),
                undef,
            );
note( $input );


my $select_nodata_expected =<< 'RNDX' ;
<input type="select" class="form-control" name="selecttest" value="American">American<br>
<input type="select" class="form-control" name="selecttest" value="English">English<br>
<input type="select" class="form-control" name="selecttest" value="Canadian">Canadian<br>
RNDX

my $select1_data_expected =<< 'RDX' ;
<input type="select" class="form-control" name="selecttest" value="American">American<br>
<input type="select" class="form-control" name="selecttest" value="English">English<br>
<input type="select" class="form-control" name="selecttest" value="Canadian" checked>Canadian<br>
RDX

my $check_nodata_expected =<< 'CNDX' ;
<input type="checkbox" class="form-control" name="checktest" value="French">French<br>
<input type="checkbox" class="form-control" name="checktest" value="Irish">Irish<br>
<input type="checkbox" class="form-control" name="checktest" value="Russian">Russian<br>
CNDX

my $labels1_nodata_expected =<< 'NDDX';
<input type="select" class="form-control" name="withlabels" value="1" checked>Peruvian Music<br>
<input type="select" class="form-control" name="withlabels" value="2">Argentinian Dance<br>
<input type="select" class="form-control" name="withlabels" value="3">Cuban<br>
NDDX

my $labels1_data_expected =<< 'NDDX1';
<input type="select" class="form-control" name="withlabels" value="1">Peruvian Music<br>
<input type="select" class="form-control" name="withlabels" value="2" checked>Argentinian Dance<br>
<input type="select" class="form-control" name="withlabels" value="3">Cuban<br>
NDDX1

# my @select1_nodata = @{ $select1->generate };
# note( $select1_nodata[0]->{input} ) ;

# is( $select1_nodata[0]->{input}, $select_nodata_expected, 'generated as 3 select buttons.');

# my @select1_data = @{ $select1->generate( { selecttest => 'Canadian' })} ;
# is( $select1_data[0]->{input}, $select1_data_expected, 'Set select1 with Canadian Checked');
# my @check1_nodata = @{ $select1->generate };
# is( $check1_nodata[0]->{input}, $check_nodata_expected, 'generated as 3 checkboxes.');
# my @labels1_nodata = @{ $select1->generate} ;
# is( $labels1_nodata[0]->{input}, $labels1_nodata_expected , 
# 	'Default checked is Peruvian Music');
# my @labels1_data = @{ $select1->generate( { withlabels => 2 })} ;
# is( $labels1_data[0]->{input}, $labels1_data_expected , 
#     'With Data check Argentinian Dance instead.');

my $classoverride1 = Form::Diva->new(
    form_name   => 'override',
    label_class => 'testclass',
    input_class => 'form-control',
    form        => [
        { n => 'selecttest', t => 'select', c => 'not-default', extra =>'disabled',
        v => [ qw /American English Canadian/ ] },
    ],
);

# like( $labels1_nodata[0]->{input}, qr/class="form-control"/ ,
# 		"The default class is being used." );
# my @classoverridden = @{$classoverride1->generate};
# like( $classoverridden[0]->{input}, qr/class="not-default"/ ,
# 		"The default class has been overridden." );
# like( $classoverridden[0]->{input}, qr/disabled/ ,
# 		"Check the extra field, we set value to disabled." );

}

done_testing();
