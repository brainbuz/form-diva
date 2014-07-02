package Form::Diva;

use 5.010;

=pod

FormMap hash of components of a form

FormData a structure of data that is presented to Form::Diva for translation

FormObjects an object returned by Form::Diva containing both the original FormData
plus formlabel and forminput items that Diva generated.

=cut

sub new {
    my $class = shift;
    my $self  = {@_};
    unless ( $self->{form_name} ) { die "form_name is mandatory" }
    bless $self, $class;
    $self->{class}   = $class;
    $self->{FormMap} = &_expandshortcuts( $self->{form} );
    return $self;
}

# specification calls for single letter shortcuts on all fields
# these all need to expand to the long form.
sub _expandshortcuts {
    my %DivaShortMap = (
        qw /
            n name t type i id e extra l label p placeholder
            d default v values value values c class/
    );
    my %DivaLongMap = map { $DivaShortMap{$_}, $_ } keys(%DivaShortMap);
    my $FormMap = shift;
    foreach my $formfield ( @{$FormMap} ) {
        foreach my $tag ( keys %{$formfield} ) {
            if ( $DivaShortMap{$tag} ) {
                $formfield->{ $DivaShortMap{$tag} }
                    = delete $formfield->{$tag};
            }
        }
    }
    return $FormMap;
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
        $out{type} = qq!type="$in{type}"!; 
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
    return
          qq|<LABEL for="$fname" class="$label_class" |
        . qq|form="$self->{form_name}">|
        . qq|$label_tag</LABEL>|;
}

sub _input {
    my $self  = shift;
    my $field = shift;
    my $data  = shift;
    my %B     = $self->_field_bits( $field, $data );
    my $input = '';
    if ( $B{textarea} ) {
        $input = qq|<TEXTAREA $B{name} $B{id} form="$self->{form_name}"
        $B{input_class} $B{placeholder} $B{extra} >$B{rawvalue}</TEXTAREA>|;
    }
    else {
        $input .= qq|<INPUT $B{type} $B{name} $B{id} form="$self->{form_name}"
        $B{input_class} $B{value} $B{placeholder} $B{extra} >|;
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
    if ( $field->{disabled} ) { $extra .= ' disabled ' }
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

sub generate {
    my $self = shift;
    my $data = shift;
    unless ( keys %{$data} ) { $data = undef }
    my @generated = ();
    foreach my $field ( @{ $self->{FormMap} } ) {
        my $input = undef;
        if ( $field->{type} eq 'radio' || $field->{type} eq 'checkbox' ) {
            $input = $self->_radiocheck( $field, $self->_class_input($field) );
        }
        else {
            $input = $self->_input( $field, $data);
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

=pod
