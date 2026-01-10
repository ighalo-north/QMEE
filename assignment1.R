#input some piece of data into R and do a substantiative calculation

#this script reads a spreadsheet and does a calculation

#read in the spreadsheet, load necessary libraries----
library(readxl)
library(tidyverse)
library(ggplot2)
library(lmerTest)
mydata <- read_excel("AS_ALANR_jan9.xlsx")


#boxplot of Lightscore by Maze
boxplot(Lightscore~Maze, data = mydata) #we see higher scores from Maze A, so investigate

#convert Maze to a categorical factor with levels A B C D
mydata$Maze <- as.factor(mydata$Maze)
levels(mydata$Maze)

#does Maze A produce a lightscore that is significantly different from the other mazes
mazeCon <- c(-3, 1, 1, 1)
contrasts(mydata$Maze) <- cbind(mazeCon)

#do an anova
aov.mazeAvsBCD <- aov(Lightscore~Treatment*Generation*Sex*Maze, data = mydata)
summary(aov.mazeAvsBCD, split=list(Maze=list(mazeCon=1,other=2)))

#some setup for plotting later on----
#the last value in the generation column is the # of generations
generations_total <- (tail(na.omit(mydata$Generation, n = 1)))[1]

#lineage should be nested within treatment
mydata$TrtLin <- factor(paste(mydata$Treatment, mydata$Lineage, sep = "_"))

#run a new model with fixed and random factors----
newmodel <- lmer(Lightscore ~ Generation + Sex + (1|Treatment) + (1|TrtLin), data = mydata)
newmodel

#create small dataframe for plotting lightscore means----
lightscore_plot <- mydata %>%
  group_by(Generation, TrtLin, Treatment) %>%
  summarise(meanScore = mean(Lightscore, na.rm=TRUE))

#create a different, larger dataframe----
sum_sex <- mydata%>%
  mutate(
    avged = case_when(
      Treatment %in% c("S") & Sex %in% c("F") ~ "SelectionFemale",
      Treatment %in% c("S") & Sex %in% c("M") ~ "SelectionMale",
      Treatment %in% c("C") & Sex %in% c("F") ~ "ControlFemale",
      Treatment %in% c("C") & Sex %in% c("M") ~ "ControlMale",
    )
  ) %>%
  group_by(avged, Generation, Sex) %>%
  summarise(
    across(c(Lightscore, prop_out),
           list(
             mean = ~ mean(.x, na.rm = TRUE),
             se   = ~ sd(.x, na.rm = TRUE) / sqrt(sum(!is.na(.x))),
             var  = ~ var(.x, na.rm = TRUE)
           ),
           .names = "{.col}_{.fn}"
    ),
    .groups = "drop")


#4 plots----
ggplot(lightscore_plot, aes(x=lightscore_plot$Generation, y=lightscore_plot$meanScore, colour=lightscore_plot$TrtLin, group=lightscore_plot$TrtLin)) +
  geom_point()+
  geom_line()+
  scale_x_continuous(limits = c(1, generations_total), breaks = 1:22)+
  scale_y_continuous(limits = c(1, 16), breaks = 1:16)+
  labs(title="all lineages' lightscore over generation", y="lightscore",
       x="generation")+
  theme_bw()

ggplot(lightscore_plot %>% filter(TrtLin %in% c('S_1', 'S_2', 'S_3', 'S_4')),
       aes(x=Generation, y=meanScore, colour=TrtLin,group=TrtLin)) +
  geom_point()+
  geom_line()+
  scale_x_continuous(limits = c(1, generations_total), breaks = 1:22)+
  scale_y_continuous(limits = c(1, 16), breaks = 1:16)+
  labs(title="selection lightscores over generation", y="lightscore",
       x="generation")+
  theme_bw()

ggplot(lightscore_plot %>% filter(TrtLin %in% c('C_1', 'C_2', 'C_3', 'C_4')),
       aes(x=Generation, y=meanScore, colour=TrtLin, group=TrtLin)) +
  geom_point()+
  geom_line()+
  scale_x_continuous(limits = c(1, generations_total), breaks = 1:22)+
  scale_y_continuous(limits = c(1, 16), breaks = 1:16)+
  labs(title="control lightscores over generation", y="lightscore",
       x="generation")+
  theme_bw()

ggplot(sum_sex, aes(x=Generation, y=Lightscore_mean, colour=avged,group=avged)) +
  geom_point()+
  geom_line()+
  scale_x_continuous(limits = c(1, generations_total), breaks = 1:22)+
  scale_y_continuous(limits = c(1, 16), breaks = 1:16)+
  labs(title="lightscore by treatment and sex", y="lightscore",
       x="generation")+
  theme_bw()

#end----
