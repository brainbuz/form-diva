package Form::Diva;

use 5.014; 

=pod

FormMap hash of components of a form

FormData a structure of data that is presented to Form::Diva for translation

FormObjects an object returned by Form::Diva containing both the original FormData
plus formlabel and forminput items that Diva generated.

=cut

sub new {
    my $class = shift ;
    my $self = { @_ } ;
    bless $self , $class;
    $self->{ class } = $class ;
    $self->_Init() ;
    return $self ;
}
    
# specification calls for single letter shortcuts on all fields
# these all need to expand to the long form.
sub _expandshortcuts {
    my %DivaShortMap = ( qw / 
        n name t type i id e extra l label p placeholder d default /) ;
    my %DivaLongMap = map { $DivaShortMap{$_}, $_ } keys( %DivaShortMap );
    my $FormMap = shift ;
    foreach my $formfield ( @{$FormMap} ) {
        foreach my $tag ( keys %{$formfield} ) {
            if ($DivaShortMap{$tag}) {
                $formfield->{$DivaShortMap{$tag}} = 
                    delete $formfield->{$tag} ; }
        }
    }
    return $FormMap ;
}
# need to cover all input types
# need to cover all html5 types
# my $diva = Form::Diva->new( 
# label_class => '',
# input_class => 'form-control',
# form        => [ 
#     { n => 'name', t => 'text', p => 'Your Name', l => 'Full Name' },
#     { name => 'phone', type => 'tel', extra => 'required' },
#     { qw / n email t email l Email / },
#     { name => 'our_id', type => 'number', extra => 'disabled' }, 
#     ], );

sub _Init { 
     my $self = shift ;
     $self->{ FormMap } = &_expandshortcuts( $self->{form} );
#     my %fieldinfo = {} ;
#     foreach my $formfield ( @{$self->{form}} ) {
#         my %fieldrecord = ();
#         if ( 1 == length $formfield ) { 
#             
#         
# hash %fieldinfo key 
# ( fname => { type => ... , label => ..., ... } ... );
    }

sub generate {
    my $self = shift ;
    my $data = shift || 0 ;
    my @generated = ();
    foreach my $field ( @{$self->{FormMap}} ) {
         my $label = '';
        my $label_class = $self->{label_class} ;
        my $label_tag = $field->{label} || ucfirst ( $field->{name} );
        my $label = qq|<LABEL for="$field->{name}" class="$label_class">| .
                    qq|$label_tag</LABEL>|;
        my $input = '';
        foreach my $itype ( qw / text color data datetime datetime-local
            email month number range search tel time url week / ) {
            if ( $field->{type} eq $itype ) { 
                $input .= "<INPUT TYPE=\"$itype\" " }
        }
        if ( $field->{type} eq 'textarea' ) { }
        $input .= "name=\"$field->{name}\" " ;
        # attempting to read from data forces evaluation as a hashref
        # but empty data is set to 0 (false) because an empty hashref still
        # evaluates as true, an exception would be thrown.
        my $value = eval { $data->{ $field->{name} } } ;
        if ( $value ) { $input .= "value=\"$value\" " }
        # placeholder is only placed in a new record, ie no data.
        unless ( $data ) {
            my $placeholder = $field->{placeholder} || '';
            if ( $placeholder ) { $input .= "placeholder=\"$placeholder\" " }
            }
#         my $input_class = $self->{input_class} ;
#         my %fieldplan   = %{$self->{fieldinfo}{$field}};
#          my $fieldlabel = $self->{form}
#          my $value = $data->{$field};
#          my $label = qq!<label for="$field" ! ;
#          if ( $label_class ) { $label .= qq! class="$label_class" ! }
#          $label .= ">$fieldplan{label}</label>";
         push @generated, { label => $label , input => $input };
    }
    return \@generated ;
}
        
    
1;    
=pod

 my $diva = Form::Diva->new( 
    label_class => '',
    input_class => 'form-control',
    form        => [ 
        { n => 'name', t => 'text', p => 'Your Name', l => 'Full Name' },
        { name => 'phone', type => 'tel', extra => 'required' },
        { qw / n email t email l Email / },
        { name => 'our_id', type => 'number', extra => 'disabled' }, ];
 @data = $diva->generate( $hashref or $dbicresultrow );