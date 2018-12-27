#!/usr/bin/perl
use strict;
use LWP::UserAgent;
use File::Touch;
use DateTime::Format::DateParse;
use File::Slurp;
use Geo::METAR;
use POSIX qw(strftime);

my $baseurl = "http://tgftp.nws.noaa.gov/data/observations/metar/cycles";
my $icao = "KEQY";

my $pad = 0.02;

my %files; # hash of {filename}=modifiedtime
for (my $i = 0; $i < 24; $i++) {
	# Determine the file name: nnZ.TXT
	my $file = sprintf('%02dZ.TXT', $i);
	print("$file ");
	# Download the file
	if (time > ((stat($file))[9] + 24 * 60 * 60)) {
		print("downloading...");
		getFile("$baseurl/$file", $file);
		print("done.\n");
		# Read the first line, it contains the timestamp of the reading for the first location in the file
		open F, $file or die "$! $file";
		my $line = <F>;
		close F;
		# Clean it up and add a timezone (UTC)
		$line =~ s/\n$//;
		$line = "$line +0000";
		# Parse it into a DateTime object and change the timezone
		my $dt = DateTime::Format::DateParse->parse_datetime($line);
		$dt->set_time_zone('America/New_York');
		# Update the modified time on the file to match
		my $touch_obj = File::Touch->new( mtime => $dt->epoch );
		my $count = $touch_obj->touch($file);
		$files{$file} = $dt->epoch;
	} else {
		$files{$file} = (stat($file))[9];
		print("OK\n");
	}
}

sub getFile() {
	my ($url, $fname) = @_;
	# Download the file
	my $ua = LWP::UserAgent->new;
	my $req = HTTP::Request->new(GET => "$url");
	my $r = $ua->request($req)->content;
	# Write it
	write_file($fname, $r);
}
