## JD: I never knew this trick!
'
Assignment 6 Linear Models Feb 10

Formulate a clear hypothesis about your data.
Make a linear model for your hypothesis.

Draw and discuss at least one of each of the following:
- diagnostic plot
- prediction plot
- inferential plot (e.g., a coefficient plot, 
  or something from emmeans or effects)


diagnostic plots: base-R plot(), performance::check_model(), DHARMa
predictive: emmeans, effects, ggpredict
inferential: coefficient plots, contrast plots
'
options(contrasts=c("contr.sum", "contr.poly"))

#car pkg stnds for: companion to apply regression

#formulate a hypothesis----
#Hypothesis: Selection lineages lightscores' will decrease over generations
#subHypothesis: females are more sensitive to the selection treatment that males

library(tidyverse)

## JD: I had to add this; please check that your script runs beginning to end in a clean session.

library(emmeans)

## JD: I like this style a lot, but please remind us in README or transmittal email how to make this file.
alan <- readRDS("clean_alan_gen25.rds")

#SMALL MODEL----
#make linear model for hypothesis
linalanbasic <- lm(Lightscore~TrtLin + Generation, data=alan)
linalan_null <- lm(Lightscore ~ 1, data = alan) #vs the null hypothesis

#draw diagnostic
performance::check_model(linalanbasic)
performance::check_model(linalan_null)

#based on the diagnostic plots,
#the basic model is a better fit to my data than the null model
#even without including Generation in linalanbasic, this model
  #is better than the null model
## JD: Not sure what this last comment means, is that part shown?
'
linalanbasic vs the null
in linalanbasic:
the distribution of the predictor values lines up with the distribution of my data
the linearity reference line is flatter and more horizontal
residuals fall along the normality line
the variance is more homogenous
and all points fall inside cooks distance in the influential observations plot
'

#a direct comparison of the two models supports what i said above
anova(linalanbasic, linalan_null)
## JD: This seems deep. A model can explain a lot of variance sometimes without matching assumptions well.

#but i have more variables, and can make a better model:
#BIG MODEL (includes hypothesis about Females vs Males----
#make linear model for hypothesis----
#add vars one by one
linalan <- lm(Lightscore~TrtLin + Generation, data = alan)

sex_linalan <- update(linalan, . ~ . +Sex)

day_linalan <- update(sex_linalan, . ~ . +day)

timeofday_linalan <- update(day_linalan, . ~ . +time_of_day)

maze_linalan <- update(timeofday_linalan, .~. +Maze)

mazeorder_linalan <- update(maze_linalan, . ~ . +Maze_Order)

blind_linalan <- update(mazeorder_linalan, .~. +blind) #check if there was any bias (effect of observers being blind or not); unlikely but interesting
  
#compare the fit of each model to my data
drop1(blind_linalan, test="F")

'
in addition to the variables in linalanbasic:
  sex, day, and Maze are clearly relevant predictors of my data
time_of_day is relevant, to a lesser degree than sex, day, and Maze
maze_order is not as relevant of a predictor
blind is also not as relevant of a predictor
'

#compare the tiny model to the bigger model, without blind
anova(linalanbasic, mazeorder_linalan)
#excluded blind here because i have some empty values in that column. 
  #to compare an anova that includes blind as a parameter,
    #i would have to throw out the empty rows
  #i don't want to model a subset of my data, i want all of it so i'm dropping blind from the model to avoid decreasing N

'
the variables in linalanbasic on their own do not fit the data well, 
  there are other relevant predictors besides TrtLin and Generation

mazeorder_linalan reduces the error in my model more than linalanbasic, so I think it is the best

i dont think i should add more variables to my model because it could be overfitted
  especially since I have a ton of data
JD: This seems backwards. The more data you have the more parameters you can support.
'

linalan_final <- mazeorder_linalan

#draw diagnostic
performance::check_model(linalan_final)
'
between the basic model and the final model, the final model seems better
  the posterior positive check, influential observations, and normality of residuals perform better in final than basic

i am ignoring the advice about VIF because I dont want to throw out relevant predictors
i will keep it in mind when interpreting results but i wont  make any changes at this point
JD: There may not even be anything to keep in mind. VIF means some of your estimates will have bigger CIs because different variables are explaining similar things. If predictors are relevant, this means you have real uncertainty and are seeing it more or less properly.
Q-Q residuals plot shows that my data has a short left tail
  the data are larger than would be expected from a normal distribution
  i think this could indicate a floor effect in my lightscore assay

the scale-location plot shows that my residuals do not have constant variance, but they are normally distributed
- this is low on the assumptions priority list so I might consider chopping some extreme values
I could use the DHARMa pkg to look at the interquartile ranges and make a decision based on that
'


#draw prediction

library(effects) #shows estimamted means for each condition
plot(allEffects(linalan_final))


predict(linalan_final) #lots of numbers so i will plot them as a correlation

pred <- predict(linalan_final)
obs <- model.response(model.frame(linalan_final))
plot(obs, pred,
     xlab = "Observed",
     ylab = "Predicted")
abline(0, 1, lty = 2)


## JD: I feel there must be a better way to order them than observation index! It's fun this way, but maybe you could learn more by ordering them
#different type of prediction (these plots are fun)
simulate(linalan_final, nsim = 20)
obs <- model.response(model.frame(linalan_final))
sim <- simulate(linalan_final, nsim = 20)

matplot(sim, type = "l", lty = 1, col = "darkgrey",
        xlab = "Observation index",
        ylab = "Outcome")

points(obs, pch = 16, col = "blue")


#the simulated data appears as though it could have plausibly come from my observed data, so the model seems to be a good fit

#draw inferential (emmeans)
em_alan1 <- emmeans(linalan_final, ~Sex)
print(em_contralan1 <- contrast(em_alan1, "eff", adjust="none"))
plot(em_contralan1, comparisons = TRUE)+ geom_vline(xintercept = 0, lty = 2)
#there is a clear difference between Females and Males

linalan_emmeans <- update(linalan_final, . ~ . +Treatment)
em_alan2 <- emmeans(linalan_emmeans, ~Treatment)
print(em_contralan2 <- contrast(em_alan2, "eff", adjust="none"))
plot(em_contralan2, comparisons = TRUE) + geom_vline(xintercept = 0, lty = 2)
#the diff between control and selection is unclear (not sure how different or if they are different at all)
#or, there is no clear difference

em_alan3 <- emmeans(linalan_final, ~TrtLin)
print(em_contralan3 <- contrast(em_alan3, "eff", adjust="none"))
plot(em_contralan3)+ geom_vline(xintercept = 0, lty = 2) #no comparisons here to avoid snooping, just looking at CIs and direction of effects
#control and selection lineages aren't even on the same side of the plot
  #but only the control lineages CIs cross 0

## NOTE: Results may be misleading due to involvement in interactions
#i predict that there may be interactions between some of these vars, particularly Sex, time_of_day, and Maze
#that may be the reason why there is no clear effect of Treatment in these contrasts



'
notes from feb 13 class

#statement: because the CI is clearly below 0, 
#cannot judge diffs in groups from overlapping CIs
#need to use Contrasts for that

#orange arrows show differences between groups from the plot of the means
#help to look at comparisons between means
  #orange arrows not overlapping, these two groups arent significantly different
#still better to compute contrasts
'

## Grade 2.1/3


