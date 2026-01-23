#clean raw data
library(readxl)
library(tidyverse)
library(ggplot2) ## BMB: don't need to load ggplot2 if you've loaded tidyverse
library(clock) #i tried to use this library to handle the times in my data, but i couldn't figure it out
##  the chron() package might be useful (I dug around  in  https://cran.r-project.org/web/views/TimeSeries.html for help)

## BMB: OK.
library(skimr)
'
assignment 2 instructions
Examine the structure of the data you imported
Examine the data for problems, and to make sure you understand the R classes
Make one or two plots that might help you see whether your data have any errors or anomalies

Report your results; fix any problems that you conveniently can
Use the saveRDS function in R to save a clean (or clean-ish) version of your data
Use the .gitignore functionality in git – do not in general put “made” objects into your repo
'

alan <- read_excel("raw_alan_gen24.xlsx")
sapply(alan,class)
## maybe more  convenient - get just the first element
sapply(alan, \(x) class(x)[1])

(alan #examine the structure of the data and check for problems
  |> summary()
  |> print())
names(alan)
skim(alan) #more examine structure, check for missing vals

#throw out the redundant dates
## BMB: what are these redundant with? their _num equivalents?
alan <- subset(alan, select = -c(start_time, end_time, Time_Elapsed))
(alan 
  |> summary()
  |> print())


#how many generations
generations_total <- (tail(na.omit(alan$Generation, n = 1)))[1]

#use tidyverse to change some char variables to factors
(alan <- alan
  |> mutate(across(c(Maze, Sex, Treatment, Maze_Order, blind), as.factor)))
## BMB: do these have the levels (order)  you  want?

#lineage should be nested within treatment for all analysis
alan$TrtLin <- factor(paste(alan$Treatment, alan$Lineage, sep = ""))
## BMB: you can use mutate() to  use fewer $, e.g.
alan <- (alan
  |> mutate(TrtLin = factor(paste0(Treatment, Lineage)))
)
## or even interaction(Treatment, Lineage, drop = TRUE)

## BMB: nice.
vial_number1 <- match(c("1"), names(alan))
vial_number2 <- match(c("16"), names(alan))
vials <- c(vial_number1:vial_number2) #indexes of cols with vial numbers (count data about the flies' position)

#find anything that's not numeric in the numbers sections
should_be_numeric <- c("Generation", "day", "Lineage", 1:16, "Lightscore", "total_Flies", "start_time_num", "end_time_num", "time_elapsed_num", "flies_in", "prop_out") ## list of columns (indices or names)

find_bad_nums <- function(x){
  x_num <- suppressWarnings(as.numeric(x))
  which(!is.na(x) & is.na(x_num))
  return(x_num)
}

find_bad_nums(alan$x)
lapply(alan, find_bad_nums)

#force all vals that should be numeric to be numeric
(alan <- alan 
|> mutate(across(all_of(should_be_numeric), as.numeric))
  )

#manipulating data so the graphs are prettier
'
penguin_alan_summed <- (alan 
                        |> summarise(across(c(Lightscore, prop_out),
                                            list(
                                              mean = ~ mean(.,na.rm=TRUE),
                                              se   = ~ sd(., na.rm = TRUE) / sqrt(sum(!is.na(.x)))),
                                            .by = c(Generation, TrtLin, Sex))
                        )
) '#this does not work, im not sure why

## BMB: the main problem is that .by goes *outside* across()
## apparently (.x) works just as well as (.) in a ~ - function, which
## surprised me
alan_sum <- (alan 
  |> summarise(across(c(Lightscore, prop_out),
                      .fns = list(
                        mean = ~ mean(.,na.rm=TRUE),
                        se   = ~ sd(., na.rm = TRUE) / sqrt(sum(!is.na(.x))))),
               .by = c(Generation, TrtLin, Sex)
               )
)

#so i did it this way instead even though it's messier, it works
alan_sum <- alan |>
  group_by(Generation, TrtLin, Sex) |>
  summarise(
    across(c(Lightscore, prop_out),
           list(
             mean = ~ mean(.x, na.rm = TRUE),
             se   = ~ sd(.x, na.rm = TRUE) / sqrt(sum(!is.na(.x))),
             var  = ~ var(.x, na.rm = TRUE)
           ),
           .names = "{.col}_{.fn}" #rename columns Lightscore_mean, Lightscore_se, etc
    ),
    .groups = "drop") #i dont actually know what this does but I get an error without it
## BMB: needing to ungroup is what .by is supposed to  avoid
skim(alan_sum) #summary to make sure it worked - yay


#Make one or two plots that might help you see whether your data have any errors or anomalies
ggplot(alan_sum |> filter(TrtLin %in% c("S1", "S2", "S3", "S4")), aes(x=Generation, y=Lightscore_mean, colour=TrtLin, group=TrtLin)) +
  geom_point()+
  geom_smooth(method="lm", formula = 'y~x', se=TRUE)+
  scale_x_continuous(limits = c(1, generations_total), breaks = 1:24)+
  scale_y_continuous(limits = c(1, 16), breaks = 1:16)+
  labs(title="selection lineages' lightscore over generation", y="lightscore",
       x="generation")+
  theme_bw()

ggplot(alan_sum |> filter(TrtLin %in% c("C1", "C2", "C3", "C4")), aes(x=Generation, y=Lightscore_mean, colour=TrtLin, group=TrtLin)) +
  geom_point()+
  geom_smooth(method="lm", formula = 'y~x', se=TRUE)+
  scale_x_continuous(limits = c(1, generations_total), breaks = 1:24)+
  scale_y_continuous(limits = c(1, 16), breaks = 1:16)+
  labs(title="control lineages' lightscore over generation", y="lightscore",
       x="generation")+
  theme_bw()

gg0 <-  
  ggplot(alan_sum, aes(x=Generation, y=Lightscore_mean,
                       colour=TrtLin, group=TrtLin)) +
  geom_point()+
  geom_smooth(method="lm", formula = 'y~x', se=TRUE)+
  scale_x_continuous(limits = c(1, generations_total), breaks = 1:24)+
  scale_y_continuous(limits = c(1, 16), breaks = 1:16)+
  labs(title="selection lineages' lightscore over generation", y="lightscore",
       x="generation")+
  theme_bw()

print(gg0)
gg0 + filter(alan_sum, stringr::str_detect(TrtLin, "^C"))
gg0 + filter(alan_sum, stringr::str_detect(TrtLin, "^S"))

## or:
alan_sum2 <- mutate(alan_sum, grp = substr(TrtLin, 1, 1))
gg0 + alan_sum2 + facet_wrap(~grp,  nrow = 1)

#Report your results; fix any problems that you conveniently can
cat("data appear normal, no more than 4 data points per treatment per generation, all numeric values are in fact numeric")
cat("no problems to report, none to fix")

## BMB: did you check the '<= 4 data points per treatment' criterion
## programmatically?
ct <- alan_sum |> count(TrtLin, Generation)
stopifnot(all(ct$n <= 4))

#Use the saveRDS function in R to save a clean (or clean-ish) version of your data
saveRDS(alan, "clean_alan_gen24.rds")





