#assignment 3:

#Construct some (i.e., more than one) ggplots using your data.
#Discuss:
  #what you are trying to show
  #some of the choices that you have made
  #the basis for these choices
    #(e.g., Cleveland hierarchy, proximity of comparisons, or other principles of graphical communication)

library(ggplot2); theme_set(theme_bw(base_size=15))
library(readxl)
library(tidyverse) # BMB: what is this comment for? magrittr and ggplot2 are within tidyverse
## BMB (you don't need to load ggplot2 if you've loaded tidyverse first

alan <- read_excel("raw_alan_gen24.xlsx")

## BMB: shouldn't need to check/adjust class etc. (should have cleaned/checked data upstream)
sapply(alan,class)


## BMB: is this where(is.character) ?
alan <- alan |> mutate(across(c(time_of_day, Maze, Maze_Order, Treatment, Lineage, Sex, blind), factor))

## BMB: what about max(alan$Generation) ??
generations_total <- (tail(na.omit(alan$Generation, n = 1)))[1]

## BMB: could use mutate() ...
alan$TrtLin <- interaction(alan$Treatment, alan$Lineage, drop = TRUE, sep = "")

sumalan <- (alan |>
  group_by(Generation, TrtLin) %>%
  summarise(Lightscore = mean(Lightscore, na.rm=TRUE), prop_out = mean(prop_out, na.rm=TRUE))
)

## BMB: same as ??
sumalan <- (alan |>
            summarise(across(c(Lightscore, prop_out), ~ mean(., na.rm=TRUE)),
                      .by = c(Generation, TrtLin))
)


## BMB: why adjust=<small>? Do you really want the graph to be that wiggly?
## BMB: why do you have theme_bw() here if you set theme_set(theme_bw()) above?
#i want to show the difference in lightscore distribution between treatments
ggplot(alan, aes(x = Treatment, y = Lightscore)) +
  ## theme_bw() +
  geom_violin(fill = "darkgreen", adjust = 1/5) +
  labs(title="lightscore in control vs selection treatment")
## BMB: why adjust=1/3? Do you really want the graph to be that wiggly?#the comparison is directly between control and selection, so I put them on the same axis
##proximity of comparisons

## BMB: maybe: ??
ggplot(alan, aes(x = Treatment, y = Lightscore)) +
  geom_violin(trim = FALSE, fill = "gray") +
  stat_sum(alpha = 0.5) +
  scale_size(range = c(2.5, 5), breaks = c(1,2))


##i want to show the differences in proportion of flies exiting the maze between mazes


suppressWarnings(ggplot(alan, aes(x = Maze, y = prop_out)) +
  theme_bw() +
  geom_violin(fill = "blue", adjust = 1/3)) +
  labs(title = "mean proportion of flies out of each maze")

## BMB: these are 'warnings', not errors
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

## BMB: should create this factor upstream ...
## can change the name at the same time (you can also change
## this in the scale_colour() argument with name=, but this is easier)
alan_sum <- alan_sum |> mutate(Treatment = substr(TrtLin, 1, 1))
ggplot(
  alan_sum,
  aes(
    Generation,
    prop_out_mean,
    colour = Treatment,
    shape = Treatment,
    linetype = Treatment,
    fill = Treatment
    ## group  = substr(TrtLin, 1, 1) ## BMB: don't need to specify group 
  )
) +
  ## BMB: why jitter here ???
  ## geom_jitter() is a sometimes necessary evil.  Why add
  ## noise to your data if you don't have to?
  ## use stat_sum(), alpha to de-emphasize points a little bit
  stat_sum(alpha = 0.5) +
  scale_size(range=c(2.5, 5), breaks = 1:2) +
  scale_x_continuous(limits = c(1, generations_total)) +
  scale_y_continuous(limits = c(0, 1)) +
  ## se=FALSE)+ ## BMB: why se = FALSE here?
  ## I think the CI ribbons add a lot (you can make alpha small to de-emphasize them)
  geom_smooth(method="lm", alpha = 0.2)  + 
  scale_color_brewer(palette = "Dark2") +
  scale_fill_brewer(palette = "Dark2") +
  labs(
    title = "proportion of flies completing the maze over generations",
    y = "lightscore",
    x = "generation")
#the warnings here are fine, some values have been removed as they were NA
  #other values went past 1.00 so were removed

#i wanted to show the the proportion in and out is relatively stable over time,
  #so i chose a scatterplot and added two lines of best fit, without standard error
    #added jitter to prevent overlapping points

##made the colours colourblindfriendly (sorry about colours in the previous assignments)
## BMB: you can also add redundant shape/linetype info

##i tried changing the legend title to Treatment but it won't budge
## BMB: see above ...

## mark: 1.95 (explanations and code OK, but a bit sloppy in places)
