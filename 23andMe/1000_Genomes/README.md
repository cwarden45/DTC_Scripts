Input
-----------

I am parsing 1000 Genomes genotypes (from [ALL.chip.omni_broad_sanger_combined.20140818.snps.genotypes.vcf](ftp://ftp-trace.ncbi.nih.gov/1000genomes/ftp/release/20130502/supporting/hd_genotype_chip/ALL.chip.omni_broad_sanger_combined.20140818.snps.genotypes.vcf))

I am curious about frequencies within more specific populations, which I am calculating if there are **unrelated** or **1 child** individuals from the pedigree file.

I am using the 1000 Genomes [Super-Populations](http://www.internationalgenome.org/category/population/), as well as the populations from the pedigree file.  I prepared a very similar file for another project from the [Ogembo lab](https://www.cityofhope.org/people/ogembo-javier), so I also want to acknowledge that.

If I filter for populations represented with at least 20 such individual, this leaves me with the following counts:

Super-Populations Sample Size (Unrelated + 1 child):
AFR: 272

AMR: 135

EAS: 445

EUR: 364

SAS: 113

Specific Population Size (Unrelated + 1 child, if greater than 20):
ACB: 55
ASW: 43
CDX: 100
CHB: 108
CHS: 51
CLM: 35
FIN: 100
GBR: 101
GIH: 113
IBS: 50
JPT: 105
KHV: 80
LWK: 116
MXL: 30
PEL: 35
PUR: 35
TSI: 112
YRI: 58

I am also using a 23andMe file converted to a VCF file (see the main [23andMe section](https://github.com/cwarden45/DTC_Scripts/tree/master/23andMe))

Annotation
-----------

1) Reformat large 1000 Genomes genotype table into a frequency table using `calculate_vcf_frequencies.pl`

I have saved a compressed version such a file here (for the unrelated and 1 child individuals).

```diff
- However, I want to make clear this is something that I created relatively quickly for my own purposes, so this is not equilvlant to something coming from the 1000 Genomes project (which has been subject to many more questions and testing).
```

Accordingly, I am expecting other people to need to modify the code itself (towards the top of the file) to test application to their own sample.  This is because I 

2) Look for variants also present in your own .vcf file using `annotate_present_variants.pl`

I am parsing the 23andMe raw data file that I converted (with limitations such as only looking at SNPs, not indels, etc.).  This type of .vcf file has some repeat annotations (as well as sites that match the reference at both alleles), but I am only considering adding the 1000 Genomes annotations to those with a "PASS" status (without being annotated as coming from a repeat) and variants actually present in my .vcf file.

3) As of 2/3/2019, I noticed that 23andMe provides a way to download the intervals of the ancestry predictions as a CSV file.  So, if you have a specific region that you are trying to understand better, you can use the genome positions to filter specific SNPs to view.

Personal Thoughts
-----------------

One thing that I think may need to be made clear is that a surprising 23andMe ancestry result may <b><u>not</b></u> necessarily be more accurate than your prior expectations.  You should consider this result as one possible piece of evidence that you combine with other information to guide you through possible interpretations of your ancestry.

I have my "raw" 23andMe data available on the [Personal Genome Project website](https://my.pgp-hms.org/profile/hu832966), and I have also exported and uploaded one such report.

More specifically, these are some hypothesis where I don't think the 23andMe assignments were 100% precise:

1) I think my Scandinavian assignment (11%) should really be non-specific European

I believe 23andMe already provides some evidence to match this expectation:

a) **That prediction goes away if I shift from 50% confidence (the default) to 90% confidence**
b) The "Recall" for this population is also lower than some other people in the [ancestry documentation](https://www.23andme.com/ancestry-composition-guide/) on the 23andMe website

2) I am predicted to have 2.5% African (Sub-Saharan African, according to 23andMe).  While this might be correct, I wonder if there might be some Northern African / Southern European that might be mixed in there.  For example, I expect to see some Spanish and Italian ancestry that isn't showing up.

While this was a main goal of trying to check the more specific 1000 Genomes frequencies, I can't quite show this with that information.

However, the Genes4Good results did indicate "West Asian and North African Ancestry was often assigned to some portions of individuals who appear to actually have European ancestry and vice-versa", and the part of African also varies with my DNA.land predictions (being North African instead of Sub-Saharan African, so I can see some evidence that the part of Africa may indeed not be precise).  On the other hand, the [GENOtation](http://genotation.stanford.edu/) Hapmap2 chromosome painting seems more limited (just European and African), but chr9 and chr14 are painted with African ancestry.

If I export the 90% confidence predictions, these are the parts that are supposed to be of African Ancestry:

chr14:48431057-58215840
chr14:94843083-95672943

chr15:26636672-33061916
chr15:47723113-49749548

chr18:69836-5979832

chrX:2700157-9188835

So far, I see some indication of increasing African ancestry from other individuals on my father's side.  However, I know that the chrX prediction cannot represent that same ancestry from my paternal line (although, to be fair, 90% confidence allows for some inaccurate assignments).  Even if there is somehow psuedoautosomal-adjcent sequence carried over on my Y-chromosome, something about that segment wouldn't be precise.

Except for chrX, I highlighted the other segments that could be correct.  With the frequencies from this script, those don't seem highly likely high AFR frequency (not to mention low frequency in other super-populations); I realize it is more complicated than this (for example, variants with high frequencies in all populations aren't as informative), but I think there is something about this result worth considering.

So, I am still not 100% sure what I am actually looking at, but I am going to look into this more (including assesssing predictions of African ancestry from my mother).

3) I have a prediction of 0.1% "East Asian and Native American" that I think may be some sort of artifict.

At least when I was testing some ADMIXTURE assignments, there were usually non-zero values assigned to each category (where I would interpret low percentages as being less accurate).  Unfortuantely, I don't have a more precise explanation for this hypothesis at this time.

**However, at least currently, this 23andMe ancestry assignment also goes away if I change the confidence from 50% (the default) to 90%.**
