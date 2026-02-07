library(ggplot2)
library(magrittr)

'
Write a separate script that reads in your .rds file and 
  does something with it: either a calculation or a plot
'

alan <- readRDS("clean_alan_gen25.rds")

#do a plot
ggplot(alan |> filter(Treatment %in% c("S")), aes(y = Lightscore)) + geom_histogram()
ggplot(alan |> filter(Treatment %in% c("C")), aes(y = Lightscore)) + geom_histogram()

#these plots compare distribution between treatments on lightscore

#alternative----
# %<>% is a tricky 'process and replace original df' pipe
alan %<>%
  mutate(grp = substr(Treatment, 1, 1))

ggplot(alan, aes(x = grp, y = Lightscore)) +
  theme_bw() +
  ## adjust = 1/4 does less smoothing
  geom_violin(fill = "gray", adjust = 1/4)

## mark: 2
