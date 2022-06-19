## Steps for Analysis

**1)** `run_Kracken2_Bracken-FASTQ-PE.py`

This code has been applied elsewhere, such as [here](https://github.com/cwarden45/Bastu_Cat_Genome/tree/master/basepaws_Dental_Health_Test) and [here](https://github.com/cwarden45/PRJNA513845-eDNA_reanalysis/tree/master/metagenomics).

**2)** `create_Kracken2_Bracken_table.R`

 - Use Kraken report to summarize classification rate
 - Use Bracken report to create genus-level abundance percentages
 
 <table>
  <tbody>
    <tr>
      <th align="center">Sample</th>
      <th align="center">Kraken2 Bacterial Classification Rate</th>
    </tr>
    <tr>
      <td align="center">Psomagen1a</td>
      <td align="center">99.97%</td>
     </tr>
     <tr>
      <td align="center">Psomagen1b</td>
      <td align="center">61.88%</td>
     </tr>
     <tr>
      <td align="center">Psomagen2</td>
      <td align="center">57.21%</td>
     </tr>
	<tr>
      <td align="center">Psomagen3</td>
      <td align="center">58.75%</td>
     </tr>
	<tr>
      <td align="center">Psomagen4</td>
      <td align="center">55.04%</td>
     </tr>
	<tr>
      <td align="center">Kean5</td>
      <td align="center">99.98%</td>
     </tr>
 	<tr>
      <td align="center">Kean6a</td>
      <td align="center">99.98%</td>
     </tr>
 	<tr>
      <td align="center">Kean6b</td>
      <td align="center">53.81%</td>
     </tr>
	  <tr>
      <td align="center">thryve2</td>
      <td align="center">97.66%</td>
     </tr>
    <tr>
      <td align="center">thryve3a</td>
      <td align="center">98.15%</td>
     </tr>
    <tr>
      <td align="center">thryve3b</td>
      <td align="center">97.39%</td>
     </tr>
    <tr>
      <td align="center">thryve4</td>
      <td align="center">98.99%</td>
     </tr>
    <tr>
      <td align="center">Ombre5</td>
      <td align="center">97.89%</td>
     </tr>
    <tr>
      <td align="center">Ombre6</td>
      <td align="center">98.77%</td>
     </tr>
</tbody>
</table>

As explained by Kean technical support, the Psomagen1b and Ombre5 use V+V4 16 Amplicon-Seq data.  However, the other Psomagen samples use "shotgun" metagenomics.

That said, the classification rate is noticably lower in Psomagen saples when the 16S region is not targeted, even though this program is designed to work on data without target enrichment.  While both are high, the classification rate appears to be closer to 100% for the V3+V4 16S amplicon (Kean) versus the V4 16S amplicon (thyrve/Ombre).

![Bracken-Adjusted Percent Quantified Clustering](n14_Braken2_genera-heatmap_quantified.PNG "Bracken-Adjusted Percent Quantified Clustering")
