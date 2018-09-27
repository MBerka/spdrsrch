#!/usr/bin/perl
use strict;

delete @ENV{qw(IFS CDPATH ENV BASH_ENV)};   # Make %ENV safer
$ENV{'PATH'} = '/bin:/usr/bin:/usr/local/bin:/usr/local/apache/bin/';

use lib ".";
use CGI::Carp qw(fatalsToBrowser);
use spdrUtils;

my %arguments = arguments( 1 );
my ($initfind, $initreplace, $initdirs, $initprereq, $dirname) = '';
my @dirs = ();
my @multpre = ();

decode_chars( $initfind = $arguments{ 'findtext' } );
decode_chars( $initreplace = $arguments{ 'replacetext' } );
decode_chars( $initdirs = $arguments{ 'directories' } );
decode_chars( $initprereq = $arguments{ 'prereqtext' } );

my $rootChoice = $arguments{ 'root' };
my $action = $arguments{ 'action' };
my $prereq = $arguments{ 'prereq' };
my $seek = $arguments{ 'seek' };
my $format = $arguments{ 'format' };

if($format eq "."){
	$format = "[a-zA-Z]";
}

my @multfind = split(/SPLIT/, $initfind);
my @multrep = split(/SPLIT/, $initreplace);

if(length($initdirs)>1){
	@dirs = split(/SPLIT/, $initdirs);
}else{
	@dirs = ("list/", "/of/", "/folders/and/subfolders/");
}

foreach my $dircount (0 .. $#dirs){
	if(substr($dirs[$dircount], 0, 1) ne "/"){
		$dirs[$dircount] = "/$dirs[$dircount]";
	}
	if(substr($dirs[$dircount], -1, 1) ne "/"){
		if(!($dirs[$dircount] =~ /\./)){
			$dirs[$dircount] .= "/";
		}
	}
}

if($prereq ne "none"){
	@multpre = split(/SPLIT/, $initprereq);
}

my $document_root = $ENV{'DOCUMENT_ROOT'};
if($rootChoice eq "server"){
	$document_root = "/home/user";
}

print "Content-type: text/html\n\n";
print "<html><head><title>SPDR SRCH</title></head><body>\n";

print "<h1>";
if($action eq "revert"){
	print "Reverting";
}elsif($action eq "custom"){
	print "Replacing: <br>\n";
	foreach my $idx (0 .. $#multfind){
		print "$multfind[$idx] with $multrep[$idx]<br>\n";
	}
}else{
	print "Searching for: <br>\n";
	foreach my $idx (0 .. $#multfind){
		print "$multfind[$idx]<br>\n";
	}
}
print "</h1>\n";

my @files = ();
my $file_count = 0;
DLOOP: foreach $dirname (@dirs){
#print "$document_root$dirname<br/>";
	if(my $checker=($dirname =~ /\./)){
		@files = ("$document_root$dirname");
	}else{
		#my $dirpath = "$document_root$dirname";
		@files = <$document_root$dirname*>;
	}
	FLOOP: foreach my $file(@files){
		my @pieces = split(/\./, $file);
		#print "@pieces<br>\n";
		if($pieces[1] eq "" && $seek eq "spider" && $dirname ne "/"){
			my $check_dir = "$pieces[0]/";
			my @check_for_files = <$check_dir*>;
			if(@check_for_files){
				$check_dir =~ s/$document_root//;
				push(@dirs, $check_dir);
			}
			
		}
		next FLOOP if $pieces[1] !~ /$format/;
		if(!open(SOURCE, "< $file")){
			print "Cannot open $file<br/>";
			next FLOOP;
		}
#print "Opened $file<br/>";
		my $string = join("", <SOURCE>);
		close SOURCE;
		$file_count++;
		foreach my $precount (0 .. $#multpre){
			if($prereq eq "include"){
				next FLOOP if $string !~ /$multpre[$precount]/;
			}else{
				next FLOOP if $string =~ /$multpre[$precount]/;
			}
		}
		my $counter = '';
		if($action eq "revert"){
			rename "$pieces[0].$pieces[1]", "$pieces[0].err";
			rename "$pieces[0].prev", "$pieces[0].$pieces[1]";
			rename "$pieces[0].err", "$pieces[0].prev";
		}elsif($action eq "custom"){
			foreach my $idx (0 .. $#multfind){
				if(my $checker=($string =~ s/$multfind[$idx]/$multrep[$idx]/g)){
					$counter = "$counter, $idx";
				}
			}
			if($counter ne ''){
				rename $file, "$pieces[0].prev";
				open(DESTIN, "> $file") or die "cannot open $file: $!";
				print DESTIN $string;
				close DESTIN;
				$file =~ s/$document_root//;
				print "$file$counter<br>\n"
			}
		}else{
			foreach my $idx (0 .. $#multfind)
			{
				if(my $checker=($string =~ /$multfind[$idx]/)){
					$counter = "$counter, $idx";
				}
			}
			if($counter ne ''){
				$file =~ s/$document_root//;
				print "$file$counter<br>\n"
			}
		}#close action selector
	}#close file looping
}#close directory looping
print "<h1>Finished!</h1>\n";
print "Searched $file_count files in:";
foreach $dirname (@dirs){
	print "<br>$dirname\n";
}
print "</body></html>";
