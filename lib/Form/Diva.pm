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
    my $fname  = $field->{name};
    my $fclass = $field->{class} || '';
    if   ($fclass) { return qq!class="$fclass"! }
    else           { return qq!class="$self->{input_class}"! }
}

=pod
type: radio
values: [ 'Male', 'Female']
 <form>
}
<input type="radio" name="sex" value="male">Male<br>
<input type="radio" name="sex" value="female">Female
</form> 
=cut

sub _radiocheck {
    my $self        = shift;
    my $field       = shift;
    my $input_class = shift;
    my $output      = '';
    foreach my $val ( @{ $field->{values} } ) {
        my ( $value, $v_lab ) = ( split( /\:/, $val ), $val );
        $output .= qq!<input type="$field->{type}" name="$field->{name}" value="$value">$v_lab<br>\n!;
    }
    return $output;
}

sub generate {
    my $self      = shift;
    my $data      = shift || 0;
    my @generated = ();
    foreach my $field ( @{ $self->{FormMap} } ) {
        my $label       = '';
        my $label_class = $self->{label_class};
        my $input_class = $self->_class_input($field);
        my $label_tag   = $field->{label} || ucfirst( $field->{name} );
        my $label = qq|<LABEL for="$field->{name}" class="$label_class">|
            . qq|$label_tag</LABEL>|;
        my $input = '';
        foreach my $itype (
            qw / text color date datetime datetime-local
            email month number range search tel time url week password/
            )
        {
            if ( $field->{type} eq $itype ) {
                $input .= "<INPUT TYPE=\"$itype\" ";
            }
        }
        if ( $field->{type} eq 'textarea' ) { }
        elsif ( $field->{type} eq 'radio' || $field->{type} eq 'checkbox' ) {
            $input = $self->_radiocheck( $field, $input_class );
        }
        else {
            $input .= "name=\"$field->{name}\" $input_class";

           # attempting to read from data forces evaluation as a hashref
           # but empty data is set to 0 (false) because an empty hashref still
           # evaluates as true, an exception would be thrown.
            my $value = eval { $data->{ $field->{name} } };
            if ($value) { $input .= "value=\"$value\" " }

            # placeholder is only placed in a new record, ie no data.
            unless ($data) {
                my $placeholder = $field->{placeholder} || '';
                if ($placeholder) {
                    $input .= "placeholder=\"$placeholder\" ";
                }
            }
            $input .= '>';
        }
        push @generated, { label => $label, input => $input };
    }
    return \@generated;
}

1;

=pod
