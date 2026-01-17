library(ggplot2)
'
Write a separate script that reads in your .rds file and 
  does something with it: either a calculation or a plot
'

## BMB: you don't have to call it 'imported', you could just call
## it 'alan' again
imported_alan_data <- readRDS("clean_alan_gen24.rds")

#do a plot
ggplot(imported_alan_data |> filter(Treatment %in% c("S")), aes(y = Lightscore)) + geom_histogram()
ggplot(imported_alan_data |> filter(Treatment %in% c("C")), aes(y = Lightscore)) + geom_histogram()

#these plots compare distribution between treatments on lightscore

## BMB: alternative
## %<>% is a tricky 'process and replace original df' pipe
library(magrittr)
imported_alan_data %<>%
  mutate(grp = substr(Treatment, 1, 1))

ggplot(imported_alan_data, aes(x = grp, y = Lightscore)) +
  theme_bw() +
  ## adjust = 1/4 does less smoothing
  geom_violin(fill = "gray", adjust = 1/4)
