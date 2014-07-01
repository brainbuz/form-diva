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
    unless ( $self->{form_name}) { die "form_name is mandatory"}
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

# sub _field_value {
    # my $self = shift ;
    # my $data = shift ;
    # my $fname = shift ;
    # if ( $data->{'_blank'} ) { }
    # elsif ( $data->{ $fname } ){
        # $data->{ value } = 
        
use Data::Dumper;

sub _field_bits {
    my $self = shift ;
    my $field_ref = shift ;
    my $data = shift ;
    my %in = %{$field_ref} ;
    my %out = () ;
    my $fname = $in{name};
    $out{input_class} = $self->_class_input($field_ref);
    $out{label_class} = $in{class} ?
        qq!class="$in{class}"! :
        qq!class="$self->{label_class}"! ;
    $out{label_displaytext} = $in{label} || ucfirst( $in{name} );
    $out{extra} = $in{extra};
    $out{name}  = $in{name};
    $out{id} = $in{id} ? $in{id} : $in{name};
    $out{type} = $in{type};

    if ( $data ) {
        $out{placeholder} = '';
        $out{rawvalue} = $data->{$fname} || '' ;
    } else {
        if ( $in{placeholder}) { 
            $out{placeholder} = qq!placeholder="$in{placeholder}"! }
        else { $out{placeholder} = '' }
        if ( $in{default}) { $out{rawvalue} = $in{default}; }
        else { $out{rawvalue} = '' }
    }
    $out{value} = qq!value="$out{rawvalue}"!;
    return %out;
}

# Generate Label
# 
sub _label {
    my $self = shift ;
    my $field = shift ;
    my $fname = $field->{name} ;
    my $label_class = $self->{label_class};
    my $label_tag   = $field->{label} || ucfirst( $fname );
    return qq|<LABEL for="$fname" class="$label_class" |
            . qq|form="$self->{form_name}">|
            . qq|$label_tag</LABEL>|;
}

sub _textarea { ... }
sub _input { 
    my $self = shift ;
    my $field = shift ;
    my $data = shift ;

}

# Note need to check default field and disable disabled fields
# this needs to be implemented after data is being handled because
# default is irrelevant if there is data.

sub _radiocheck {    # field, input_class, data;
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
    my $self      = shift;
    my $data      = shift;
    unless ( keys %{$data} ) { $data = undef }    
    my @generated = ();
    foreach my $field ( @{ $self->{FormMap} } ) {
        my $fname = $field->{name};
        my $extra   = $field->{extra} || '';
        my $form = $data->{form_name} ?
                qq!form="$data->{form_name}"! : '' ;
        my $value = $data ?
                $data->{ $fname } : $field->{default} ;   
        my $input_class = $self->_class_input($field);
        my $placeholder = $data ? 
            '' : 
            do { if ($field->{placeholder}) {"placeholder=\"$field->{placeholder}\""}};
        my $input = '';
        foreach my $itype (
            qw / text color date datetime datetime-local
            email month number range search tel time url week password/
            )
        {
            if ( $field->{type} eq $itype ) {
                $input = "<INPUT TYPE=\"$itype\" ";
            }
        }

        # Textarea has option field form="id" where id matches a form
        # the form id should be passed through data.
        # Textarea needs to be built after data structure.
        if ( $field->{type} eq 'textarea' ) {      
            $input = qq |<textarea $form $input_class $extra $placeholder
            name="$fname">$value</textarea> |;
warn "Textarea Placeholder ? $placeholder"            ;
        }
        elsif ( $field->{type} eq 'radio' || $field->{type} eq 'checkbox' ) {
            $input = $self->_radiocheck( $field, $input_class );
        }
        else {
            $input .= qq |name="$field->{name}" $input_class $placeholder|;

           # attempting to read from data forces evaluation as a hashref
           # but empty data is set to 0 (false) because an empty hashref still
           # evaluates as true, an exception would be thrown.
            my $value = eval { $data->{ $fname } };
            if ($value) { $input .= " value=\"$value\" " }
            $input .= '>';
        }
        $input =~ s/  +/ /g; # remove extra whitespace.
        $input =~ s/\s+>/>/g ; # cleanup space before closing >
        push @generated, { 
            label => $self->_label( $field ),
            input => $input };
    }
    return \@generated;
}

1;

=pod
