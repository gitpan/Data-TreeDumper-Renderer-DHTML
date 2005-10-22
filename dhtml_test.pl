
use strict ;
use Data::TreeDumper ;

#-------------------------------------------------------------------------------

# the renderer can return a default style. This is needed as styles must be at the top of the document
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
		
my $style2 ;
my $body2 = DumpTree
		(
		  GetData(), 'Data2'
		, DISPLAY_ROOT_ADDRESS => 1
		, DISPLAY_PERL_ADDRESS => 1
		, DISPLAY_PERL_SIZE => 1
		, RENDERER => 
			{
			  NAME => 'DHTML'
			, STYLE => \$style2
			, COLLAPSED => 1
			, CLASS => 'collapse_test'
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
Automatically generated by Perl and Data::TreeDumper::Renderer::DHTML
-->

<head>
<title>Data</title>
$style
$style2
</head>

<body>

$body

$body2

<p>
   <img src='http://www.w3.org/Icons/valid-xhtml10' alt='Valid XTML 1.0!' height="15" width='44' />
</p>

</body>
</html>
EOT

#-------------------------------------------------------------------------------

sub GetData
{
my $s = {
  'REGEX' => q#(<|>|&|\'|\"    &nbsp;)#,
  'STDIN' => \*STDIN,
  'RS' => \4,
  
  'A' => {
    'a' => {},
    'code1' => sub { "DUMMY" },
    'b' => {
      'a' => 0,
      'b' => 1,
      'c' => {
        'a' => 1,
        'b' => 1,
        'c' => 1,
        }
      },
    'b2' => {
      'a' => 1,
      'b' => 1,
      'c' => 1,
      }
  },
  'C' => {
    'b' => {
      'a' => {
        'c' => 42,
        'a' => 3,
        'b' => sub { "DUMMY" },
	'empty' => undef
      }
    }
  },
  'ARRAY' => [
    'elment_1',
    'element_2',
    'element_3',
    [1, 2],
    {a => 1, b => 2}
  ]
};

${$s->{'A'}{'code3'}} = $s->{'A'}{'code1'};
$s->{'A'}{'code2'} = $s->{'A'}{'code1'};
$s->{'CopyOfARRAY'} = $s->{'ARRAY'};
$s->{'C1'} = \($s->{'C2'});
$s->{'C2'} = \($s->{'C1'});

$s->{za} = $s->{A} ;

my $object = bless {A =>[], B => 123}, 'SuperObject' ;
$s->{object} = $object ;

return($s) ;
}


