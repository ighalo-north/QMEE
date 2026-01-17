library(ggplot2)
'
Write a separate script that reads in your .rds file and 
  does something with it: either a calculation or a plot
'

imported_alan_data <- readRDS("clean_alan_gen24.rds")

#do a plot
ggplot(imported_alan_data |> filter(Treatment %in% c("S")), aes(y = Lightscore)) + geom_histogram()
ggplot(imported_alan_data |> filter(Treatment %in% c("C")), aes(y = Lightscore)) + geom_histogram()

#these plots compare distribution between treatments on lightscore