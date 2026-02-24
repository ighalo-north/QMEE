# BIO 708: Quant. Methods in Ecol + Evol

***Keren Ighalo 2026***

Abstract

Many animals are attracted to artificial light at night, which is a major cause of injury and death. Given the negative fitness consequences of light-attraction, natural selection should have favoured the evolution of light avoidance, but there is no evidence that this has occurred. To resolve this conundrum, we suggested that there is a genetic link between light-attraction and some unknown trait with positive effects of fitness. We thus predicted that animals possessing light avoidance would incur some fitness costs. To test this prediction, we artificially selected replicated lineages of light-avoiding fruit flies and assessed their performance in a battery of fitness-related tests. Here, we posited that there is a major genetic factor simultaneously constraining the evolution of light-avoidance or light-neutrality and maintaining the presence of light-attraction in animal populations. To test this hypothesis, we used artificial selection to generate a population of fruit flies Drosophila melanogaster that is light-avoidant and assessed their performance in a battery of fitness-related tests.

***Mini-Description***

Data from my artificial selection experiment. Each group (row) completes a light-avoidance assay (light maze). After a period of time, the flies' distribution across 16 vials is represented in 16 columns.

A key hypothesis is that light-avoidance is heritable, in other words, the lightscores in the selection group should decrease over generation.

### **Artificial Selection (Light Maze) Data**

File `raw_alan_gen25.xlsx` comprises 25 generations of data. Each row contains the following information from left to right:

-   Generation (numeric generation from 1 - 23)
-   time of day (string, morn or aft)
-   day (numeric, 1 - 4; which day of the experimental week was the data collected)
-   Maze_Order (string, the physical location of each maze relative to the testing room)
-   Treatment (string, C or S)
-   Lineage (string, 1 - 4; each independent population of fruit flies has a unique identifier S1-4, C1-4)
-   Maze (string, A B C or D; which light maze was this group tested in)
-   Light_Side (string, left or right)
-   Sex (string, M or F)
-   columns labelled 1-16 are vials
-   Lightscore (double; a weighted average of the previous 16 columns)
-   flies_in (numeric; number of flies that started the maze)
-   flies_out (numeric; number of flies that completed the maze in the allotted time)
-   start_time_num (double; time that the trial began represented as a base 10 number)
-   end_time_num (double; time that the trial ended represented as a base 10 number)
-   time_elapsed_num (double; end_time_num - start_time_num)
-   prop_out (double; flies_in / flies_out)
-   blind (string; yes or no)

### **Main Scripts**

The **script `clean_raw_alan.R`** cleans the script `raw_alan_gen24` and **generates a clean rds file: `clean_alan_gen25.rds`** in the main directory. This `.rds` file is required for several`.R` scripts.

### **Assignment Scripts**

The script `read_rds.R` reads the .rds file and plots two histograms. The script assignment1.R reads in the relevant data, runs two statistical analyses, and generates 5 plots. The script `assignment3.R` is for data visualization. The text file `assignment4_statphil.txt` discusses the statistical reporting in Zwaan, Bijlsma, & Hoekstra, 1995. The text file `assignment5.txt` describes my data and one or more of my research questions from the point of view of measurement theory. Script `assingment6.R` relates to linear models and has diagnostic, prediction, and inferential plots.
