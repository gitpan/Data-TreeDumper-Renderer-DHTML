package Data::TreeDumper::Renderer::DHTML;

use 5.006;
use strict;
use warnings;

require Exporter;
use AutoLoader qw(AUTOLOAD);

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw() ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw();

our $VERSION = '0.01';

#-------------------------------------------------------------------------------------------
sub GetRenderer
{
# setup arguments can be passed to the renderer

return
	(
		{
		  BEGIN => \&RenderDhtmlBegin
		, NODE  => \&RenderDhtmlNode
		, END   => \&RenderDhtmlEnd
		
		# data needed by the renderer
		, PREVIOUS_LEVEL => -1
		, PREVIOUS_ADDRESS => 'ROOT'
		}
	) ;
}


#-------------------------------------------------------------------------------------------

sub RenderDhtmlBegin
{
# render the root by using the name passed as title ($_[0])
# this needs some work be a valid HTML!

<<EOR
<SCRIPT LANGAUGE="javascript">
function toggleList(tree_id) {
    var element = document.getElementById(tree_id);
    if (element) {
        if (element.style.display == 'none') {
            element.style.display = 'block';
        }
        else {
            element.style.display = 'none';
        }
    }
}
</SCRIPT>

<LI><A HREF='javascript:void(0);' onClick='toggleList(\"ROOT\")'>
$_[0] </A></LI>

EOR
}

#-------------------------------------------------------------------------------------------
sub RenderDhtmlNode
{
my
	(
	  $element
	, $level
	, $is_terminal
	, $previous_level_separator
	, $separator
	, $element_name
	, $element_value
	, $dtd_address
	, $address_field
	, $perl_data
	, $setup
	) = @_ ;
	
my $node = '' ;

my $previous_level = $setup->{RENDERER}{PREVIOUS_LEVEL} ;

$node .= "<UL ID='$setup->{RENDERER}{PREVIOUS_ADDRESS}'>\n\n" if($level > $previous_level) ;
$node .= "</UL>" x ($previous_level - $level)  ;

$setup->{RENDERER}{PREVIOUS_LEVEL}   = $level ;
$setup->{RENDERER}{PREVIOUS_ADDRESS} = $dtd_address ;

$element_value = " = $element_value" if($element_value ne '') ;

if($is_terminal)
	{
	$node .= "<LI>$element_name $element_value $address_field $perl_data</LI>\n\n" ;
	}
else
	{
	$node .= "<LI><A HREF='javascript:void(0);' onClick='toggleList(\"$dtd_address\")'>\n"
		 . "$element_name $element_value $address_field $perl_data</A></LI>\n\n" ;
	}
}
	
#-------------------------------------------------------------------------------------------
sub RenderDhtmlEnd
{
"</UL>\n"
} 

1 ;

__END__

=head1 NAME

Data::TreeDumper::Renderer::DHTML - Simple DHTML renderer for B<Data::TreeDumper>

=head1 SYNOPSIS

  # Auto load
  print DumpTree($s, 'Tree', RENDERER => 'DHTML') ;
  
  # Manual load
  print DumpTree
  	(
  	  $s
  	, 'Tree'
  	, RENDERER => Data::TreeDumper::Renderer::DHTML::GetRenderer("argument")
  	) ;

=head1 DESCRIPTION

Simple DHTML renderer for B<Data::TreeDumper>. Thanks to Stevan Little author of Tree::Simple::View
for giving me the idea and providing some code I could snatch.

=head1 Bugs

None I know of in this release but plenty, lurking in the dark corners, waiting to be found.

=head1 EXPORT

None

=head1 AUTHOR

Khemir Nadim ibn Hamouda. <nadim@khemir.net>

Thanks to Ed Avis for showing interest and pushing me to re-write the documentation.

  Copyright (c) 2003 Nadim Ibn Hamouda el Khemir. All rights
  reserved.  This program is free software; you can redis-
  tribute it and/or modify it under the same terms as Perl
  itself.
  
If you find any value in this module, mail me!  All hints, tips, flames and wishes
are welcome at <nadim@khemir.net>.

=head1 SEE ALSO

B<Data::TreeDumper>.

=cut

