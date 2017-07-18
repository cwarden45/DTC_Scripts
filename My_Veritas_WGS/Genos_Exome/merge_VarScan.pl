use warnings;
use strict;
use diagnostics;
use File::Basename;

my $prefix = "";

foreach my $arg (@ARGV)
	{
		if ($arg =~ /--prefix=/)
			{
				($prefix) = ($arg =~ /--prefix=(.*)/);
			}#end if ($arg =~ /--prefix=/)

			
		if ($arg =~ /--help/)
			{
				print "Usage: perl VCF_recovery.pl --prefix=[name]varscan.[snp/indel].vcf\n";
				print "--prefix : Prefix for separate SNP and indel files (and for newly created combined .vcf\n";
				exit;
			}#end if ($arg =~ /--output=/)
	}#end foreach my $arg (@ARGV)
	
my $snpVCF = "$prefix.varscan.snp.vcf";
my $indelVCF = "$prefix.varscan.indel.vcf";
my $combinedVCF = "$prefix.varscan.combined.vcf";

print "VarScan SNP: $snpVCF\n";
print "VarScan Indel: $indelVCF\n";
print "VarScan Combined: $combinedVCF\n";

my $command = "bgzip -c $snpVCF > $snpVCF.gz";
system($command);
$command = "/opt/bcftools/bcftools index $snpVCF.gz";
system($command);
$command = "bgzip -c $indelVCF > $indelVCF.gz";
system($command);
$command = "/opt/bcftools/bcftools index $indelVCF.gz";
system($command);
$command = "/opt/bcftools/bcftools concat -a $snpVCF.gz $indelVCF.gz > $combinedVCF";
system($command);