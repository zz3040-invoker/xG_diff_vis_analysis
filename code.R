# Author: Nemo Ni, Pu Xiao, Colin (Zhening) Zhang
# last update: 08/02/2023

## SETUP
# import packages
library(highcharter)
library(ggplot2)
library(plotly)
library(tidyverse)
# package for best subsets/stepwise selection
library(leaps)
# package for palette
library(viridis)
library(RColorBrewer)
# package to create summary table in "Study sample"
library(gtsummary)

# data import
df <- read_csv("data/epl2021_npg_5.csv") # npg_num >= 5
df_event <- read_csv("data/shot_data_npg_5.csv")

## INTRODUCTION
# plot name: intro_p1
# Scatterplot: Shooting vs xG_diff (hue: club)
# Shows that high xG_diff may not imply a high shooting scores in FIFA.
intro_p1 = df %>% 
  hchart(
    type = "scatter",
    hcaes(x = shooting, y = npxG_diff, group = team_title)
  ) %>%
  hc_xAxis(
    title = list(text = "FIFA21 shooting score")
  ) %>%
  hc_yAxis(
    title = list(text = "non-penalty expected goal difference"),
    plotLines = list(list(color = "red", value = 0, width = 1, zIndex = 5, dashStyle = "Dash"))
  ) %>%
  hc_title(
    text = "<b>Shooting</b> vs <b>xG_diff</b> of EPL players with 5+ non penalty goals in the season 2020/2021",
    margin = 20,
    align = "left",
    style = list(color = "#22A884", useHTML = TRUE)
  ) %>%
  hc_tooltip(
    valueDecimals = 2,
    headerFormat = "{point.key}: ",
    pointFormat= "{point.team_title}<br> shooting: {point.x}<br> npxG_diff: {point.y:.2f}<br> npg: {point.npg_num}<br> npxG: {point.npxG_num:.2f}"
  ) 

htmlwidgets::saveWidget(intro_p1, "intro_p1.html")
#display_html('<iframe src="intro_p1.html" width=100% height=600></iframe>')

# plot name: intro_p2
# Scatterplot: Whoscored rating vs xG_diff (hue: position_short)
# Shows that high xG_diff doesn't not imply a high whoscored rating.
intro_p2 <- df %>% 
  hchart(
    type = "scatter",
    hcaes(x = Rating, y = npxG_diff, group = position_short)
  ) %>%  
  hc_yAxis(
    title = list(text = "non-penalty expected goal difference"),
    plotLines = list(list(color = "red", value = 0, width = 1, zIndex = 5, dashStyle = "Dash"))
  ) %>%
  hc_title(
    text = "<b>Whoscored rating</b> vs <b>xG_diff</b> of EPL players with 5+ non penalty goals in the season 2020/2021",
    margin = 20,
    align = "left",
    style = list(color = "#22A884", useHTML = TRUE)
  ) %>%
  hc_tooltip(
    valueDecimals = 2,
    headerFormat = "{point.key}: ",
    pointFormat= "{point.team_title} <br> Rating: {point.x} <br> npxG_diff: {point.y}"
  )

htmlwidgets::saveWidget(intro_p2, "intro_p2.html")
#display_html('<iframe src="intro_p2.html" width=100% height=400></iframe>')

## STUDY SAMPLE
# table name: table1
# tbl_summary table: show the summary of 15 important features using package "gtsummary".
important_features <- quos(
  attacking_finishing, mentality_positioning, shooting, age, 
  weak_foot, work_rate_attack, power_long_shots, skill_moves, 
  pace, passing, dribbling, defending, physic, 
  position_short, npxG_diff
)

# create the table
table1 <- df %>%
  select(!!!important_features) %>%
  tbl_summary()

# save table1 in html and output it in Kaggle
gt::gtsave(as_gt(table1), "table1.html")
#display_html('<iframe src="table1.html" width=100% height=400></iframe>')

## STEP 1
# We first select important features from initial data set (with 14 features) and using regsubsets 
# Performing all subset regression using regsubsets from leaps
# https://rdrr.io/cran/leaps/man/plot.regsubsets.html
models_xG <- regsubsets(
  npxG_diff ~ 
    attacking_finishing + 
    mentality_positioning + 
    shooting + 
    age + 
    weak_foot + 
    work_rate_attack + 
    power_long_shots + 
    skill_moves + 
    pace + 
    passing + 
    dribbling + 
    defending + 
    physic + 
    position_short, 
  data = df,
  nvmax = 10, 
  nbest = 1
)

# plot the result
plot(
  models_xG, 
  scale = "bic", 
  main = "Result from best subset selection (nvmax = 10, nbest = 1)",
  xlab = "Drop-in BIC",  
  col = rev(brewer.pal(9, 'Blues'))
)

# we choose the following 2 features from best subset selection above:
# relevel the factor of position_short, set reference level as "ST"
df$position_short <- relevel(factor(df$position_short), ref = "ST")
lm1 <- lm(
  npxG_diff ~ 
    pace +
    position_short, 
  data = df
)
summary(lm1)

## STEP 2
# print the linear regression summary between npxG_diff and position.y
lm_npxG_diff_position <- lm(npxG_diff ~ position_short, data = df)
summary(lm_npxG_diff_position)

# plot name: s2_p1
# Boxplot: position_short vs xG_diff (hue: position_short)
# shows the different distribution of xG_diff across three different positions: ST, CM, W
# excludes DEF because it only has two data points; removes outliers.

dat_st <- data_to_boxplot(
  filter(df, position_short == "ST"),
  variable = round(npxG_diff, 2),
  add_outliers = FALSE,
  color = "#00e272",
  name = "ST"
)

dat_w <- data_to_boxplot(
  filter(df, position_short == "W"),
  variable = round(npxG_diff, 2),
  add_outliers = FALSE,
  color = "#feb56a",
  name = "W"
)

dat_cm <- data_to_boxplot(
  filter(df, position_short == "CM"),
  variable = round(npxG_diff, 2),
  add_outliers = FALSE,
  color = "#2caffe",
  name = "CM"
)

s2_p1 <- highchart() %>%
  hc_xAxis(type = "category") %>%
  hc_add_series_list(dat_st) %>%
  hc_add_series_list(dat_w) %>%
  hc_add_series_list(dat_cm) %>%
  hc_xAxis(
    title = list(text = "Position")
  ) %>%
  hc_yAxis(
    title = list(text = "non-penalty xG difference"),
    plotLines = list(list(color = "red", value = 0, width = 1, zIndex = 5, dashStyle = "Dash"))
  ) %>%
  hc_title(
    text = "Distribution of <b>npxG_diff</b>: Midfielder(CM) vs Wingers(W) vs Strikers(ST)",
    margin = 20,
    align = "left",
    style = list(color = "#22A884", useHTML = TRUE)
  )

htmlwidgets::saveWidget(s2_p1, "s2_p1.html")
#display_html('<iframe src="s2_p1.html" width=100% height=400></iframe>')

# plot name: s2_p2
# Scatterplot: npg vs npxG (hue: position_short)
# Shows that position influences xG_diff.

s2_p2 = df %>% 
  hchart(
    type = "scatter",
    hcaes(x = npxG_num, y = npg_num, group = position_short)
  ) %>%  
  hc_colors(c("#00e272", "#2caffe", "#91e8e12", "#feb56a")) %>% # change the colors as the same as intro_p2
  hc_add_series(
    name = "reference line (npg_num = npxG_num)", 
    data = seq(20) - 1, 
    color = "red",
    marker = list(enabled = FALSE),
    dashStyle = "Dash"
  ) %>%
  hc_xAxis(title = list(text = "non-penalty xG")) %>%
  hc_yAxis(title = list(text = "non-penalty goals")) %>%
  hc_title(
    text = "<b>npg</b> vs <b>npxG</b> of 5+ npg players in 2020/2021 the season",
    margin = 20,
    align = "left",
    style = list(color = "#22A884", useHTML = TRUE)
  ) %>%
  hc_tooltip(
    valueDecimals = 2,
    headerFormat = "{point.key}: ",
    pointFormat= "{point.team_title} <br> position: {point.position_short} <br> npxG_num: {point.x:.2f} <br> npg_num: {point.y}"
  )

htmlwidgets::saveWidget(s2_p2, "s2_p2.html")
#display_html('<iframe src="s2_p2.html" width=100% height=400></iframe>')

## STEP 3
plot = df %>% 
  ggplot(
    aes(x = pace, y = round(npxG_diff,2), color = position_short, label = player_name)
  ) + 
  geom_point() +
  geom_smooth(method = "lm") +
  labs(x = "FIFA pace", y = "non-penality xG difference") + # x and y labs
  scale_color_manual(values = c("cornflowerblue", "black", "green", "orange")) # change colors

s3_p1 = ggplotly(
  plot
) %>% 
  layout(
    title = list(
      text = "<b>FIFA pace</b> vs <b>npxG</b> of 5+ npg players in 2020/2021 the season", 
      font = list(color = "green")
    )
  ) # add title

# need following two lines to plot the graph on kaggle
htmlwidgets::saveWidget(s3_p1, "s3_p1.html")
#display_html('<iframe src="s3_p1.html" width=100% height=400></iframe>')

s3_p2 = df %>% 
  hchart(
    type = "scatter",
    hcaes(x = crowdedArea, y = npxG_diff, group = position_short)
  ) %>%  
  hc_colors(c("#00e272", "#2caffe", "#91e8e12", "#feb56a")) %>% # change the colors as the same as intro_p2
  hc_xAxis(title = list(text = "crowdedArea")) %>%
  hc_yAxis(title = list(text = "npxG_idff"),
           plotLines = list(list(color = "red", value = 0, width = 1, zIndex = 5, dashStyle = "Dash"))) %>%
  hc_title(
    text = "<b>crowdedArea</b> vs <b>npxG_num</b> of 5+ npg players in 2020/2021 the season",
    margin = 20,
    align = "left",
    style = list(color = "#22A884", useHTML = TRUE)
  ) %>%
  hc_tooltip(
    valueDecimals = 2,
    headerFormat = "{point.key}: ",
    pointFormat= "{point.team_title} <br> position: {point.position_short} <br> Shots in crowdedArea: {point.x:.2f} <br> npxG_num: {point.y}"
  )

# need following two lines to plot the graph on kaggle
htmlwidgets::saveWidget(s3_p2, "s3_p2.html")
#display_html('<iframe src="s3_p2.html" width=100% height=400></iframe>')

s3_p2_2 = df %>% 
  hchart(
    type = "scatter",
    hcaes(x = crowdedArea_goal_P, y = npxG_diff, group = position_short)
  ) %>%  
  hc_colors(c("#00e272", "#2caffe", "#91e8e12", "#feb56a")) %>% # change the colors as the same as intro_p2
  
  hc_xAxis(title = list(text = "crowdedArea_goal_P")) %>%
  hc_yAxis(title = list(text = "npxG_num"),
           plotLines = list(list(color = "red", value = 0, width = 1, zIndex = 5, dashStyle = "Dash"))) %>%
  hc_title(
    text = "<b>crowdedArea_goal_P</b> vs <b>npxG_num</b> of 5+ npg players in 2020/2021 the season",
    margin = 20,
    align = "left",
    style = list(color = "#22A884", useHTML = TRUE)
  ) %>%
  hc_tooltip(
    valueDecimals = 2,
    headerFormat = "{point.key}: ",
    pointFormat= "{point.team_title} <br> position: {point.position_short} <br> crowdedArea_goal_P: {point.x:.2f} <br> npxG_num: {point.y}"
  )

# need following two lines to plot the graph on kaggle
htmlwidgets::saveWidget(s3_p2_2, "s3_p2_2.html")
#display_html('<iframe src="s3_p2_2.html" width=100% height=400></iframe>')

s3_p3 <- df %>% 
  hchart(
    type = "scatter",
    hcaes(x = shot_num * 90 / Mins, y = npxG_diff, group = position_short)
  ) %>% 
  hc_colors(c("#00e272", "#2caffe", "#91e8e12", "#feb56a")) %>%
  hc_xAxis(
    title = list(text = "Shots per 90 minutes")
  ) %>%
  hc_yAxis(
    title = list(text = "non-penalty expected goal difference"),
    plotLines = list(list(color = "red", value = 0, width = 1, zIndex = 5, dashStyle = "Dash"))
  ) %>%
  hc_title(
    text = "<b>Shots per 90 mins</b> vs <b>xG_diff</b> of EPL players with 5+ non penalty goals in the season 2020/2021",
    margin = 20,
    align = "left",
    style = list(color = "#22A884", useHTML = TRUE)
  ) %>%
  hc_tooltip(
    valueDecimals = 2,
    headerFormat = "{point.key}: ",
    pointFormat= "{point.team_title} <br> 
                        shots: {point.x:.2f} <br> 
                        npg: {point.npg} <br>
                        npxG: {point.npxG:.2f} <br>
                        npxG_diff: {point.y}"
  )

htmlwidgets::saveWidget(s3_p3, "s3_p3.html")
#display_html('<iframe src="s3_p3.html" width=100% height=400></iframe>')

s3_p3_1 <- df %>% 
  hchart(
    type = "scatter",
    hcaes(x = shot_num, y = npxG_diff, group = position_short)
  ) %>% 
  hc_colors(c("#00e272", "#2caffe", "#91e8e12", "#feb56a")) %>%
  hc_xAxis(
    title = list(text = "total shots"),
    plotLines = list(list(color = "red", value = 80, width = 1, zIndex = 5, dashStyle = "Dash"))
  ) %>%
  hc_yAxis(
    title = list(text = "non-penalty expected goal difference"),
    plotLines = list(list(color = "red", value = 0, width = 1, zIndex = 5, dashStyle = "Dash"))
  ) %>%
  hc_title(
    text = "<b>Shots</b> vs <b>xG_diff</b> of EPL players with 5+ non penalty goals in the season 2020/2021",
    margin = 20,
    align = "left",
    style = list(color = "#22A884", useHTML = TRUE)
  ) %>%
  hc_tooltip(
    valueDecimals = 2,
    headerFormat = "{point.key}: ",
    pointFormat= "{point.team_title} <br> 
                        shots: {point.x} <br> 
                        npg: {point.npg} <br>
                        npxG: {point.npxG:.2f} <br>
                        npxG_diff: {point.y}"
  )

htmlwidgets::saveWidget(s3_p3_1, "s3_p3_1.html")
#display_html('<iframe src="s3_p3_1.html" width=100% height=400></iframe>')

other_lastActions <- c(
  "OffsidePass", "BallTouch", "BallRecovery", "HeadPass", 
  "Dispossessed", "Rebound", "LayOff", "CornerAwarded", "None", 
  "Foul", "BlockedPass", "Interception", "GoodSkill", "Challenge"
)

# plot: based on an average player
data2 <- df_event %>%
  filter(position != "DEF") %>%
  mutate(lastAction2 = case_when(lastAction %in% other_lastActions ~ "Other",
                                 TRUE ~ lastAction),
         goal = result == "Goal") %>%
  group_by(position, lastAction2) %>%
  summarize(
    shots = n(),
    sum_xg = sum(xG),
    avg_xg = mean(xG),
    sum_goal = sum(goal),
    avg_goal = mean(goal),
    avg_xg_diff = mean(goal) - mean(xG),
    sum_xg_diff = sum(goal) - sum(xG)
  ) 

# highcharts
s3_p4 = data2 %>% 
  hchart(
    type = "column",
    hcaes(x = lastAction2, y = avg_xg_diff, group = position)
  ) %>%
  #hc_plotOptions(bar = list(stacking = "stack")) %>%
  hc_xAxis(
    title = list(text = "Last Action")
  ) %>%
  hc_yAxis(
    title = list(text = "Average npxG_diff")
  ) %>%
  hc_title(
    text = "<b>Average npxG_diff</b> of <b>last action</b> per shot between different <b>positions</b>",
    margin = 20,
    align = "left",
    style = list(color = "#22A884", useHTML = TRUE)
  ) %>%
  hc_tooltip(
    valueDecimals = 2,
    headerFormat = "{point.key}: ",
    pointFormat= "<br>position: {point.position}
                    <br>avg_npxG_diff: {point.y:.2f}
                    <br>shots: {point.shots}
                    <br>goals: {point.sum_goal}
                    <br>xG: {point.sum_xg:.2f}"
  )

htmlwidgets::saveWidget(s3_p4, "s3_p4.html")
#display_html('<iframe src="s3_p4.html" width=100% height=600></iframe>')

