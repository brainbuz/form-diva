#!/usr/bin/env perl
use Mojolicious::Lite;
use Form::Diva;
#use Data::GUID::Any 'guid_as_string';

# Documentation browser under "/perldoc"
plugin 'PODRenderer';
# Silence secrets warning.
app->secrets(['My very secret passphrase.']);
my $log = Mojo::Log->new;

my $diva1 = Form::Diva->new(
    form_name   => 'DIVA1',
    label_class => 'col-sm-3 control-label',
    input_class => 'form-control',
    form        => [
        { n => 'name', t => 'text', p => 'Your Name', l => 'Full Name' },
        {   name  => 'phone',
            type  => 'tel',
            extra => 'required',
            id    => 'not name',
        },
        {qw / n email t email l Email c form-email placeholder doormat/},
        {   name    => 'our_id',
            type    => 'number',
            default => 57,
            class => 'other-class shaded-green',
        },
        {   n => 'longtext',
            type => 'TextArea',
            placeholder => 'Type some stuff here',
        }        
    ],
);



get '/' => sub {
  my $c = shift;
  $c->render('index');
};

get '/form1' => sub {
  my $c = shift;
    $c->stash( form_name => $diva1->form_name) ;
    $c->stash( form1 => $diva1->generate );
  $c->render('form1');
};

post '/form1' => sub {
  my $c = shift;
    $c->stash( form_name => $diva1->form_name) ;
    my %data = ();
    my @params = $c->param ;
$log->info( "what was recieved @params")    ;
     $data{name} =  $c->req->param('name'); 
$log->info( 'The Grand ' . $c->req->param('grand') );      
    # ( $data{name}, $data{id}, $data{phone}, $data{email}) =
    # 	$c->param( 'name', 'id', 'phone', 'email');
$log->info( 'post data')    	;
foreach my $k ( keys %data) {
	$log->info( "$k : $data{$k}") ;
}
    $c->stash( form1 => $diva1->generate( \%data ) );
  $c->render('form1');
};

app->start;

=pod 

The example data section from the docs.

__DATA__

@@ index.html.ep
% layout 'default';
% title 'Welcome';
Welcome to the Mojolicious real-time web framework!

# @@ layouts/default.html.ep
# <!DOCTYPE html>
# <html>
#   <head><title><%= title %></title></head>
#   <body><%= content %>
#   <p>Layout from Controller</p></body>
# </html>
