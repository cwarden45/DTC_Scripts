Personal Thoughts
-----------------

***I got concordant results for my maternal line***:

*National Genographic 2.0*: L3 --> N --> R --> U --> U5 --> **U5B**

*23andMe*: L --> L3 --> N --> R --> U --> **U5b** --> U5b2a2


***With the help of some [Wikipedia mappings](https://en.wikipedia.org/wiki/Human_Y-chromosome_DNA_haplogroup), I also got concordant results for my paternal line***:

*National Genographic 2.0*: P305 --> M42 --> M168 --> M203 --> **M96** --> P147 (E1) --> P177 (E1b) --> P2 (E1b1) --> M215 ([E1b1b](https://www.eupedia.com/europe/Haplogroup_E1b1b_Y-DNA.shtml)) --> *M123* --> M34

*23andMe*: A --> DE-M145 --> **E-M96** --> *E-M123* --> E-L29

--> Essentially **Haplogroup E(M96)** on Wikipedia

My regional ancestry is mostly European: 72% Northwestern Europe, 19% Eastern Europe, 4% West Mediterranean, and 3% Western Africa.  Still not sure what to think about the 3% Western Africa, but I think the rest is an decent match for my expections (perhaps "West Mediterranean" captures some Spanish / Italian ancestry?)

Geno 2.0 reports my 1st reference population is Dutch and my second reference population is British.  The British makes sense.  I think the "Dutch" may really be "German" (and I think it should have been after British).

I am not sure what to think about the historical figure and Neanderthal results (but gut reaction is they should have less weight, but I haven't looked into it closely), but I can note that 23andMe says I have a common E-M34 ancestor with Napoleon Bonaparte (and Napoleon is not among the 12 "Genius Timeline" results from Geno 2.0).

I uploaded my Geno 2.0 data and reports to [my PGP page](https://my.pgp-hms.org/profile/hu832966), if anybody wants to look into those.

***So, overall, I learned more about the mitochondrial and Y-chromosome markers.  However, I wouldn't typically recommend this to other people who already have 23andMe genotyping (and I would recommend 23andMe over Geno 2.0 overall).***

Raw Data File Conversion
-----------

Raw data has chromosomes, but not genomic position.

So, I downloaded all hg19 dbSNP locations (from http://hgdownload.soe.ucsc.edu/goldenPath/hg19/database/snp138.txt.gz).

This is admittedly not the latest dbSNP (or reference), but my sample is from 2011 and this dbSNP file was a lot smaller.

In order to match Genes for Good code, I converted to 23andMe format (rather than creating a .vcf file) with `Geno2.0_to_23andMe_format.pl`.  Out of concerns about being able to support other people's use of these scripts, you need to modify the file (but, hopefully, you just have to change the variables towards the top of the script).  This mapping is only for markers with rsIDs, and it may take a little while (perhaps ~20 minutes?).

If you could convert all of the markers, there would be 200,180 positions covered by the Geno 2.0 array.  I mapped 80,744 positions by dbSNP ID, for the following analysis (all of which are also present on the 23andMe array).

I also had to sort by chromosomal order and position prior to plink file conversion, and remove non-canonical chromosomes.

Plink inferred my sex was female with this smaller set of markers.  I tried to do HLA typing with SNP2HLA and HIBAG (similar to [Genes for Good](https://github.com/cwarden45/DTC_Scripts/tree/master/Genes_for_Good)), but I got an error message that all relevant markers were already excluded.
