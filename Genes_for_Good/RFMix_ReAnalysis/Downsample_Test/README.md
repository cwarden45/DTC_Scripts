I previously tested the effect of down-sampling [my mom's X-chromosome](https://github.com/cwarden45/DTC_Scripts/blob/master/23andMe/Ancestry_plus_1000_Genomes/README.md), so I thought it would be good to do something similar with my entire genome with my Genes for Good dataset.

*10x Reduction in Reference Set (**133 Reference Samples**)*:

![10x-down ref](GFG_Ref-10x.png "10x-down ref")

*10x Reduction in Reference Set, 10x Reduction in Probes (**133 Reference Samples, 28,664 Probes**)*:

![10x-down ref 10x-down probe](GFG_Ref-10x_Probe-10x.png "10x-down ref, 10x-down probe")

I believe ~30,000 variants is in the ballpark used by [basepaws](https://github.com/cwarden45/Bastu_Cat_Genome/tree/master/Basepaws_Notes).

*10x Reduction in Reference Set, 18x Reduction in Probes (**133 Reference Samples, 15,924 Probes**)*:

![10x-down ref 18x-down probe](GFG_Ref-10x_Probe-18x.png "10x-down ref, 18x-down probe")

I choose this weird number to roughly match the number of [QC Array](https://www.illumina.com/products/by-type/microarray-kits/infinium-qc.html) probes.

As a sort of worst-case scenario, I went further:

*20x Reduction in Reference Set, 18x Reduction in Probes (**66 Reference Samples, 15,924 Probes**)*:

![20x-down ref 18x-down probe](GFG_Ref-20x_Probe-18x.png "20x-down ref, 18x-down probe")

While there are clearly large segments of inaccurate ancestry, all of the above plots would indicate that I am mostly European.  So, it could be a lot worse.

Now with that for perspective, I testing using the full reference set (of unrelated individuals) with reduced probes:

*18x Reduction in Probes (**1,329 Reference Samples, 15,924 Probes**)*:

![18x-down probe](GFG_Probe-18x.png "18x-down probe")

*10x Reduction in Probes (**1,329 Reference Samples, 28,664 Probes**)*:

![10x-down probe](GFG_Probe-10x.png "10x-down probe")

*5x Reduction in Probes (**1,329 Reference Samples, 57,328 Probes**)*:

![5x-down probe](GFG_Probe-5x.png "5x-down probe")

*2x Reduction in Probes (**1,329 Reference Samples, 143,320 Probes**)*:

![2x-down probe](GFG_Probe-2x.png "2x-down probe")

While this still isn't perfect, I think it looks roughtly like the full set of probes (and 23andMe results) [one level up](https://github.com/cwarden45/DTC_Scripts/blob/master/Genes_for_Good/RFMix_ReAnalysis/README.md).  So, whether the remaining (relatively) small results that are inconsistent are due to a limitation in the methods versus reference set is a little hard for me to say for certain.  However, with >10x down-sampling we could clearly see large segments of inaccurate assignments, which could clearly be improved by increasing probes (and reference samples).
