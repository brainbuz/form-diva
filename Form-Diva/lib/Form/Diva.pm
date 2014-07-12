use strict;
use warnings;
no warnings 'uninitialized';

package Form::Diva;

# ABSTRACT: Generate HTML5 form label and input fields

use Storable qw(dclone);

# The _option_id sub needs access to a variable for hashing the ids
# in use, even though it is initialized at the beginning of generate,
# it needs to both exist outside of the generate subroutines scope
# and before before the _option_id sub is declared.
my %id_uq = ( );
sub _clear_id_uq { %id_uq = ( ) }

sub new {
    my $class = shift;
    my $self  = {@_};
    bless $self, $class;
    $self->{class} = $class;
    unless ( $self->{input_class} ) { die 'input_class is required.' }
    unless ( $self->{label_class} ) { die 'label_class is required.' }
    ( $self->{FormMap}, $self->{FormHash} )
        = &_expandshortcuts( $self->{form} );
    return $self;
}

sub clone {
    my $self  = shift;
    my $args  = shift;
    my $new   = {};
    my $class = 'Form::Diva';
    $new->{FormHash}    = dclone $self->{FormHash};
    $new->{input_class} = $args->{input_class} || $self->{input_class};
    $new->{label_class} = $args->{label_class} || $self->{label_class};
    $new->{form_name}   = $args->{form_name} || $self->{form_name};
    if ( $args->{neworder} ) {
        my @reordered = map { $new->{FormHash}->{$_} } @{ $args->{neworder} };
        $new->{FormMap} = \@reordered;
    }
    else { $new->{FormMap} = dclone $self->{FormMap}; }
    bless $new, $class;
    return $new;
}

# so far diva hasn't needed the form name
# to use form='id of form' in the tags we would need the id not the name
# sub form_name {
#     my $self = shift ;
#     return $self->{form_name};
# }

sub input_class {
    my $self = shift;
    return $self->{input_class};
}

sub label_class {
    my $self = shift;
    return $self->{label_class};
}

sub _option_id {
    my $self  = shift;
    my $id    = shift;
    my $value = shift;
    my $idv = $id . '_' . lc($value) ;
    $idv =~ s/\s+/_/g;
    while ( defined $id_uq{$idv} ) {
        $id_uq{$idv}++;
        $idv = $idv . $id_uq{$idv};
    }
    $id_uq{$idv} = 1;
    return "id=\"$idv\"" ;
}

# specification calls for single letter shortcuts on all fields
# these all need to expand to the long form.
sub _expandshortcuts {
    my %DivaShortMap = (
        qw /
            n name t type i id e extra x extra l label p placeholder
            d default v values c class /
    );
    my %DivaLongMap = map { $DivaShortMap{$_}, $_ } keys(%DivaShortMap);
    my $FormHash    = {};
    my $FormMap     = shift;
    foreach my $formfield ( @{$FormMap} ) {
        foreach my $tag ( keys %{$formfield} ) {
            if ( $DivaShortMap{$tag} ) {
                $formfield->{ $DivaShortMap{$tag} }
                    = delete $formfield->{$tag};
            }
        }
        unless ( $formfield->{type} ) { $formfield->{type} = 'text' }
        unless ( $formfield->{name} ) { die "fields must have names" }
# needs test
        unless ( $formfield->{id} ) { $formfield->{id} = $formfield->{name };}        
        $FormHash->{ $formfield->{name} } = $formfield;
    }
    return ( $FormMap, $FormHash );
}

# given a field returns either the default field class="string"
# or the field specific one
sub _class_input {
    my $self   = shift;
    my $field  = shift;
    my $fclass = $field->{class} || '';
    if   ($fclass) { return qq!class="$fclass"! }
    else           { return qq!class="$self->{input_class}"! }
}

sub _field_bits {
    my $self      = shift;
    my $field_ref = shift;
    my $data      = shift;
    my %in        = %{$field_ref};
    my %out       = ();
    my $fname     = $in{name};
    $out{extra} = $in{extra};    # extra is taken literally
    $out{input_class} = $self->_class_input($field_ref);
    $out{name}        = qq!name="$in{name}"!;
    $out{id}          = $in{id} ? qq!id="$in{id}"! : qq!id="$in{name}"!;

    if ( lc( $in{type} ) eq 'textarea' ) {
        $out{type}     = 'textarea';
        $out{textarea} = 1;
    }
    else {
        $out{type}     = qq!type="$in{type}"!;
        $out{textarea} = 0;
    }
    if ($data) {
        $out{placeholder} = '';
        $out{rawvalue} = $data->{$fname} || '';
    }
    else {
        if ( $in{placeholder} ) {
            $out{placeholder} = qq!placeholder="$in{placeholder}"!;
        }
        else { $out{placeholder} = '' }
        if   ( $in{default} ) { $out{rawvalue} = $in{default}; }
        else                  { $out{rawvalue} = '' }
    }
    $out{value} = qq!value="$out{rawvalue}"!;
    return %out;
}

sub _label {
    my $self        = shift;
    my $field       = shift;
    my $fname       = $field->{name};
    my $label_class = $self->{label_class};
    my $label_tag   = $field->{label} || ucfirst($fname);
    return qq|<LABEL for="$fname" class="$label_class">|
        . qq|$label_tag</LABEL>|;
}

sub _input {
    my $self  = shift;
    my $field = shift;
    my $data  = shift;
    my %B     = $self->_field_bits( $field, $data );
    my $input = '';
    if ( $B{textarea} ) {
        $input = qq|<TEXTAREA $B{name} $B{id}
        $B{input_class} $B{placeholder} $B{extra} >$B{rawvalue}</TEXTAREA>|;
    }
    else {
        $input .= qq|<INPUT $B{type} $B{name} $B{id}
        $B{input_class} $B{placeholder} $B{extra} $B{value} >|;
    }
    $input =~ s/\s+/ /g;     # remove extra whitespace.
    $input =~ s/\s+>/>/g;    # cleanup space before closing >
    return $input;
}

sub _option_input {          # field, input_class, data;
    my $self           = shift;
    my $field          = shift;    # field definition from FormMap or FormHash
    my $data           = shift;    # scalar data for this form field
    my $replace_fields = shift;    # valuelist to use instead of default
    my $output         = '';
    my $input_class = $self->_class_input($field);
    my $extra       = $field->{extra} || "";
    #my $id          = $field->{id} ? $field->{id} : $field->{name};
    my $default     = $field->{default}
        ? do {
        if   ($data) {undef}
        else         { $field->{default} }
        }
        : undef;
    my @values
        = $replace_fields
        ? @{$replace_fields}
        : @{ $field->{values} };
    if ( $field->{type} eq 'select' ) {
        $output
            = qq|<SELECT name="$field->{name}" id="$field->{id}" $extra $input_class>\n|;
        foreach my $val (@values) {
            my ( $value, $v_lab ) = ( split( /\:/, $val ), $val );
            my $idf = "id=\"$field->{id}" . '_' . "$value\"";
            $idf =~ s/\s+/_/g;
            my $selected = '';
            if    ( $data eq $value )    { $selected = 'selected ' }
            elsif ( $default eq $value ) { $selected = 'selected ' }
            $output
                .= qq| <option value="$value" $idf $selected>$v_lab</option>\n|;
        }
        $output .= '</SELECT>';
    }
    else {
        foreach my $val (@values) {
            my ( $value, $v_lab ) = ( split( /\:/, $val ), $val );
            my $checked = '';
            if    ( $data eq $value )    { $checked = 'checked ' }
            elsif ( $default eq $value ) { $checked = 'checked ' }
            my $idf = "id=\"$field->{id}" . '_' . "$value\"";
            $idf =~ s/\s+/_/g;
            $output
                .= qq!<input type="$field->{type}" $input_class $extra name="$field->{name}" $idf value="$value" $checked>$v_lab<br>\n!;
        }
    }
    return $output;
}

sub generate {
    my $self    = shift;
    my $data    = shift;
    my $overide = shift;
    unless ( keys %{$data} ) { $data = undef }
    my @generated = ();
    $self->_clear_id_uq ;    # needs to be empty when form generation starts.
    foreach my $field ( @{ $self->{FormMap} } ) {
        my $input = undef;
        if (   $field->{type} eq 'radio'
            || $field->{type} eq 'checkbox'
            || $field->{type} eq 'select' )
        {
            $input = $self->_option_input(
                $field,
                $data->{ $field->{name} },
                $overide->{ $field->{name} },
            );
        }
        else {
            $input = $self->_input( $field, $data );
        }
        $input =~ s/  +/ /g;     # remove extra whitespace.
        $input =~ s/\s+>/>/g;    # cleanup space before closing >
        push @generated,
            {
            label => $self->_label($field),
            input => $input
            };
    }
    return \@generated;
}

1;
