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

our $VERSION = '0.03';


use constant DHTML_CLASS => 'data_treedumper_dhtml' ;

my $uuuid = int(rand(100_000)) ;

#-------------------------------------------------------------------------------------------
sub GetRenderer
{
my $id = "${uuuid}_ROOT" ;
$uuuid++ ;

return
	(
		{
		  BEGIN => \&RenderDhtmlBegin
		, NODE  => \&RenderDhtmlNode
		, END   => \&RenderDhtmlEnd
		
		# data needed by the renderer
		, PREVIOUS_LEVEL => -1
		, PREVIOUS_ADDRESS => $id
		
		, @_
		}
	) ;
}


#-------------------------------------------------------------------------------------------

sub RenderDhtmlBegin
{
# render the root by using the name passed as title ($_[0])

my ($title, undef, undef, $setup) = @_ ;

my $class = $setup->{RENDERER}{CLASS} || DHTML_CLASS ;

my $javascript = <<EOR ;
<script LANGUAGE="javascript">
function toggleList(tree_id) 
{
if (document.getElementById) 
	{
	var element = document.getElementById(tree_id);
	
	if (element) 
		{
		if (element.style.display == 'none') 
			{
			element.style.display = 'block';
			}
		else
			{
			element.style.display = 'none';
			}
		}
	}
else if (document.all) 
	{
	var element = document.all[tree_id];
	
	if (element) 
		{
		if (element.style.display == 'none') 
			{
			element.style.display = 'block';
			}
		else
			{
			element.style.display = 'none';
			}
		}
	}
else if (document.layers) 
	{
	var element = document.layers[tree_id];
	
	if (element) 
		{
		if (element.display == 'none') 
			{
			element.display = 'block';
			}
		else
			{
			element.display = 'none';
			}
		}
	}
} 

</script>

EOR

my $style = <<EOS;
<style>
span.$class {font-family:monospace ; white-space:pre}
li.$class {list-style-type:none ; margin:0 ; padding:0 ; line-height: 1em}
ul.$class, li.$class {margin:0 ; padding:0 ;}
</style>
EOS

my $header = <<EOH ;
<li class='$class'><span class='$class'><a href='javascript:void(0);' onClick='toggleList(\"$setup->{RENDERER}{PREVIOUS_ADDRESS}\")'>$title </a></span></li>
EOH

$style = '' if(exists $setup->{RENDERER}{NO_STYLE}) ;

if(exists $setup->{RENDERER}{STYLE})
	{
	$setup->{RENDERER}{STYLE} .= $style ;
	return($javascript . $header) ;
	}
else
	{
	return($style . $javascript . $header) ;
	}
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
	
my $class = $setup->{RENDERER}{CLASS} || DHTML_CLASS ;

my $glyph = '' ;
$glyph = $previous_level_separator. $separator unless ($setup->{RENDERER}{NO_GLYPH}) ;
	
$element_value = " = $element_value"    if($element_value ne '') ;
$address_field = " $address_field" if $address_field ne '' ;
$perl_data     = " $perl_data"     if $perl_data ne '' ;

my $node = '' ;
$node = "<ul class='$class' ID='$setup->{RENDERER}{PREVIOUS_ADDRESS}'>\n\n" if($level > $setup->{RENDERER}{PREVIOUS_LEVEL}) ;
$node .= "</ul>" x ($setup->{RENDERER}{PREVIOUS_LEVEL} - $level)  ;

if($is_terminal)
	{
	$node .= "<li class='$class'><span class='$class'>$glyph$element_name $element_value$address_field$perl_data</span></li>\n\n" ;
	}
else
	{
	$node .= "<li class='$class'>"
		 . "<span class='$class'><a href='javascript:void(0);' onClick='toggleList(\"${uuuid}_$dtd_address\")'>"
		 . "$glyph$element_name $element_value$address_field$perl_data</a></span></li>\n\n" ;
	}

$setup->{RENDERER}{PREVIOUS_LEVEL}   = $level ;
$setup->{RENDERER}{PREVIOUS_ADDRESS} = $uuuid . '_' .  $dtd_address ;
$uuuid++ ;

return($node) ;
}
	
#-------------------------------------------------------------------------------------------
sub RenderDhtmlEnd
{
"</ul>\n"
} 

#-------------------------------------------------------------------------------------------
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

Thanks to my colleague Staffan Maahlén for being a HTML/CSS freak and pointing a zillion little mistakes in
the generated HTML.

CSS style is dumped to $setup->{RENDERER}{STYLE} (a ref to a scalar) if it exists. This allows you to collect
all the CSS then output it at the top of the HTML code.

{RENDERER}{NO_STYLE} removes style section generation. This is usefull when you defined you styles by hand.

The output will use class 'data_tree_dumper_dhtml' for <li> and <ul>. The class can be renamed with the help of 
{RENDERER}{CLASS}. This allows you to dump multiple data structures and display them with a diffrent styles.

B<Data::TreeDumper> outputs the tree lines as ASCII text by default. If {RENDERER}{NO_GLYPH} and RENDERER}{NO_STYLE}
are defined, no lines are output and the indentation will be the default <li> style. If you would like to specify a 
specific style for your tree dump, defined you own CSS and set the appropriate class through {RENDERER}{CLASS.

=head1 Bugs

The previous version displayed wrong in IE and Mozilla but right in Konqueror. It now works rather fine in IE and 
Mozilla but wraps in Konqueror when it doens't in Mozilla!

I'm no web guy so if you want to make this module work in your favorit browser, contribute some code.

I'll hapilly hand this module over to someone who knows what he does :-)

=head1 EXPORT

None

=head1 AUTHOR

Khemir Nadim ibn Hamouda. <nadim@khemir.net>

  Copyright (c) 2003 Nadim Ibn Hamouda el Khemir. All rights
  reserved.  This program is free software; you can redis-
  tribute it and/or modify it under the same terms as Perl
  itself.
  
If you find any value in this module, mail me!  All hints, tips, flames and wishes
are welcome at <nadim@khemir.net>.

=head1 SEE ALSO

B<Data::TreeDumper>.

=cut

