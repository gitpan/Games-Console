
# Games-Console - a 2D quake-style console

package Games::Console;

# (C) by Tels <http://bloodgate.com/>

use strict;

use vars qw/$VERSION/;

$VERSION = '0.01';

##############################################################################
# methods

sub new
  {
  # create a new console
  my $class = shift;

  my $self = { };
  bless $self, $class;
  
  my $args = $_[0];
  $args = { @_ } unless ref $args eq 'HASH';

  $self->{logfile} = $args->{logfile} || '';
  $self->{loglevel} = int(abs($args->{loglevel} || 0));
  
  $self->{background_color} = $args->{background} || [0.4, 0.6, 1];
  $self->{background_alpha} = $args->{background_alpha} || 0.5;

  $self->{text_color} = $args->{text_color} || [ 0.4, 0.6, 0.8 ];
  $self->{text_alpha} = $args->{text_alpha} || 0.8;
  
  $self->{font} = $args->{font};

  # maximum height/width in percent
  $self->{width} = abs($self->{width} || 100);
  $self->{height} = abs($args->{height} || 50);
  
  $self->{screen_width} = 640;
  $self->{screen_height} = 480;
  
  $self->{direction} = 1;
  # in percent per second (50 means it takes 2 seconds to open console)
  $self->{speed} = 50;
  
  $self->{start_percent} = 0;		# started moving at this percentage
  $self->{start_time} = 0;		# and this time
  $self->{cur_percent} = 0;		# cur percent visible

  $self->{messages} = [];
  
  $self->{spacing_y} = 0;
  $self->{border_x} = 5;
  $self->{border_y} = 5;
  $self->{prompt} = $args->{prompt} || '> ';
  $self->{cursor} = $args->{cursor} || '_';
  
  $self->{last_cursor} = 0;
  $self->{cursor_time} = abs($args->{cursor_time} || 300);
  
  $self->{current_input} = '';	# what user entered until ENTER key is pressed

  $self->{cur_height} = 0;	# invisble
  $self;
  }

sub close
  {
  my $self = shift;

  $self->{direction} = -1 if $self->{visible};
  }

sub open
  {
  my $self = shift;

  $self->{direction} = 1; $self->{visible} = 1;
  $self->{start_time} = shift;
  $self->{start_percent} = $self->{cur_percent};
  }

sub toggle
  {
  my $self = shift;

  if (!$self->{visible})
    {
    $self->{direction} = 1; $self->{visible} = 1;
    }
  else
    {
    $self->{direction} = - $self->{direction};
    $self->{direction} = -1 if $self->{direction} == 0;
    }
  $self->{start_time} = shift;
  $self->{start_percent} = $self->{cur_percent};
  }

sub visible
  {
  # make immidiately visible/invisible
  my $self = shift;

  if (@_ > 0)
    {
    my $v = $_[0] ? 1 : 0;
    if ($self->{visible} && !$v)
      {
      $self->{direction} = 0;
      $self->{cur_percent} = 0;
      }
    elsif (!$self->{visible} && $v)
      {
      $self->{direction} = 1;
      $self->{start_percent} = 0;
      $self->{start_time} = shift;
      }
    $self->{visible} = $v;
    }
  $self->{visible};
  }

sub render
  {
  my ($self,$current_time) = @_;

  return unless $self->{visible};

  if ($self->{direction} != 0)
    {
    $self->{cur_percent} = $self->{start_percent} + 
       $self->{direction} * ($current_time - $self->{start_time}) *
       $self->{speed} / 100;
    }

  if ($self->{cur_percent} < 0)
    {
    # fully closed
    $self->{cur_percent} = 0;
    $self->{start_percent} = 0;
    $self->{direction} = 0;
    $self->{visible} = 0;
    return;
    }

  if ($self->{cur_percent} > 100)
    {
    # fully open
    $self->{cur_percent} = 100;
    $self->{direction} = 0;
    }
  
  # calculate height/width
  my $w = $self->{width} * $self->{screen_width} / 100;
  my $h = ($self->{cur_percent} / 100) 
          * $self->{height} * $self->{screen_height} / 100;

  $self->_render( 0, $self->{screen_height}, $w, $h, $current_time );

  }

sub _render
  {
  # prepare the output, render the background and the text
  my ($self,$x,$y,$w,$h,$time) = @_;

  }

sub message
  {
  my ($self,$msg,$loglevel) = @_;

  push @{$self->{messages}}, [ $msg, $loglevel ];

  $self->log ($msg,$loglevel);

  $self;
  }

sub log
  {
  my ($self,$msg,$loglevel) = @_;

  }

sub screen_width
  {
  my $self = shift;

  if (@_ > 0)
    {
    $self->{screen_width} = $_[0];
    $self->{font}->screen_width($_[0]);
    }
  $self->{screen_width};
  }

sub screen_height
  {
  my $self = shift;

  if (@_ > 0)
    {
    $self->{screen_height} = $_[0];
    $self->{font}->screen_height($_[0]);
    }
  $self->{screen_height};
  }

sub background_color
  {
  my $self = shift;

  $self->{background_color} = shift if @_ > 0;
  $self->{background_color};
  }

sub text_color
  {
  my $self = shift;

  $self->{text_color} = shift if @_ > 0;
  $self->{text_color};
  }

sub background_alpha
  {
  my $self = shift;

  $self->{background_alpha} = shift if @_ > 0;
  $self->{background_alpha};
  }

sub text_alpha
  {
  my $self = shift;

  $self->{text_alpha} = shift if @_ > 0;
  $self->{text_alpha};
  }

sub width
  {
  my $self = shift;

  $self->{width} = abs(shift) if @_ > 0;
  $self->{width};
  }

sub height
  {
  my $self = shift;

  $self->{height} = abs(shift) if @_ > 0;
  $self->{height};
  }

sub speed
  {
  my $self = shift;

  $self->{speed} = abs(shift) if @_ > 0;
  $self->{speed};
  }

1;

__END__

=pod

=head1 NAME

Games::Console - provide a 2D quake style in-game console

=head1 SYNOPSIS

	use Games::Console;

	my $console = Games::Console->new(
	  font => $font_object,
	  background_color => [ 1,1,0],
	  background_alpha => 0.4,
	  text_color => [ 1,1,1 ],
	  text_alpha => 1,
          speed => 50,		# in percent per second
	  height => 50,		# fully opened, in percent of screen
	  width => 100,		# fully opened, in percent of screen
	);

	$console->toggle($current_time);
	$console->message('Hello there!', $loglevel);


=head1 EXPORTS

Exports nothing on default. 

=head1 DESCRIPTION

This package provides you with a quake-style console for your games. The
console can parse input, log to a logfile, and gather messages.

This package is just a base class, that does setup the rendering, but doesn't
actually render anything.

See Games::Console::SDL and Games::Console::OpenGL for subclasses that
implement the actual rendering to the screen via SDL and OpenGL, respectively.

=head1 METHODS

=over 2

=item new()

	my $console = Games::Console->new( $args );

Create a new console. Typically, you have only one.

C<$args> is a hash ref containing the following keys:

	logfile			where to log messages
	loglevel		the log level (e.g. what to log)
	text_color		color of output text as array ref [r,g,b]
	text_alpha		blend font over background for semitransparent
	background_color	color of background as array ref [r,g,b]
	background_alpha	blend console background over screen background

=item render()

	$console->render ( $current_time );

If the console is currently visible, render it.

=item text_color()

        $rgb = $console->text_color();		# [$r,$g, $b ]
        $console->color(1,0.1,0.8);		# set RGB

Sets the color of the text output.

=item text_alpha()

        $a = $font->text_alpha();		# $a
        $font->color(0.8);		# set A
        $font->alpha(undef);		# set's it to 1.0 (seems an OpenGL
					# specific set because
					# glColor($r,$g,$b) also sets $a == 1

Sets the alpha value of the rendered output.

=item spacing_x()

	$x = $font->spacing_x();
	$font->spacing_x( $new_width );

Get/set the width of each character. Default is 10. This is costly, since it
needs to rebuild the font. See also L<spacing_y()> and L<spacing()>.

=back

=head1 KNOWN BUGS

None yet.

=head1 AUTHORS

(c) 2003 Tels <http://bloodgate.com/>

=head1 SEE ALSO

L<Games::3D>, L<SDL:App::FPS>, and L<SDL::OpenGL>.

=cut

