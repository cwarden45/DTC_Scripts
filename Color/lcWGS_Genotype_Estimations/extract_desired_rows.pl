use warnings;
use strict;
use Cwd 'abs_path'; 

$| =1;
	
my $inputfile = $ARGV[0];
my $row_file = $ARGV[1];
my $outputfile = $ARGV[2];

#create hash
print "...creating hash of lines to keep...\n";
my %line_hash;

open(INPUTFILE, $row_file) || die("Could not open $row_file!");
while (<INPUTFILE>)
	{
		my $line = $_;
		chomp $line;
		$line =~ s/\r//g;
		$line =~ s/\n//g;
		
		$line_hash{$line}=1;
	}#end while (<INPUTFILE>)
close(INPUTFILE);

print "Created hash with ",scalar(keys %line_hash), " lines to keep.\n";

#parse file to keep
print "...creating filtered file...\n";
open(OUTPUTFILE, ">$outputfile") || die("Could not open $outputfile!");

my $line_count=0;
open(INPUTFILE, $inputfile) || die("Could not open $inputfile!");
while (<INPUTFILE>)
	{
		my $line = $_;
		chomp $line;
		$line =~ s/\r//g;
		$line =~ s/\n//g;
		
		$line_count++;
		
		if(exists($line_hash{$line_count})){
			print OUTPUTFILE "$line\n";
		}#end if(exists($line_hash{$line_count}))
	}#end while (<INPUTFILE>)
close(INPUTFILE);

close(OUTPUTFILE);

exit;