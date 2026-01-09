# QMEE

bio708

<html>

This is data from my artificial selection experiment. Each group (each row) completes a light-avoidance assay (light maze). After a period of time, the flies' distribution across 16 vials is represented in 16 columns. A weighted average is referred to as their "lightscore".

A key hypothesis is that light-avoidance is heritable, in other words, the lightscores in the selection group should decrease over generation and the lightscores in the control group should not change over generations.

<br>

The raw data comprises 23 generations of data. Each row contains the following information from left to right:

<ul>

-   Generation (numeric generation from 1 - 23)
-   time of day (string, morn or aft)
-   day (numeric, 1 - 4; which day of the experimental week was the data collected)
-   Maze_Order (string, the physical location of each maze relative to the testing room)
-   Treatment (string, C or S)
-   Lineage (string, 1 - 4; each independent population of fruit flies has a unique identifier S1-4, C1-4)
-   Maze (string, A B C or D; which light maze was this group tested in)
-   Sex (string, M or F)
-   columns labelled 1-16 are vials
-   Lightscore (double; a weighted average of the previous 16 columns)
-   flies_in (numeric; number of flies that started the maze)
-   flies_out (numeric; number of flies that completed the maze in the alloted time)
-   start_time_num (double; time that the trial began represented as a base 10 number)
-   end_time_num (double; time that the trial ended represented as a base 10 number)
-   time_elapsed_num (double; end_time_num - start_time_num)
-   prop_out (double; flies_in / flies_out)

</ul>

</html>
