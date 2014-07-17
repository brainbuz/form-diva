# id is calculated in multiple places, this test makes sure it is
# done as documented and the same.

use strict;
use warnings;
use Test::More;
use Storable qw(dclone);
use Data::Printer;

use_ok('Form::Diva');

my $diva1 = Form::Diva->new(
    label_class => 'testclass',
    input_class => 'form-control',
    form_name => 'diva1',
    form        => [
        { n => 'name', t => 'text', p => 'Your Name', l => 'Full Name' },
        { name => 'phone', type => 'tel', extra => 'required' },
        {qw / n email t email l Email c form-email id eml/},
        { name => 'our_id', type => 'number', extra => 'disabled' },
    ],    hidden =>
        [ { n => 'secret' }, 
        { n => 'hush', default => 'very secret' },
        { n => 'mystery', id => 'mystery_site_url', 
          extra => 'custom="bizarre"', type => "url"} ],
);

my $id_phone = 'formdiva_phone';
my $id_email = 'eml';
my $id_secret = 'formdiva_secret';
my $id_mystery = 'mystery_site_url';

my $generated = $diva1->generate ;
my $hidden    = $diva1->hidden;
my $plain     = $diva1->plain;

like( $generated->[1]{input}, qr/id="$id_phone"/, 
	"generate returned input with correct id for phone $id_phone.");
like( $generated->[2]{input}, qr/id="$id_email"/, 
	"generate returned input with correct id for email $id_email.");

is( $plain->[1]{id}, $id_phone, 
	"plain returned data with correct id for phone $id_phone.");
is( $plain->[2]{id}, $id_email, 
	"plain returned data with correct id for email $id_email.");

like( $hidden, qr/id="$id_secret"/, 
	"hidden returned correct id for secret $id_secret.");
like( $hidden, qr/id="$id_mystery"/, 
	"hidden returned correct id for mystery $id_mystery.");

done_testing;