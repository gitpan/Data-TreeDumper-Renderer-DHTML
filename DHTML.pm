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

our $VERSION = '0.05';

use constant DHTML_CLASS => 'data_treedumper_dhtml' ;

my $uuuid = int(rand(100_000)) ;

my %ascii_to_html =
	(
	'<' => '&lt;'
	, '>' => '&gt;'
	, '&' => '&amp;'
	, "'" => '&apos;'
	, '"' => '&quot;'
	, ' ' => '&nbsp;'
	) ;

#-------------------------------------------------------------------------------------------

sub GetRenderer
{
my $expand_collapse_button_id = "expand_collapse_button_${uuuid}" ;
$uuuid++ ;

my $search_button_id = "search_button_${uuuid}" ;
$uuuid++ ;

return
	(
		{
		  BEGIN => \&RenderDhtmlBegin
		, NODE  => \&RenderDhtmlNode
		, END   => \&RenderDhtmlEnd
		
		# data needed by the renderer
		, EXPAND_COLLAPSE_BUTTON_ID => $expand_collapse_button_id
		, SEARCH_BUTTON_ID          => $search_button_id
		
		, PREVIOUS_LEVEL   => -1
		, PREVIOUS_ADDRESS => "c_${uuuid}_ROOT"
		, TABULATION       => 0
		, @_
		}
	) ;
}


#-------------------------------------------------------------------------------------------

sub RenderDhtmlBegin
{
my ($title, $td_address, $element, $perl_size, $perl_address, $setup) = @_ ;

my $class = $setup->{RENDERER}{CLASS} || DHTML_CLASS ;

my $button_container = '' ;
if(exists $setup->{RENDERER}{BUTTON})
	{
	$button_container .= "<div class='tdump_button_container'>\n" ;
	
	if($setup->{RENDERER}{BUTTON}{COLLAPSE_EXPAND})
		{
		$button_container .= "   <input type='button' id='$setup->{RENDERER}{EXPAND_COLLAPSE_BUTTON_ID}' onclick='expand_collapse(true)' value='Collapse'/>\n" ;
		}
		
	if($setup->{RENDERER}{BUTTON}{SEARCH})
		{
		$button_container .= "   <input type='button' id='$setup->{RENDERER}{SEARCH_BUTTON_ID}' onclick='search()' value='Search'/>\n" ;
		}
		
	$button_container .= "</div>\n\n" ;
	}

my $style = <<EOS;
<style type='text/css' >
.$class li {list-style-type:none ; margin:0 ; padding:0 ; line-height: 1em ;}

.$class ul {margin:0 ; padding:0 ;}
ul.$class {font-family:monospace ; white-space: nowrap ;}
</style>
EOS

if(defined $setup->{RENDERER}{STYLE})
	{
	if('SCALAR' eq ref $setup->{RENDERER}{STYLE})
		{
		${$setup->{RENDERER}{STYLE}} = $style ;
		$style = '' ;
		}
	else
		{
		$style = $setup->{RENDERER}{STYLE} ;
		}
	}
	
$style = '' if(exists $setup->{RENDERER}{NO_STYLE}) ;

$perl_size = "&lt;$perl_size&gt;" if $perl_size ne '' ;

my $header = <<EOH ;
<ul class = '$class'>
   <li class='$class'>
      <a id='a_${uuuid}_ROOT' href='javascript:void(0);' onclick='toggleList(\"$setup->{RENDERER}{PREVIOUS_ADDRESS}\")'>$title</a><a> [$td_address] $perl_size $perl_address</a>
EOH

$setup->{RENDERER}{TABULATION} = 2 ,
push @{$setup->{RENDERER}{NODES}{A_IDS}}, "\"a_${uuuid}_ROOT\"";
push @{$setup->{RENDERER}{NODES}{COLLAPSABLE_IDS}}, "\"c_${uuuid}_ROOT\"" ;

$setup->{RENDERER}{PREVIOUS_ADDRESS} = "c_${uuuid}_ROOT" ;
$uuuid++ ;

return($style . $button_container . $header) ;
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
	, $td_address
	, $address_link
	, $perl_size
	, $perl_address
	, $setup
	) = @_ ;
	
my $tabulation = $setup->{RENDERER}{TABULATION} ;
	
my $class = $setup->{RENDERER}{CLASS} || DHTML_CLASS ;

my $glyph = '' ;
unless ($setup->{RENDERER}{NO_GLYPH})
	{
	$glyph = $previous_level_separator. $separator ;
	$glyph =~ s/ /&nbsp;/g ;
	}

$perl_size = "&lt;$perl_size&gt;" if $perl_size ne '' ;

if($element_value ne '')
	{
	$element_value =~ s/(<|>|&|\'|\"|\ )/$ascii_to_html{$1}/eg ;
	$element_value = " = $element_value" ;
	}

my $node = '' ;
if($level > $setup->{RENDERER}{PREVIOUS_LEVEL})
	{
	$node = '   ' x $tabulation . "<ul id='$setup->{RENDERER}{PREVIOUS_ADDRESS}'>\n" ;
	$tabulation++ ;
	}
else
	{
	if($level < $setup->{RENDERER}{PREVIOUS_LEVEL})
		{
		for (my $i = 0 ; $i < $setup->{RENDERER}{PREVIOUS_LEVEL} - $level ; $i++)
			{
			$tabulation-- ;
			$node .= '   ' x $tabulation . "</ul>\n" ;
			
			$tabulation-- ;
			$node .= '   ' x $tabulation . "</li>\n" ;
			}
		}
	}

# keep nodes id for search
push @{$setup->{RENDERER}{NODES}{A_IDS}}, "\"a_${uuuid}_$td_address\"";

if($is_terminal)
	{
	$node .= '   ' x $tabulation . "<li><a id='a_${uuuid}_$td_address' name=\"$td_address\">$glyph$element_name$element_value" ;
	
	if($setup->{DISPLAY_ADDRESS})
		{
		if(defined $address_link)
			{
			$node .= " [$td_address -> </a><a href=\"#$address_link\">$address_link</a><a>] $perl_size $perl_address</a></li>\n" ;
			}
		else
			{
			$node .= " [$td_address]</a><a /><a> $perl_size $perl_address</a></li>\n" ;
			}
		}
	else	
		{
		$node .= "</a><a /><a> $perl_size $perl_address</a></li>\n" ;
		}
	}
else
	{
	if($setup->{RENDERER}{BUTTON}{COLLAPSE_EXPAND})
		{
		push @{$setup->{RENDERER}{NODES}{COLLAPSABLE_IDS}}, "\"c_${uuuid}_$td_address\"" ;
		}
		
	$node .= '   ' x $tabulation . "<li>\n" ;
	$tabulation++ ;
	
	$node .= '   ' x $tabulation 
		. "<a id='a_${uuuid}_$td_address' name='$td_address' href='javascript:void(0);' onclick='toggleList(\"c_${uuuid}_$td_address\")'>"
		. "$glyph$element_name</a><a>$element_value [$td_address] $perl_size $perl_address</a>\n" ;
	}

$setup->{RENDERER}{TABULATION}       = $tabulation ;
$setup->{RENDERER}{PREVIOUS_LEVEL}   = $level ;
$setup->{RENDERER}{PREVIOUS_ADDRESS} = "c_${uuuid}_$td_address" ;
$uuuid++ ;

return($node) ;
}
	
#-------------------------------------------------------------------------------------------
sub RenderDhtmlEnd
{
my $setup = shift ;

unless(exists $setup->{RENDERER}{BUTTON})
	{
	#~ "   </li>\n</ul>\n" ;
	"   </ul>   </li>\n</ul>\n" ;
	}
else
	{
	my $a_ids = join "\n\t\t, ", @{$setup->{RENDERER}{NODES}{A_IDS}} ;
	my $collapsable_ids = join "\n\t\t\t\t, ", @{$setup->{RENDERER}{NODES}{COLLAPSABLE_IDS}} ;

<<EOS
      </ul>
   </li>
</ul>

<script type='text/javascript'>
<!--

var a_id_array= new Array
		(
		$a_ids
		) ;

function search()
{
var string_to_search = prompt('DTD::DHTML Search','');
var regexp = new RegExp(string_to_search, 'i') ;

var i ;
for (i = 0; i < a_id_array.length; i++)
	{
	if (document.getElementById) 
		{
		if(regexp.test(document.getElementById(a_id_array[i]).text))
			{
			confirm('"' + document.getElementById(a_id_array[i]).text + '" node id:' + document.getElementById(a_id_array[i]).id) ;
			}
		}
	else if (document.all) 
		{
		confirm(document.all[a_id_array[0]].value) ;
		}
	else if (document.layers) 
		{
		confirm(document.layers[a_id_array[0]].value) ;
		}
	}
}

var collapsable_id_array = new Array
				(
				$collapsable_ids
				) ;

var expanded = 1 ;

function expand_collapse() 
{
var style ;
if(expanded == 1)
	{
	expanded = 0 ;
	style = "none" ;
	replace_button_text("$setup->{RENDERER}{EXPAND_COLLAPSE_BUTTON_ID}", " Expand ") ;
	}
else
	{
	expanded = 1 ;
	style = "block" ;
	replace_button_text("$setup->{RENDERER}{EXPAND_COLLAPSE_BUTTON_ID}", "Collapse") ;
	}

var i;
for (i = 0; i < collapsable_id_array.length; i++)
	{
	if (document.getElementById) 
		{
		document.getElementById(collapsable_id_array[i]).style.display = style ;
		}
	else if (document.all) 
		{
		document.all[collapsable_id_array[i]].style.display = style ;
		}
	else if (document.layers) 
		{
		document.layers[collapsable_id_array[i]].display = style ;
		}
	}
}

function replace_button_text(buttonId, text)
{
if (document.getElementById)
	{
	var button=document.getElementById(buttonId);
	if (button)
		{
		if (button.childNodes[0])
			{
			button.childNodes[0].nodeValue=text;
			}
		else if (button.value)
			{
			button.value=text;
			}
		else //if (button.innerHTML)
			{
			button.innerHTML=text;
			}
		}
	}
}

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

-->
</script>
EOS
	}
} 

#-------------------------------------------------------------------------------------------
1 ;

__END__

=head1 NAME

Data::TreeDumper::Renderer::DHTML - DHTML renderer for B<Data::TreeDumper>

=head1 SYNOPSIS

  use Data::TreeDumper ;
  
  #-------------------------------------------------------------------------------
  
  my $style ;
  my $body = DumpTree
  		(
  		  GetData(), 'Data'
  		, DISPLAY_ROOT_ADDRESS => 1
  		, DISPLAY_PERL_ADDRESS => 1
  		, DISPLAY_PERL_SIZE => 1
  		, RENDERER => 
  			{
  			  NAME => 'DHTML'
  			, STYLE => \$style
  			, BUTTON =>
  				{
  				  COLLAPSE_EXPAND => 1
  				, SEARCH => 1
  				}
  			}
  		) ;
  		
  		
  print <<EOT;
  <?xml version="1.0" encoding="iso-8859-1"?>
  <!DOCTYPE html 
       PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
       "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
  >
  
  <html>
  
  <!--
  Automatically generated by Perl and Data::TreeDumper::DHTML
  -->
  
  <head>
  <title>Data</title>
  
  $style
  </head>
  <body>
  $body
  
  <p>
     <img src='http://www.w3.org/Icons/valid-xhtml10' alt='Valid HTML 4.01!' height="15" width='44' />
  </p>
  
  </body>
  </html>
  EOT

=head1 DESCRIPTION

Simple DHTML renderer for B<Data::TreeDumper>. 

Thanks to Stevan Little author of Tree::Simple::View
for giving me the idea and providing some code I could snatch.

=head1 EXAMPLE

B<dhtml_test.pl>


=head1 OPTIONS

=head2 Style

CSS style is dumped to $setup->{RENDERER}{STYLE} (a ref to a scalar) if it exists. This allows you to collect
all the CSS then output it at the top of the HTML code.

{RENDERER}{NO_STYLE} removes style section generation. This is usefull when you defined your styles by hand.

=head2 Class

The output will use class 'data_tree_dumper_dhtml' for <li> and <ul>. The class can be renamed with the help of 
{RENDERER}{CLASS}. This allows you to dump multiple data structures and display them with a diffrent styles.

=head2 Glyphs

B<Data::TreeDumper> outputs the tree lines as ASCII text by default. If {RENDERER}{NO_GLYPH} and RENDERER}{NO_STYLE}
are defined, no lines are output and the indentation will be the default <li> style. If you would like to specify a 
specific style for your tree dump, defined you own CSS and set the appropriate class through {RENDERER}{CLASS}.

=head2 Expand/Collapse

If {RENDERER}{BUTTON}{COLLAPSE_EXPAND} is set, the rendered will add a button to allow the user to collapse and expand the
tree.

=head2 Search

If {RENDERER}{BUTTON}{SEARCH} is set, the rendered will add a button to allow the user to search the tree. This is 
a primitive search and has no other value than for test.

=head1 Bugs

I'll hapilly hand this module over to someone who knows what he does :-)

Check the TODO file.

=head1 EXPORT

None

=head1 AUTHORS

Khemir Nadim ibn Hamouda. <nadim@khemir.net>

Staffan Maahlén.

  Copyright (c) 2003 Nadim Ibn Hamouda el Khemir and 
  Staffan Maahlén. All rights reserved.
  
  This program is free software; you can redistribute
  it and/or modify it under the same terms as Perlitself.
  
If you find any value in this module, mail me!  All hints, tips, flames and wishes
are welcome at <nadim@khemir.net>.

=head1 SEE ALSO

B<Data::TreeDumper>.

=cut

