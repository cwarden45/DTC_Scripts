### Order to Run Scripts ###

1) cluster_fastQC.py

2) cluster_BWA_alignment.py

3) coverage_statistics.py

4) GATK_variant_calls.py or VarScan_variant_calls.py

5) filter_variants.py

6) annotate_variants.py

7) variant_summary.R


### Dependencies (some optional) ###

Most Python scripts can be run using this [Docker image](https://hub.docker.com/r/cwarden45/dnaseq-dependencies/)

*Alignment*

BWA: http://bio-bwa.sourceforge.net/bwa.shtml

*QC-Statistics / Pre-Processing*

FastQC: http://www.bioinformatics.babraham.ac.uk/projects/fastqc/

Picard: https://broadinstitute.github.io/picard/

Agilent SureSelect Targets (Registration Requried): https://earray.chem.agilent.com/suredesign/

*Variant Calling*

GATK: https://software.broadinstitute.org/gatk/

VarScan: http://varscan.sourceforge.net/

*Variant Annotation*

ANNOVAR: http://annovar.openbioinformatics.org/en/latest/

### Parameter Values ###
| Parameter | Value|
|---|---|
|Result_Folder|Path to output folder for selected, final results|
|Alignment_Folder|Path to Alignment Folder|
|Reads_Folder|Path to Read Folder|
|Cluster_Email|If running alignment on a cluster, e-mail for notifications|
|genome|Name of genome build|
|MEM_Limit|Memory allocated to java or job on cluster|
|BWA_Ref| Path to BWA ref|
|Threads|Number of Threads for BWA-MEM Alignment|
|target_regions|Path to target regions file|
|PE_Reads|Are you using paired-end reads?  Can be 'yes' (typical for Illumina data) or 'no'|
