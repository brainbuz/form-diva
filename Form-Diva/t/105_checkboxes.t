#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
#use 5.014;
use Storable qw(dclone);

use_ok('Form::Diva');

=pod Test radio buttons and checkboxes

=cut

my $radio1 = Form::Diva->new(
    form_name   => 'DIVA110',
    label_class => 'testclass',
    input_class => 'form-control',
    form        => [
        { n => 'radiotest', t => 'radio', 
        v => [ qw /American English Canadian/ ] },
    ],
);

my $check1 = Form::Diva->new(
    form_name   => 'DIVA110A',
    label_class => 'testclass',
    input_class => 'form-control',
    form        => [
        { name => 'checktest', type => 'checkbox', 
        values => [ qw /French Irish Russian/ ] },
    ],
);

my $labels1 = Form::Diva->new(
    form_name   => 'DIVA110B',
    label_class => 'testclass',
    input_class => 'form-control',
    form        => [
        { name => 'withlabels', type => 'radio', default => 1,
        values => [ 
        	"1:Peruvian Music", 
        	"2:Argentinian Dance",
        	"3:Cuban" ] },
    ],
);

my $newform = &Form::Diva::_expandshortcuts( $radio1->{form} );

my $testradio1values = $newform->[0]{values};
is( $newform->[0]{type}, 'radio', 
		'check _expandshortcuts that r expanded to radio');
is( $testradio1values->[2], 'Canadian', 'Test _expandshortcuts for values' );

my $radio_nodata_expected =<< 'RNDX' ;
<input type="radio" class="form-control" name="radiotest" value="American">American<br>
<input type="radio" class="form-control" name="radiotest" value="English">English<br>
<input type="radio" class="form-control" name="radiotest" value="Canadian">Canadian<br>
RNDX

my $radio1_data_expected =<< 'RDX' ;
<input type="radio" class="form-control" name="radiotest" value="American">American<br>
<input type="radio" class="form-control" name="radiotest" value="English">English<br>
<input type="radio" class="form-control" name="radiotest" value="Canadian" checked>Canadian<br>
RDX

my $check_nodata_expected =<< 'CNDX' ;
<input type="checkbox" class="form-control" name="checktest" value="French">French<br>
<input type="checkbox" class="form-control" name="checktest" value="Irish">Irish<br>
<input type="checkbox" class="form-control" name="checktest" value="Russian">Russian<br>
CNDX

my $labels1_nodata_expected =<< 'NDDX';
<input type="radio" class="form-control" name="withlabels" value="1" checked>Peruvian Music<br>
<input type="radio" class="form-control" name="withlabels" value="2">Argentinian Dance<br>
<input type="radio" class="form-control" name="withlabels" value="3">Cuban<br>
NDDX

my $labels1_data_expected =<< 'NDDX1';
<input type="radio" class="form-control" name="withlabels" value="1">Peruvian Music<br>
<input type="radio" class="form-control" name="withlabels" value="2" checked>Argentinian Dance<br>
<input type="radio" class="form-control" name="withlabels" value="3">Cuban<br>
NDDX1

my @radio1_nodata = @{ $radio1->generate };
is( $radio1_nodata[0]->{input}, $radio_nodata_expected, 'generated as 3 radio buttons.');
my @radio1_data = @{ $radio1->generate( { radiotest => 'Canadian' })} ;
is( $radio1_data[0]->{input}, $radio1_data_expected, 'Set Radio1 with Canadian Checked');
my @check1_nodata = @{ $check1->generate };
is( $check1_nodata[0]->{input}, $check_nodata_expected, 'generated as 3 checkboxes.');
my @labels1_nodata = @{ $labels1->generate} ;
is( $labels1_nodata[0]->{input}, $labels1_nodata_expected , 
	'Default checked is Peruvian Music');
my @labels1_data = @{ $labels1->generate( { withlabels => 2 })} ;
is( $labels1_data[0]->{input}, $labels1_data_expected , 
    'With Data check Argentinian Dance instead.');

my $classoverride1 = Form::Diva->new(
    form_name   => 'override',
    label_class => 'testclass',
    input_class => 'form-control',
    form        => [
        { n => 'radiotest', t => 'radio', c => 'not-default', extra =>'disabled',
        v => [ qw /American English Canadian/ ] },
    ],
);

like( $labels1_nodata[0]->{input}, qr/class="form-control"/ ,
		"The default class is being used." );
my @classoverridden = @{$classoverride1->generate};
like( $classoverridden[0]->{input}, qr/class="not-default"/ ,
		"The default class has been overridden." );
like( $classoverridden[0]->{input}, qr/disabled/ ,
		"Check the extra field, we set value to disabled." );

done_testing();
