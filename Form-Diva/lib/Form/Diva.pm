use strict;
use warnings;
no warnings 'uninitialized';

package Form::Diva;

# ABSTRACT: Generate HTML5 form label and input fields

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

# Note need to check default field and disable disabled fields
# this needs to be implemented after data is being handled because
# default is irrelevant if there is data.

sub _radiocheck {            # field, input_class, data;
    my $self        = shift;
    my $field       = shift;
    my $input_class = shift;
    my $data        = shift;
    my $output      = '';
    my $extra       = $field->{extra} || "";
    my $default     = $field->{default}
        ? do {
        if   ($data) {undef}
        else         { $field->{default} }
        }
        : undef;
    foreach my $val ( @{ $field->{values} } ) {
        my ( $value, $v_lab ) = ( split( /\:/, $val ), $val );
        my $checked = '';
        if    ( $data    eq $value ) { $checked = 'checked ' }
        elsif ( $default eq $value ) { $checked = 'checked ' }
        $output
            .= qq!<input type="$field->{type}" $input_class $extra name="$field->{name}" value="$value" $checked>$v_lab<br>\n!;
    }
    return $output;
}

=pod

<select name="browser">
<option value="firefox">Firefox</option>
<option value="ie">IE</option>
  <optgroup label="Swedish Cars">
    <option value="volvo">Volvo</option>
    <option value="saab">Saab</option>
  </optgroup>
</select>

Datalist-Option

<input type=text list=browsers> # selected is value
<datalist id=browsers>
  <option value="Opera">
  <option value="Safari">
</datalist>

=cut
# also datalist.

sub _select {            # field, input_class, data;
    my $self        = shift;
    my $field       = shift;
    my $data        = shift;
    my $class       = $self->_class_input( $field ) ;
    my $extra       = $field->{extra} || "";
    my @values      =  @{ $field->{values} };
    my $is_datalist  = $field->{type} eq 'datalist' ? 1 : 0 ;
    my $default     = $field->{default}
        ? do { if ($data) {undef} else { $field->{default} } }
        : undef;
    my $output = undef;
    if ( $is_datalist ) {
        my $value = '';
        if ( $data ) { $value= qq|value="$data"| }
        elsif ( $default )  { $value= qq|value="$default"| }
        $output = qq|<INPUT list="$field->{name}" type="text" $extra $class $value />\n| .
        qq|<DATALIST id="$field->{name}">\n|; 
        }
    else {
        $output = qq|<SELECT name="$field->{name}" $extra $class>\n|; 
        } 
    foreach my $val ( @{ $field->{values} } ) {
        my ( $value, $v_lab ) = ( split( /\:/, $val ), $val );
        my $selected = '';
        if( $is_datalist ) { $selected = '' }
        elsif    ( $data    eq $value ) { $selected = 'selected ' }
        elsif ( $default eq $value ) { $selected = 'selected ' }
        $output .= qq| <option value="$value" $selected>$v_lab</option>\n|;
    }
    if ( $is_datalist ) { $output .= '</DATALIST>'; }
    else { $output .= '</SELECT>'; }
    return $output;
}

sub generate {
    my $self = shift;
    my $data = shift;
    unless ( keys %{$data} ) { $data = undef }
    my @generated = ();
    foreach my $field ( @{ $self->{FormMap} } ) {
        my $input = undef;
        if ( $field->{type} eq 'radio' || $field->{type} eq 'checkbox' ) {
            $input = $self->_radiocheck(
                $field,
                $self->_class_input($field),
                $data->{ $field->{name} }
            );
        }
        elsif( $field->{type} eq 'select' || $field->{type} eq 'datalist' ) {
            $input = $self->_select(
                $field,
                $data->{ $field->{name}});
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