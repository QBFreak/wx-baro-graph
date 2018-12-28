#!/usr/bin/perl
use strict;
use DateTime::Format::DateParse;
use File::Slurp;
use Geo::METAR;
use POSIX qw(strftime);
use GD::Graph::linespoints;

use GD::Graph::colour;

my $line_color = "#00FF00";
my $bg_color = "#000000";
my $fg_color = "#00DD00";

my $baseurl = "http://tgftp.nws.noaa.gov/data/observations/metar/cycles";
my $icao = "";

$icao = $ARGV[0];
if ($icao eq "") {
    $icao = "KEQY";
}

my $pad = 0.02;

my %files; # hash of {filename}=modifiedtime
for (my $i = 0; $i < 24; $i++) {
	# Determine the file name: nnZ.TXT
	my $file = sprintf('%02dZ.TXT', $i);
    # Add the file to the list
	$files{$file} = (stat($file))[9];
}

# Run through the files in order by modified time,
#  find the records for the desired station,
#  and stick them in a hash
my %observations;
foreach my $name (sort { $files{$a} <=> $files{$b} } keys %files) {
	my $contents = read_file($name);
	my @matches = ($contents =~ /(?:^|\n)($icao [^\n]+)/g);
	foreach my $match (@matches) {
		my $m = new Geo::METAR;
		$m->metar($match);
		my $dt = DateTime::Format::DateParse->parse_datetime(strftime("%Y-%m-", gmtime($files{$name})) . $m->DATE . " " . $m->TIME);
		$observations{$dt->epoch} = $m->ALT;
	}
}

my @points;
my @values;
my $minobs = 500;
my $maxobs = 0;
foreach my $observation (sort keys %observations) {
	#print($observations{$observation} . " observed at $observation\n");
	my $dt = DateTime->from_epoch( epoch => $observation, time_zone => 'UTC' );
	$dt->set_time_zone('America/New_York');
	my $obtime = $dt->hour_1 + $dt->minute / 60;
	push @points, $dt->hour_1();
	push @values, $observations{$observation};
	if ($minobs > $observations{$observation}) {
		$minobs = $observations{$observation};
	}
	if ($maxobs < $observations{$observation}) {
		$maxobs = $observations{$observation};
	}
	#print($observations{$observation} . " observed at " . $obtime . "\n");
}

my @data;
push @data, \@points, \@values;
my $my_graph = new GD::Graph::linespoints( );
$my_graph->set(
	title => 'Barometric Pressure History',
	x_label	=> 'Hourly Readings',
	y_label => 'Inches',
	y_min_value => ($minobs - $pad),
	y_max_value => ($maxobs + $pad),
	transparent => 0,
	dclrs => [ $line_color ],
	bgclr => $bg_color,
	fgclr => $fg_color,
	labelclr => $fg_color,
	axislabelclr => $fg_color,
	borderclrs => $fg_color,
	legendclr => $fg_color,
	textclr => $fg_color,
);
$my_graph->set_legend( 'Barometric Pressure' );
my $gd = $my_graph->plot(\@data);
write_file( "$icao.png", $gd->png() );

exit;

