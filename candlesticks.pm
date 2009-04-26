#==========================================================================
#              Copyright (c) 2008 Paul Miller
#==========================================================================
 
package GD::Graph::candlesticks;

use strict;
use GD::Graph::mixed; # NOTE: we pull this in so we can modify part of it.
use GD::Graph::axestype;
use GD::Graph::utils qw(:all);
use GD::Graph::colour qw(:colours);

use constant PI => 4 * atan2(1,1);

our $VERSION = "0.9402";
our @ISA = qw(GD::Graph::axestype);

push @GD::Graph::mixed::ISA, __PACKAGE__;

# working off gdgraph/Graph/bars.pm (in addition to ohlc.pm)

# initialise {{{
sub initialise {
    my $self = shift;

    $self->SUPER::initialise;
    $self->set(correct_width => 1);
    $self->set(candle_stick_width => 5);
}
# }}}

# draw_data_set {{{
sub draw_data_set {
    my $self = shift;
    my $ds   = shift;

    my @values = $self->{_data}->y_values($ds) or
        return $self->_set_error("Impossible illegal data set: $ds", $self->{_data}->error);

    # Pick a colour
    my $dsci = $self->set_clr($self->pick_data_clr($ds));

    my $GX;
    my ($ox,$oy, $cx,$cy, $lx,$ly, $hx,$hy); # NOTE: all the x's are the same...
    for (my $i = 0; $i < @values; $i++) {
        my $value = $values[$i];
        next unless ref($value) eq "ARRAY" and @$value==4;
        my ($open, $high, $low, $close) = @$value;

        if (defined($self->{x_min_value}) && defined($self->{x_max_value})) {
            $GX = $self->{_data}->get_x($i);

            ($ox, $oy) = $self->val_to_pixel($GX, $value->[0], $ds);
            ($hx, $hy) = $self->val_to_pixel($GX, $value->[1], $ds);
            ($lx, $ly) = $self->val_to_pixel($GX, $value->[2], $ds);
            ($cx, $cy) = $self->val_to_pixel($GX, $value->[3], $ds);

        } else {
            ($ox, $oy) = $self->val_to_pixel($i+1, $value->[0], $ds);
            ($hx, $hy) = $self->val_to_pixel($i+1, $value->[1], $ds);
            ($lx, $ly) = $self->val_to_pixel($i+1, $value->[2], $ds);
            ($cx, $cy) = $self->val_to_pixel($i+1, $value->[3], $ds);
        }

        $self->candlesticks_marker($ox,$oy, $cx,$cy, $lx,$ly, $hx,$hy, $dsci );
        $self->{_hotspots}[$ds][$i] = ['rect', $self->candlesticks_marker_coordinates($ox,$oy, $cx,$cy, $lx,$ly, $hx,$hy)];
    }

    return $ds;
}
# }}}
# candlesticks_marker_coordinates {{{
sub candlesticks_marker_coordinates {
    my $self = shift;
    my ($ox,$oy, $cx,$cy, $lx,$ly, $hx,$hy) = @_;

    return ( $ox-2, $cx+2, $hy, $ly );
}
# }}}
# candlesticks_marker {{{
sub candlesticks_marker {
    my $self = shift;
    my ($ox,$oy, $cx,$cy, $lx,$ly, $hx,$hy, $mclr) = @_;
    return unless defined $mclr;

    $self->{graph}->line( ($lx,$ly) => ($hx,$hy), $mclr );

    my $mode = $cy>$oy ? "rectangle" : "filledRectangle";
    $self->{graph}->$mode( ($cx-2,$cy) => ($cx+2,$cy), $mclr );
}
# }}}

"this file is true";
