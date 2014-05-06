package Form::Diva;

use 5.014; 

sub new {
    my $class = shift ;
    my $self = { @_ } ;
    bless $self , $class;
    $self->{ class } = $class ;
    #$self->_Init() ;
    return $self ;
}
    
# specification calls for single letter shortcuts on all fields
# these all need to expand to the long form.
sub _expandshortcuts {
    my %DivaShortMap = ( qw / 
        n name t type i id e extra l label p placeholder d default /) ;
    my %DivaLongMap = map { $DivaShortMap{$_}, $_ } keys( %DivaShortMap );
    my $form = shift ;
    foreach my $formfield ( @{$form} ) {
        foreach my $tag ( keys %{$formfield} ) {
            if ($DivaShortMap{$tag}) {
                $formfield->{$DivaShortMap{$tag}} = 
                    delete $formfield->{$tag} ; }
        }
    }
    return $form ;
}

sub _map_form_as_hash {
    my %hash = ();
    foreach my $row ( @{$_[0]} ) { 
        $hash{ $row->{name} } = {
            extra => $row->{extra},
            type  => $row->{type},
        }
    }
return \%hash;

}
sub _Init { 
#     my $self = shift ;
#     my %fieldinfo = {} ;
#     foreach my $formfield ( @{$self->{form}} ) {
#         my %fieldrecord = ();
#         if ( 1 == length $formfield ) { 
#             
#         
# hash %fieldinfo key 
# ( fname => { type => ... , label => ..., ... } ... );
... }

sub generate {
    my $self = shift ;
    my $data = shift ;
    my @generated = ();
    foreach my $field ( keys %{$data} ) {
         my $label_class = $self->{label_class} ;
#         my $input_class = $self->{input_class} ;
#         my %fieldplan   = %{$self->{fieldinfo}{$field}};
#          my $fieldlabel = $self->{form}
#          my $value = $data->{$field};
#          my $label = qq!<label for="$field" ! ;
#          if ( $label_class ) { $label .= qq! class="$label_class" ! }
#          $label .= ">$fieldplan{label}</label>";
#         push @generated, { label => $label };
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