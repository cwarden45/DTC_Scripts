Please see this [blog post](http://cdwscience.blogspot.com/2012/06/my-23andme-results-getting-free-second.html) to learn more about the Perl scripts

**Perl Script Notes**
- hg19 is no longer the latest reference sequence, but it is what was used for my WGS sample and you can get hg19 annotationsfrom SeattleSeq here: http://snp.gs.washington.edu/SeattleSeqAnnotation138/
- SeattleSNP didn't recognize some alleles from 23andMe (mostly deletions)

**New Scripts**
- **23andMe_to_VCF.py** - converts 23andMe raw format to VCF (`python 23andMe_to_VCF.py --input=[23andMe file]`, if you've run the Vertias WGS scripts.  Type `python 23andMe_to_VCF.py --help` for more information)

⋅You'll want to check the 23andMe data portal for variants with "D" or "I" annotations.  Sometimes, your actual genotype is counter-intuitive.  So, unless you happen to have the same genotype as me, you'll probably have to modify the python code (and possibly add insertion sequences from [dbSNP](http://www.ncbi.nlm.nih.gov/snp)).  Sorry about that.
