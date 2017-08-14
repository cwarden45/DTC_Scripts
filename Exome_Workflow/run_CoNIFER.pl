use warnings;
use strict;

#re-run with SV = 0, 1, and 2
#However, you only need to count RPKM the first time!
my $sv = 0;

#also download R script to run DNAcopy after CoNIFER
my $seg_mean_cutoff = 2;
my $Rfile = "run_DNAcopy_post_CoNIFER.R";

my $CoNIFER_path = "/opt/conifer-0.2.2/conifer.py";

my $parameter_file = "parameters.txt";
my $alignment_folder = "";
my $result_folder = "";
my $CoNIFER_bed = "";
my $sample_table = "";

open(PARAM, $parameter_file)||die("Cannot open $parameter_file\n");

my $line_count = 0;

while(<PARAM>){
	my $line = $_;
	chomp $line;
	$line =~ s/\r//g;
	$line =~ s/\n//g;
	
	$line_count++;
	
	if($line_count > 1){
		my @line_info = split("\t", $line);
		my $param = $line_info[0];
		my $value = $line_info[1];
		
		if($param eq "Alignment_Folder"){
			$alignment_folder=$value;
		}elsif($param eq "Result_Folder"){
			$result_folder=$value;
		}elsif($param eq "CoNIFER_BED"){
			$CoNIFER_bed=$value;
		}elsif($param eq "sample_description_file"){
			$sample_table=$value;
		}
		
	}#end if($line_count > 1)
}#end while(<PARAM>)

close(PARAM);

if(($alignment_folder eq "")||($alignment_folder eq "[[required]]")){
	die("Need to enter a value for 'Alignment_Folder'!\n");
}

if(($result_folder eq "")||($result_folder eq "[[required]]")){
	die("Need to enter a value for 'Result_Folder'!\n");
}

if(($CoNIFER_bed eq "")||($CoNIFER_bed eq "[[required]]")){
	die("Need to enter a value for 'CoNIFER_BED'!\n");
}

if(($sample_table eq "")||($sample_table eq "[[required]]")){
	die("Need to enter a value for 'sample_description_file'!\n");
}

my $CoNIFER_folder = "$result_folder/CoNIFER";
my $command = "mkdir $CoNIFER_folder";
system($command);

my $RPKM_folder = "$CoNIFER_folder/RPKM";
$command = "mkdir $RPKM_folder";
system($command);

RPKM_counts($alignment_folder, $CoNIFER_folder, $CoNIFER_bed, $CoNIFER_path, $RPKM_folder);
run_CoNIFER($CoNIFER_folder, $CoNIFER_bed, $CoNIFER_path, $sv, $RPKM_folder);
run_DNAcopy($CoNIFER_folder, $sv, $Rfile, $seg_mean_cutoff, $sample_table);

exit;
	
sub run_DNAcopy
	{
		my ($CoNIFER_folder, $sv, $Rfile, $seg_mean_cutoff, $sample_table)=@_;
		
		my %sample_hash;
		
		open(SAMPLE, $sample_table) || die("Could not open  $sample_table!");
		my $sample_line_count=0;
		my $sample_index = -1;
		my $label_index = -1;
		while(<SAMPLE>){
			my $line=$_;
			chomp $line;
			$line =~ s/\r//g;
			$line =~ s/\n//g;
			
			$sample_line_count++;
			
			my @line_info = split("\t",$line);
			
			if($sample_line_count == 1){
				for (my $i=0; $i < scalar(@line_info); $i++){
					if($line_info[$i] eq "sampleID"){
						$sample_index=$i;
					}elsif($line_info[$i] eq "userID"){
						$label_index=$i;
					}
				}#end for (my $i; $i < scalar(@line_info); $i++)
				
				if ($sample_index == -1){
					die "Did not find column index for 'sampleID'";
				}
				if ($label_index == -1){
					die "Did not find column index for 'userID'";
				}
			}else{
				$sample_hash{$line_info[$sample_index]}=$line_info[$label_index]
			}#end else
		}#end while(<SAMPLE>)
		close(SAMPLE);
		
		my $exported_folder = "$CoNIFER_folder/export_svdzrpkm_$sv";
		my $DNAcopy_folder = "$CoNIFER_folder/DNAcopy_sv$sv";
		mkdir($DNAcopy_folder);
		
		my $outputfile = "$CoNIFER_folder/DNAcopy_sv$sv"."_seg.mean$seg_mean_cutoff"."_results.txt";
		
		open(OUT, "> $outputfile") || die("Could not open  $outputfile!");
		print OUT "ID\tchrom\tloc.start\tloc.end\tnum.mark\tseg.mean\n";
		
		opendir DH, $exported_folder or die "Failed to open $exported_folder: $!";
		my @files = readdir(DH);
		foreach my $file (@files)
			{
				my $CoNIFER_file = "$exported_folder/$file";
				#print "$CoNIFER_file\n";
				if(-f ($CoNIFER_file) && ($file =~ /^\d/))
					{
						my ($sample) = ($file =~ /(.*).rpkm.bed$/);
						my $label = "";
						if(exists($sample_hash{$sample})){
							$label=$sample_hash{$sample};
						}else{
							die "Could not find label for |$sample|\n";
						}
						print "$sample --> $label\n";
						
						#run DNA copy
						my $DNAcopy_file = "$DNAcopy_folder/$sample.txt";
						my $command = "Rscript $Rfile $CoNIFER_file $label $DNAcopy_file";
						system($command);
						
						#parse results
						my $line_count =0;
						open(INPUTFILE, $DNAcopy_file) || die("Could not open $DNAcopy_file!");
						while (<INPUTFILE>)
							{
								my $line = $_;
								chomp $line;
								$line =~ s/\r//g;
								$line =~ s/\n//g;
								$line_count++;
								
								if($line_count > 1)
									{
										my @line_info = split("\t",$line);
										
										my $seg_mean = $line_info[5];
										
										if(abs($seg_mean) > $seg_mean_cutoff)
											{
												print OUT "$line\n";
											}#end if(abs($seg_mean) > $seg_mean_cutoff)
										
									}#end unless($line =~ /^#/)
							}#end while (<INPUTFILE>)
						close(INPUTFILE);	
					}#end if($folder =~ /Sample/)
			}#end foreach my $file (@files)
		closedir(DH);
		close(OUT);
	}#end run_DNAcopy

sub RPKM_counts
	{
		my ($inputfolder, $outputfolder, $CoNIFER_probe, $CoNIFER, $RPKM_folder)=@_;
		
		#Create RPKM files
		
		opendir DH, $inputfolder or die "Failed to open $inputfolder: $!";
		my @files = readdir(DH);
		foreach my $file (@files)
			{
				#print "$file\n";
				if(-f ("$inputfolder/$file") && ($file =~ /(^\d+_\S+).nodup.bam$/))
					{
						my ($sample) = ($file =~ /(^\d+_\S+).nodup.bam$/);
						print "$sample\n";
						my $bam_file = "$inputfolder/$file";
						
						#re-name .bam index
						my $new_index = "$bam_file.bai";
						if(!(-f($new_index))){
							my $prev_index = $bam_file;
							$prev_index =~ s/.bam$/.bai/;

							my $command = "mv $prev_index $new_index";
							system($command);
						}#end if(!(-f($new_index)))
						
						#create RPKM files
						my $RPKM_file = "$RPKM_folder/$sample.rpkm.txt";
						$command = "python $CoNIFER rpkm --probes $CoNIFER_probe --input $bam_file --output $RPKM_file";
						system($command);
					}#end if($folder =~ /Sample/)
			}#end foreach my $file (@files)
		closedir(DH);

	}#end RPKM_counts
	
sub run_CoNIFER
	{
		my ($outputfolder, $CoNIFER_probe, $CoNIFER, $sv, $RPKM_folder)=@_;
		
		my $hdf5_file = "$outputfolder/analysis_sv$sv.hdf5";
		my $singular_values = "$outputfolder/singular_values.txt";
		my $screeplot = "$outputfolder/screeplot.png";
		my $sd = "$outputfolder/sd_values.txt";
		
		#run CoNIFER
		my $command = "python $CoNIFER analyze --probes $CoNIFER_probe --rpkm_dir $RPKM_folder --output $hdf5_file --svd $sv --write_svals $singular_values --plot_scree $screeplot --write_sd $sd";
		system($command);
		
		#call CNVs
		my $calls = "$outputfolder/calls_sv$sv.txt";
		$command = "python $CoNIFER call --input $hdf5_file --output $calls";
		system($command);
				
		#export calls for DNAcopy
		my $svdrpkm_folder = "$CoNIFER_folder/export_svdzrpkm_$sv";
		mkdir($svdrpkm_folder);
		$command = "python $CoNIFER export --input $hdf5_file --output $svdrpkm_folder";
		system($command);
	}#end run_CoNIFER