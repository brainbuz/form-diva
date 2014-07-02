#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Form::Diva' ) || print "Bail out!\n";
}

diag( "Testing Form::Diva $Form::Diva::VERSION, Perl $], $^X" );
