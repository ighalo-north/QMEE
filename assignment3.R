#assignment 3:

#Construct some (i.e., more than one) ggplots using your data.
#Discuss:
  #what you are trying to show
  #some of the choices that you have made
  #the basis for these choices
    #(e.g., Cleveland hierarchy, proximity of comparisons, or other principles of graphical communication)

library(ggplot2); theme_set(theme_bw(base_size=15))
library(readxl)
library(tidyverse) #magrittr and ggplot2 are within tidyverse

alan <- read_excel("raw_alan_gen24.xlsx")
sapply(alan,class)


alan <- alan |> mutate(across(c(time_of_day, Maze, Maze_Order, Treatment, Lineage, Sex, blind), factor))
generations_total <- (tail(na.omit(alan$Generation, n = 1)))[1]
alan$TrtLin <- interaction(alan$Treatment, alan$Lineage, drop = TRUE, sep = "")

sumalan <- (alan |>
  group_by(Generation, TrtLin) %>%
  summarise(Lightscore = mean(Lightscore, na.rm=TRUE), prop_out = mean(prop_out, na.rm=TRUE))
)

#i want to show the difference in lightscore distribution between treatments
ggplot(alan, aes(x = Treatment, y = Lightscore)) +
  theme_bw() +
  geom_violin(fill = "darkgreen", adjust = 1/5) +
  labs(title="lightscore in control vs selection treatment")
#the comparison is directly between control and selection, so I put them on the same axis
  #proximity of comparisons


#i want to show the differences in proportion of flies exiting the maze between mazes
suppressWarnings(ggplot(alan, aes(x = Maze, y = prop_out)) +
  theme_bw() +
  geom_violin(fill = "blue", adjust = 1/3)) +
  labs(title = "mean proportion of flies out of each maze")
#the error here is okay, just due to empty rows
#I put the mazes on the same axis for readability 


#i want to show the proportion of flies completing the maze over generations
alan_sum <- (alan 
             |> summarise(across(c(Lightscore, prop_out),
                                 .fns = list(
                                   mean = ~ mean(.,na.rm=TRUE),
                                   se   = ~ sd(., na.rm = TRUE) / sqrt(sum(!is.na(.x))))),
                          .by = c(Generation, TrtLin, Sex)
             )
)

ggplot(
  alan_sum,
  aes(
    Generation,
    prop_out_mean,
    colour = substr(TrtLin, 1, 1),
    group  = substr(TrtLin, 1, 1)
  )
) +
  geom_jitter() +
  scale_x_continuous(limits = c(1, generations_total)) +
  scale_y_continuous(limits = c(0, 1)) +
  geom_smooth(method="lm", se=FALSE)+
  scale_color_brewer(palette = "Dark2") +
  labs(
    title = "proportion of flies completing the maze over generations",
    y = "lightscore",
    x = "generation")
#the warnings here are fine, some values have been removed as they were NA
  #other values went past 1.00 so were removed

#i wanted to show the the proportion in and out is relatively stable over time,
  #so i chose a scatterplot and added two lines of best fit, without standard error
    #added jitter to prevent overlapping points

#made the colours colourblindfriendly (sorry about colours in the previous assignments)

#i tried changing the legend title to Treatment but it won't budge
