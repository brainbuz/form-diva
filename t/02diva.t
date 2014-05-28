#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use 5.018;
use Storable qw(dclone);

use_ok('Form::Diva');

=pod Test radio buttons and checkboxes

=cut

my $radio1 = Form::Diva->new(
    label_class => 'testclass',
    input_class => 'form-control',
    form        => [
        { n => 'radiotest', t => 'radio', 
        v => [ qw /American English Canadian/ ] },
    ],
);

my $check1 = Form::Diva->new(
    label_class => 'testclass',
    input_class => 'form-control',
    form        => [
        { name => 'checktest', type => 'checkbox', 
        values => [ qw /French Irish Russian/ ] },
    ],
);

my $labels1 = Form::Diva->new(
    label_class => 'testclass',
    input_class => 'form-control',
    form        => [
        { name => 'withlabels', type => 'radio', 
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
<input type="radio" name="radiotest" value="American">American<br>
<input type="radio" name="radiotest" value="English">English<br>
<input type="radio" name="radiotest" value="Canadian">Canadian<br>
RNDX
my $check_nodata_expected =<< 'CNDX' ;
<input type="checkbox" name="checktest" value="French">French<br>
<input type="checkbox" name="checktest" value="Irish">Irish<br>
<input type="checkbox" name="checktest" value="Russian">Russian<br>
CNDX

my $labels1_nodata_expected =<< 'NDDX';
<input type="radio" name="withlabels" value="1">Peruvian Music<br>
<input type="radio" name="withlabels" value="2">Argentinian Dance<br>
<input type="radio" name="withlabels" value="3">Cuban<br>
NDDX

my @radio1_nodata = @{ $radio1->generate };
is( $radio1_nodata[0]->{input}, $radio_nodata_expected, 'generated as 3 radio buttons.');
my @check1_nodata = @{ $check1->generate };
is( $check1_nodata[0]->{input}, $check_nodata_expected, 'generated as 3 checkboxes.');
my @labels1_nodata = @{ $labels1->generate} ;
is( $labels1_nodata[0]->{input}, $labels1_nodata_expected , 
	'generated radio with labels and values.');


=pod
my $diva1 = Form::Diva->new(
    label_class => 'testclass',
    input_class => 'form-control',
    form        => [
        { n => 'name', t => 'text', p => 'Your Name', l => 'Full Name' },
        { name => 'phone', type => 'tel', extra => 'required' },
        {qw / n email t email l Email /},
        { name => 'our_id', type => 'number', extra => 'disabled' },
    ],
);

my $newform = &Form::Diva::_expandshortcuts( $diva1->{form} );
is( $newform->[0]{p},     undef,       'record 0 p is undef' );
is( $newform->[0]{label}, 'Full Name', 'record 0 label is Full Name' );
is( $newform->[0]{placeholder},
    'Your Name', 'value from p got moved to placeholder' );
is( $newform->[3]{name}, 'our_id', 'last record in test is named our_id' );
is( $newform->[3]{extra},
    'disabled', 'last record extra field has value disabled' );

#my $rehashed = &Form::Diva::_map_form_as_hash( $newform );
#my @rhkeys = keys %{$rehashed};
#note ( "@rhkeys" );

my $data1 = {
    name   => 'spaghetti',
    our_id => 1,
    email  => 'dinner@food.food',
};

# my $test1 = $diva1->generate( $data1 );
# for( @{$test1} ) { note( $_->{label}, "\n", $_->{input} ); }
# my $test2 = $diva1->generate(  );
# for( @{$test2} ) { note( $_->{label}, "\n", $_->{input} ); }

my @html_types = (
    {qw / n color t color l Colour /},
    {qw / n date   t date   l Date /},
    { n => 'datetime', t => 'datetime', l => 'Date Time' },
    {   n => 'datetime-local',
        t => 'datetime-local',
        l => 'Localized Date Time'
    	},
    {qw / n email  t email  l Email /},
    {qw / n month  t month  l Month /},
    {qw / n number t number l Number /},
    {qw / n yourpassword t password l YourSecretPassword /},
    {qw / n range  t range  l Range /},
    {qw / n search t search l Search/},
    {qw / n tel    t tel    l Telephone /},
    {qw / n url    t url    l URL /},
    {qw / n week   t week   l Week /},
);

note('Testing all of the html form field types');
my $diva_html_types = Form::Diva->new(
    label_class => 'testclass',
    input_class => 'form-control',
    form        => dclone( \@html_types ),
);
my @html_field_types_form = @{ $diva_html_types->generate() };
for ( my $i = 0; $i < scalar(@html_types); $i++ ) {
    my %data = %{ $html_types[$i] };
    my %res  = %{ $html_field_types_form[$i] };
    note("");
    is( $res{label},
        qq!<LABEL for="$data{n}" class="testclass">$data{l}</LABEL>!,
        "Testing Field Type: $data{t} Label Validated"
    );

    #note( $res{input} ) ;
    is( $res{input},
        qq!<INPUT TYPE="$data{t}" name="$data{n}" >!,
        "Testing Field Type: $data{t}. Input Field validated"
    );

    #last;
}

=cut

done_testing();
