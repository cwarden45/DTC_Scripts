**NOTE:** The down-sampled file size for *Psomagen1a* was different because the read length was different (larger 16S fragment), so that sample was not considered for downstream analysis)

Otherwise, the input files can be downloaded from the following locations:

<table>
  <tbody>
    <tr>
      <th align="center">Sample</th>
      <th align="center">R1</th>
      <th align="center">R2</th>
    </tr>
    <tr>
      <td align="center">Psomagen1a</td>
      <td align="center"><a href="https://storage.googleapis.com/cdw-metagenomics/CDW_16S_2021/Psomagen1a_R1.fastq.gz">R1</a></td>
      <td align="center"><a href="https://storage.googleapis.com/cdw-metagenomics/CDW_16S_2021/Psomagen1a_R1.fastq.gz">R2</a></td>
     </tr>
    <tr>
      <td align="center">Psomagen1b</td>
      <td align="center"><a href="https://storage.googleapis.com/cdw-metagenomics/CDW_16S_2021/Psomagen1b_R1.fastq.gz">R1</a></td>
      <td align="center"><a href="https://storage.googleapis.com/cdw-metagenomics/CDW_16S_2021/Psomagen1b_R2.fastq.gz">R2</a></td>
     </tr>
     <tr>
      <td align="center">Psomagen2</td>
      <td align="center"><a href="https://storage.googleapis.com/cdw-metagenomics/CDW_16S_2021/Psomagen2_R1.fastq.gz">R1</a></td>
      <td align="center"><a href="https://storage.googleapis.com/cdw-metagenomics/CDW_16S_2021/Psomagen2_R2.fastq.gz">R2</a></td>
     </tr>
	<tr>
      <td align="center">Psomagen3</td>
      <td align="center"><a href="https://storage.googleapis.com/cdw-metagenomics/CDW_16S_2021/Psomagen3_R1.fastq.gz">R1</a></td>
      <td align="center"><a href="https://storage.googleapis.com/cdw-metagenomics/CDW_16S_2021/Psomagen3_R2.fastq.gz">R2</a></td>
     </tr>
	<tr>
      <td align="center">Psomagen4</td>
      <td align="center"><a href="https://storage.googleapis.com/cdw-metagenomics/CDW_16S_2021/Psomagen4_R1.fastq.gz">R1</a></td>
      <td align="center"><a href="https://storage.googleapis.com/cdw-metagenomics/CDW_16S_2021/Psomagen4_R2.fastq.gz">R2</a></td>
     </tr>
	<tr>
      <td align="center">Kean5<br>(Psomagen is now <a href="https://www.keanhealth.com/">Kean</a>)</td>
      <td align="center"><a href="https://storage.googleapis.com/cdw-metagenomics/CDW_16S_2021/Kean5_R1.fastq.gz">R1</a></td>
      <td align="center"><a href="https://storage.googleapis.com/cdw-metagenomics/CDW_16S_2021/Kean5_R2.fastq.gz">R2</a></td>
     </tr>
	  <tr>
      <td align="center">thryve2</td>
      <td align="center"><a href="https://storage.googleapis.com/cdw-metagenomics/CDW_16S_2021/thryve2_R1.fastq.gz">R1</a></td>
      <td align="center"><a href="https://storage.googleapis.com/cdw-metagenomics/CDW_16S_2021/thryve2_R2.fastq.gz">R2</a></td>
     </tr>
    <tr>
      <td align="center">thryve3a</td>
      <td align="center"><a href="https://storage.googleapis.com/cdw-metagenomics/CDW_16S_2021/thryve3a_R1.fastq.gz">R1</a></td>
      <td align="center"><a href="https://storage.googleapis.com/cdw-metagenomics/CDW_16S_2021/thryve3a_R2.fastq.gz">R2</a></td>
     </tr>
    <tr>
      <td align="center">thryve3b</td>
      <td align="center"><a href="https://storage.googleapis.com/cdw-metagenomics/CDW_16S_2021/thryve3b_R1.fastq.gz">R1</a></td>
      <td align="center"><a href="https://storage.googleapis.com/cdw-metagenomics/CDW_16S_2021/thryve3b_R2.fastq.gz">R2</a></td>
     </tr>
    <tr>
      <td align="center">thryve4</td>
      <td align="center"><a href="https://storage.googleapis.com/cdw-metagenomics/CDW_16S_2021/thryve4_R1.fastq.gz">R1</a></td>
      <td align="center"><a href="https://storage.googleapis.com/cdw-metagenomics/CDW_16S_2021/thryve4_R2.fastq.gz">R2</a></td>
     </tr>
    <tr>
      <td align="center">Ombre5<br>(thryve is now <a href="https://www.ombrelab.com/">Ombre</a>)</td>
      <td align="center"><a href="https://storage.googleapis.com/cdw-metagenomics/CDW_16S_2021/Ombre5_R1.fastq.gz">R1</a></td>
      <td align="center"><a href="https://storage.googleapis.com/cdw-metagenomics/CDW_16S_2021/Ombre5_R2.fastq.gz">R2</a></td>
     </tr>
</tbody>
</table>

## mothur analysis

**1)** Run mothur seperately for each amplicon size:

- Execute `16S_2021-SILVA-FULL-PE150.batch` using `run_mothur-FULL-PE150.sh`
- Execute `16S_2021-SILVA-FULL-PE300.batch` using `run_mothur-FULL-PE300.sh`

You might need to run commands ***after*** *make.contigs()* separately, which is why certain lines are commented out (and the comments lines should be swapped when the command is run for a second time).

For samples 1-4, there was only 1 sample of a differnet fragment size and only PE150 samples were tested.  In that scenarios, you could run `16S_2021-RDP.batch` +`run_mothur-downsample.sh`, `16S_2021-SILVA.batch` + `run_mothur-downsample.sh`, or `16S_2021-SILVA-FULL.batch` + `run_mothur-FULL.sh`.You could also change the classifier setting within `run_mothur-downsample.sh` or `run_mothur-FULL.sh` (to be 80% confidence or 50% confidence, for example).  However, after realizing that the Kean Gut+ sample was more like the Psomagen GutBiome+ sample (and the Kean Gut sample was not like something that I believe was previously available to purchase separately, I revised the scripts to be able to process different fragment sizes separately and then combine the results).

The alignment file became very large with the full set of reads and it was not currently being used with downstream analysis.  So, there are 2 fewer lines in the batch file for the reads that are not down-sampled.

**2)** Illustrate sample clustering using `mothur_genera_clustering-combined.R`.  This is based upon commands that I most commonly used for generating heatmaps for RNA-Seq analysis (such as [DEG_goseq.R](https://github.com/cwarden45/RNAseq_templates/blob/master/TopHat_Workflow/DEG_goseq.R)).  When the code was only intended to be used for PE300 samples, the command used was `mothur_genera_clustering.R`.

This uses [heatmap.3.R](https://github.com/obigriffith/biostar-tutorials/blob/master/Heatmaps/heatmap.3.R) as a dependency.

If you follow the procedure to remove sequences that don't start and stop at the most common positions, all of the Psomagen sequences are removed.

If the target regions are different, then that can add complications.  However, as a rough guess for similar genera-level assignments, I tried to make use of the classifications between both samples.

For example, as a starting point, it looks like a lot more Psomagen sequences are being filtered prior to analysis.  I can look into this more, but that is why I have created 2 sets of plots (percentages by starting total and percentages by quantified total)

### Total Read Counts (RDP, 80% confidence)

<table>
  <tbody>
    <tr>
      <th align="center">Sample</th>
      <th align="center">Starting Reads</th>
      <th align="center">mothur Returned</th>
      <th align="center">Total for<br>Percent Classified</th>
    </tr>
    <tr>
      <td align="center">Psomagen1b</td>
      <td align="center">40,000</td>
      <td align="center">21,317</td>
      <td align="center">31</td>
     </tr>
    <tr>
      <td align="center">Psomagen2</td>
      <td align="center">40,000</td>
      <td align="center">17,825</td>
      <td align="center">24</td>
     </tr>
    <tr>
      <td align="center">Psomagen3</td>
      <td align="center">40,000</td>
      <td align="center">17,341</td>
      <td align="center">27</td>
     </tr>
    <tr>
      <td align="center">thryve2</td>
      <td align="center">40,000</td>
      <td align="center">36,170</td>
      <td align="center">35,914</td>
     </tr>
    <tr>
      <td align="center">thryve3a</td>
      <td align="center">40,000</td>
      <td align="center">29,715</td>
      <td align="center">29,482</td>
     </tr>
    <tr>
      <td align="center">thryve3b</td>
      <td align="center">40,000</td>
      <td align="center">29,212</td>
      <td align="center">28,948</td>
     </tr>
    <tr>
      <td align="center">thryve4</td>
      <td align="center">40,000</td>
      <td align="center">36,428</td>
      <td align="center">35,133</td>
     </tr>
</tbody>
</table>

### Total Read Counts (SILVA, seed, 80% confidence)

<table>
  <tbody>
    <tr>
      <th align="center">Sample</th>
      <th align="center">Starting Reads</th>
      <th align="center">mothur Returned</th>
      <th align="center">Total for<br>Percent Classified</th>
    </tr>
    <tr>
      <td align="center">Psomagen1b</td>
      <td align="center">40,000</td>
      <td align="center">21,317</td>
      <td align="center">30</td>
     </tr>
    <tr>
      <td align="center">Psomagen2</td>
      <td align="center">40,000</td>
      <td align="center">17,825</td>
      <td align="center">23</td>
     </tr>
    <tr>
      <td align="center">Psomagen3</td>
      <td align="center">40,000</td>
      <td align="center">17,341</td>
      <td align="center">22</td>
     </tr>
    <tr>
      <td align="center">thryve2</td>
      <td align="center">40,000</td>
      <td align="center">36,170</td>
      <td align="center">35,752</td>
     </tr>
    <tr>
      <td align="center">thryve3a</td>
      <td align="center">40,000</td>
      <td align="center">29,715</td>
      <td align="center">29,353</td>
     </tr>
    <tr>
      <td align="center">thryve3b</td>
      <td align="center">40,000</td>
      <td align="center">29,212</td>
      <td align="center">28,826</td>
     </tr>
    <tr>
      <td align="center">thryve4</td>
      <td align="center">40,000</td>
      <td align="center">36,428</td>
      <td align="center">34,856</td>
     </tr>
</tbody>
</table>

### Total Read Counts (SILVA, full, 80% confidence)


<table>
  <tbody>
    <tr>
      <th align="center">Sample</th>
      <th align="center">Starting Reads</th>
      <th align="center">mothur Returned</th>
      <th align="center">Total for<br>Percent Classified</th>
    </tr>
    <tr>
      <td align="center">Psomagen1b</td>
      <td align="center">40,000</td>
      <td align="center">21,317</td>
      <td align="center">45</td>
     </tr>
    <tr>
      <td align="center">Psomagen2</td>
      <td align="center">40,000</td>
      <td align="center">17,825</td>
      <td align="center">40</td>
     </tr>
    <tr>
      <td align="center">Psomagen3</td>
      <td align="center">40,000</td>
      <td align="center">17,341</td>
      <td align="center">27</td>
     </tr>
    <tr>
      <td align="center">thryve2</td>
      <td align="center">40,000</td>
      <td align="center">36,170</td>
      <td align="center">35,903</td>
     </tr>
    <tr>
      <td align="center">thryve3a</td>
      <td align="center">40,000</td>
      <td align="center">29,715</td>
      <td align="center">29,428</td>
     </tr>
    <tr>
      <td align="center">thryve3b</td>
      <td align="center">40,000</td>
      <td align="center">29,212</td>
      <td align="center">28,913</td>
     </tr>
    <tr>
      <td align="center">thryve4</td>
      <td align="center">40,000</td>
      <td align="center">36,428</td>
      <td align="center">36,005</td>
     </tr>
</tbody>
</table>

### Total Read Counts (SILVA, full, 70% confidence)


<table>
  <tbody>
    <tr>
      <th align="center">Sample</th>
      <th align="center">Starting Reads</th>
      <th align="center">mothur Returned</th>
      <th align="center">Total for<br>Percent Classified</th>
    </tr>
    <tr>
      <td align="center">Psomagen1b</td>
      <td align="center">40,000</td>
      <td align="center">21,317</td>
      <td align="center">59</td>
     </tr>
    <tr>
      <td align="center">Psomagen2</td>
      <td align="center">40,000</td>
      <td align="center">17,825</td>
      <td align="center">54</td>
     </tr>
    <tr>
      <td align="center">Psomagen3</td>
      <td align="center">40,000</td>
      <td align="center">17,341</td>
      <td align="center">39</td>
     </tr>
    <tr>
      <td align="center">thryve2</td>
      <td align="center">40,000</td>
      <td align="center">36,170</td>
      <td align="center">35,866</td>
     </tr>
    <tr>
      <td align="center">thryve3a</td>
      <td align="center">40,000</td>
      <td align="center">29,715</td>
      <td align="center">29,430</td>
     </tr>
    <tr>
      <td align="center">thryve3b</td>
      <td align="center">40,000</td>
      <td align="center">29,212</td>
      <td align="center">28,894</td>
     </tr>
    <tr>
      <td align="center">thryve4</td>
      <td align="center">40,000</td>
      <td align="center">36,428</td>
      <td align="center">36,004</td>
     </tr>
</tbody>
</table>

### Total Read Counts (SILVA, full, 50% confidence)


<table>
  <tbody>
    <tr>
      <th align="center">Sample</th>
      <th align="center">Starting Reads</th>
      <th align="center">mothur Returned</th>
      <th align="center">Total for<br>Percent Classified</th>
    </tr>
    <tr>
      <td align="center">Psomagen1b</td>
      <td align="center">40,000</td>
      <td align="center">21,317</td>
      <td align="center">235</td>
     </tr>
    <tr>
      <td align="center">Psomagen2</td>
      <td align="center">40,000</td>
      <td align="center">17,825</td>
      <td align="center">187</td>
     </tr>
    <tr>
      <td align="center">Psomagen3</td>
      <td align="center">40,000</td>
      <td align="center">17,341</td>
      <td align="center">123</td>
     </tr>
    <tr>
      <td align="center">thryve2</td>
      <td align="center">40,000</td>
      <td align="center">36,170</td>
      <td align="center">35,772</td>
     </tr>
    <tr>
      <td align="center">thryve3a</td>
      <td align="center">40,000</td>
      <td align="center">29,715</td>
      <td align="center">29,368</td>
     </tr>
    <tr>
      <td align="center">thryve3b</td>
      <td align="center">40,000</td>
      <td align="center">29,212</td>
      <td align="center">28,851</td>
     </tr>
    <tr>
      <td align="center">thryve4</td>
      <td align="center">40,000</td>
      <td align="center">36,428</td>
      <td align="center">35,957</td>
     </tr>
</tbody>
</table>

### Percentage Classified Plots (SILVA, full, 80% confidence)

<table>
  <tbody>
    <tr>
      <th align="center">Sample</th>
      <th align="center">mothur Returned</th>
      <th align="center">Total for<br>Percent Classified</th>
    </tr>
    <tr>
      <td align="center">Psomagen1b</td>
      <td align="center">9,050,376</td>
      <td align="center">19,672</td>
     </tr>
    <tr>
      <td align="center">Psomagen2</td>
      <td align="center">7,014,774</td>
      <td align="center">14,146</td>
     </tr>
    <tr>
      <td align="center">Psomagen3</td>
      <td align="center">7,183,238</td>
      <td align="center">11,343</td>
     </tr>
    <tr>
      <td align="center">Psomagen4</td>
      <td align="center">7,761,896</td>
      <td align="center">19,314</td>
     </tr>
    <tr>
      <td align="center">Kean5</td>
      <td align="center">0</td>
      <td align="center">NA</td>
     </tr>
    <tr>
      <td align="center">thryve2</td>
      <td align="center">50,003</td>
      <td align="center">49,648</td>
     </tr>
    <tr>
      <td align="center">thryve3a</td>
      <td align="center">36,671</td>
      <td align="center">36,332</td>
     </tr>
    <tr>
      <td align="center">thryve3b</td>
      <td align="center">42,403</td>
      <td align="center">41,996</td>
     </tr>
    <tr>
      <td align="center">thryve4</td>
      <td align="center">38,138</td>
      <td align="center">37,701</td>
     </tr>
    <tr>
      <td align="center">Ombre5</td>
      <td align="center">35,786</td>
      <td align="center">35,537</td>
     </tr>
</tbody>
</table>

**^^^Re-run processing PE150 and PE300 separately.^^^**

As you can see above, Sample 4 clusters separately.  However, the other samples cluster more by company than collection date and there is a noticable difference in the genera-level percentages for some assignments (between companies).

Also, only a small fraction (<1%) of the Psomagen data is being used in the plot above.  The number of reads returned by Kean is considerably lower.  I am not sure if that relates to no eligable reads remaining for the plot above (for Kean).

### Percentage Classified Plots (SILVA, full, 80% confidence, PROCESS PE300 and PE150 SEPARATELY)

<table>
  <tbody>
    <tr>
      <th align="center">Sample</th>
      <th align="center">mothur Returned</th>
      <th align="center">Total for<br>Percent Classified</th>
    </tr>
    <tr>
      <td align="center">Psomagen1a</td>
      <td align="center"></td>
      <td align="center"></td>
     </tr>
    <tr>
      <td align="center">Psomagen1b</td>
      <td align="center"></td>
      <td align="center"></td>
     </tr>
    <tr>
      <td align="center">Psomagen2</td>
      <td align="center"></td>
      <td align="center"></td>
     </tr>
    <tr>
      <td align="center">Psomagen3</td>
      <td align="center"></td>
      <td align="center"></td>
     </tr>
    <tr>
      <td align="center">Psomagen4</td>
      <td align="center"></td>
      <td align="center"></td>
     </tr>
    <tr>
      <td align="center">Kean5</td>
      <td align="center"></td>
      <td align="center"></td>
     </tr>
    <tr>
      <td align="center">thryve2</td>
      <td align="center"></td>
      <td align="center"></td>
     </tr>
    <tr>
      <td align="center">thryve3a</td>
      <td align="center"></td>
      <td align="center"></td>
     </tr>
    <tr>
      <td align="center">thryve3b</td>
      <td align="center"></td>
      <td align="center"></td>
     </tr>
    <tr>
      <td align="center">thryve4</td>
      <td align="center"></td>
      <td align="center"></td>
     </tr>
    <tr>
      <td align="center">Ombre5</td>
      <td align="center"></td>
      <td align="center"></td>
     </tr>
</tbody>
</table>

![mothur Percent Quantified Clustering](n1_SILVA_filtered_genera-heatmap_quantified.PNG "mothur Percent Quantified Clustering")
