Personal Thoughts
-----------------

*My regional ancestry is mostly European*: 42% England / Wales / Northwestern Europe, 22% Germanic Europe, 21% Ireland & Scotland, 8% Norway, 3% Sweden, 2% Benin/Togo, 2% Ivory Coast / Ghana, and 1% European Jewish.

My maternal recent ancestry is from Arkanasas (near Memphis) and Tennessee, so the "Additional Community" result of "Northern Arkansas & Middle Tennessee Settlers" was interesting.

I also ordered the version of AncestryDNA that provides some trait information, and I filled out the questions for the "Personal Discoveries Project."  The Traits results are a little hard to view all at once, but I think providing the regional ancestry variation for each trait was interesting.

I uploaded my AncestryDNA data and reports to [my PGP page](https://my.pgp-hms.org/profile/hu832966), if anybody wants to look into those.

***So, overall, I think the relatively recent Arkanasas/Tennessee ancestry (and unique prediction of German ancestry) is interesting, but I think this would be more useful as a sort of free analysis for exported raw data.  I also found some additional family members that had AncestryDNA data but not 23andMe data, but I think recommending people deposit their data into public databases to search for family members would be preferable than having everybody purchase both 23andMe and AncestryDNA tests to search both sets of users for family members.  So, I wouldn't push too hard for people to have an additional test (and I'm not purchasing the additional Ancestry membership), but I think it provides some potentially interesting information (and I will probably check for revised results in the future).  For an extra $10, I think the extra traits were worth it (and I think a one-time cost of $10 may be acceptable instead of free in other circumstances).***

Raw Data File Conversion
-----------

I actually had an earlier [blog post](http://cdwscience.blogspot.com/2013/12/additional-analysis-of-ancestrydna-data.html) where I did some file conversion and analysis for somebody else.  So, that was one less thing that I had to write for my own data!

Just in case there have been some more recent chip changes, I created a new Venn Diagram with my own data, and (similar to my [Genes for Good](https://github.com/cwarden45/DTC_Scripts/tree/master/Genes_for_Good) data) I tested making HLA Predictions below.

[Genes for Good](https://github.com/cwarden45/DTC_Scripts/tree/master/Genes_for_Good) Code Analysis Results
-----------

### For Research Purposes Only! ###

![alt text](probe_name_overlap.png "SNP Chip Probe Name Overlap")

I had the V3 23andMe chip for my sample.  My AncestryDNA chip had 667,884 probes.  Above overlap is by name (not position).

<table>
  <tbody>
    <tr>
      <th align="center">Marker</th>
      <th align="center">SNP2HLA</th>
      <th align="center">HIBAG</th>
      <th align="center">bwakit</th>
      <th align="center">HLAminer</th>
    </tr>
    <tr>
      <td align="center">HLA-A</td>
      <td align="left">A*01, A*02<br/>(23andMe)<br/><br/>A*01, A*02<br/>(Genes for Good)<br/><br/>A*01, A*02<br/>(AncestryDNA)</td>
      <td align="left">A*01, A*02<br/>(23andMe)<br/><br/>A*01, A*02<br/>(AncestryDNA)</td>
      <td align="left">A*01, A*02<br/>(Genos Exome BWA-MEM)</td>
      <td align="left">A*01, A*02<br/>(Genos Exome BWA-MEM)<br/><br/>A*01, A*68<br/>(Genos Exome BWA)</td>
     </tr>
    <tr>
      <td align="center">HLA-B</td>
      <td align="left">B*08, B*40<br/>(23andMe)<br/><br/>B*08, B*40<br/>(Genes for Good)<br/><br/>B*08, B*40<br/>(AncestryDNA)</td>
      <td align="left">B*08, B*40<br/>(23andMe)<br/><br/>B*08, B*40<br/>(AncestryDNA)</td>
      <td align="left">B*08, B*40<br/>(Genos Exome BWA-MEM)</td>
      <td align="left">B*08, B*40<br/>(Genos Exome BWA-MEM)<br/><br/>B*08, B*41<br/>(Genos Exome BWA)</td>
     </tr>
    <tr>
      <td align="center">HLA-C</td>
      <td align="left">C*03, C*07<br/>(23andMe)<br/><br/>C*03, C*07<br/>(Genes for Good)<br/><br/>C*03, C*07<br/>(AncestryDNA)</td>
      <td align="left">C*03, C*07<br/>(23andMe)<br/><br/>C*03, C*07<br/>(AncestryDNA)</td>
      <td align="left">C*03, C*07<br/>(Genos Exome BWA-MEM)</td>
      <td align="left">C*03, C*07<br/>(Genos Exome BWA-MEM)<br/><br/>C*03, C*07<br/>(Genos Exome BWA)</td>
     </tr>
    <tr>
      <td align="center">HLA-DRB1</td>
      <td align="left">DRB1*01, DRB1*03<br/>(23andMe)<br/><br/>DRB1*01, DRB1*03<br/>(Genes for Good)<br/><br/>DRB1*01, DRB1*03<br/>(AncestryDNA)</td>
      <td align="left">DRB1*03, DRB1*11<br/>(23andMe)<br/><br/>DRB1*03, DRB1*15<br/>(AncestryDNA)</td>
      <td align="left">DRB1*04, DRB1*04<br/>(Genos Exome BWA-MEM)</td>
      <td align="left">DRB1*01, DRB1*15<br/>(Genos Exome BWA-MEM)<br/><br/>DRB1*01, DRB1*15<br/>(Genos Exome BWA)</td>
     </tr>
     <tr>
      <td align="center">HLA-DQA1</td>
      <td align="left">DQA1*05, DQA1*05<br/>(23andMe)<br/><br/>DQA1*01, DQA1*05<br/>(Genes for Good)<br/><br/>DQA1*01, DQA1*05<br/>(AncestryDNA)</td>
      <td align="left">DQA1*05, DQA1*05<br/>(23andMe)<br/><br/>DQA1*01, DQA1*05<br/>(AncestryDNA)</td>
      <td align="left">DQA1*03, DQA1*03<br/>(Genos Exome BWA-MEM)</td>
      <td align="left">DQA1*02, DQA1*03<br/>(Genos Exome BWA-MEM)<br/><br/>DQA1*02, DQA1*03<br/>(Genos Exome BWA)</td>
     </tr>
     <tr>
      <td align="center">HLA-DQB1</td>
      <td align="left">DQB1*02, DQB1*05<br/>(23andMe)<br/><br/>DQB1*02, DQB1*02<br/>(Genes for Good)<br/><br/>DQB1*02, DQB1*05<br/>(AncestryDNA)</td>
      <td align="left">DQB1*02, DQB1*03<br/>(23andMe)<br/><br/>DQB1*03, DQB1*06<br/>(AncestryDNA)</td>
      <td align="left">DQB1*03, DQB1*03<br/>(Genos Exome BWA-MEM)</td>
      <td align="left">DQB1*02, DQB1*03<br/>(Genos Exome BWA-MEM)<br/><br/>DQB1*02, DQB1*03<br/>(Genos Exome BWA)</td>
     </tr>
</tbody>
</table>
