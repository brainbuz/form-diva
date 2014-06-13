package Form::Diva;

use 5.014;

=pod

FormMap hash of components of a form

FormData a structure of data that is presented to Form::Diva for translation

FormObjects an object returned by Form::Diva containing both the original FormData
plus formlabel and forminput items that Diva generated.

=cut

sub new {
    my $class = shift;
    my $self  = {@_};
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
            n name t type i id e extra l label p placeholder d default v values c class/
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

=pod
Need to work on Pre selected Checkbox radio syntax is the same.
the states need to come from data not source. 
We can make a check box pre selected (checked) even before the users try to select, using the entry "checked"

Example Code:
<form name=myform>
<input type="checkbox" name=mybox value="1" checked>one
<input type="checkbox" name=mybox value="2" >two
<input type="checkbox" name=mybox value="3" checked>three
</form>

Result:
one two three

Non Editable / Non Selectable check box
We can make a Checkbox non selectable (disable) using the entry "disabled"

Example:
<form name=myform>
<input type="checkbox" name=mybox value="1" disabled>one
<input type="checkbox" name=mybox value="2" disabled>two
<input type="checkbox" name=mybox value="3" disabled>three
</form>

<input type="radio" name=myradio value="1" >one
<input type="radio" name=myradio value="2" checked>two
<input type="radio" name=myradio value="1" disabled>one
=cut

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
    my $data      = shift || undef;
    my @generated = ();
    foreach my $field ( @{ $self->{FormMap} } ) {
        my $fname = $field->{name};
        my $label       = '';
        my $extra   = $field->{extra} || '';
        my $form = $data->{form_name} ?
                qq!form="$data->{form_name}"! : '' ;
        my $placeholder = $field->{placeholder};   
        my $value = $data ?
                $data->{ $fname } : $field->{default} ;   
        my $label_class = $self->{label_class};
        my $input_class = $self->_class_input($field);
        my $label_tag   = $field->{label} || ucfirst( $field->{name} );
        my $label = qq|<LABEL for="$fname" class="$label_class">|
            . qq|$label_tag</LABEL>|;
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
        }
        elsif ( $field->{type} eq 'radio' || $field->{type} eq 'checkbox' ) {
            $input = $self->_radiocheck( $field, $input_class );
        }
        else {
            $input .= qq |name="$field->{name}" $input_class|;

           # attempting to read from data forces evaluation as a hashref
           # but empty data is set to 0 (false) because an empty hashref still
           # evaluates as true, an exception would be thrown.
            my $value = eval { $data->{ $fname } };
            if ($value) { $input .= " value=\"$value\" " }

            # placeholder is only placed in a new record, ie no data.
            unless ($data) {
                my $placeholder = $field->{placeholder} || '';
                if ($placeholder) {
                    $input .= "placeholder=\"$placeholder\" ";
                }
            }
            $input .= '>';
            $input =~ s/\s+/ /g; # remove extra whitespace.
        }
        push @generated, { label => $label, input => $input };
    }
    return \@generated;
}

1;

=pod
