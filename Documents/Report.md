# XG Analysis on EPL 2020 players with interactive plots: do players with higher xG difference mean they are "better" shooters?
**Last Edit**: 08/07/2023

**Authors:**
Nemo Ni, Pu Xiao, Zhening Zhang

**Contributions:** *All the authors have equal contributions. The listing order is random. All authors participated in brainstorming, project designing, coding, and writing. The main responsibilities of each person are written below: Zhening proposed the idea (hence Zheing is the owner of this Kaggle notebook), organized the meeting, and wrote R codes for interactive plots in Introduction and Step 2. Pu carried out the best subset regression in Step 1, designed some interactive plots in Step 3, and wrote the Discussion and Conclusion. Nemo constructed our dataset by filtering the FIFA dataset, studied pace vs npxG_diff in Step 3, and contributed all the writing parts of this report.*

**Table of Content:**
* [Introduction](#intro)
* [Study sample](#sample)
* [STEP 1: feature selection](#s1)
* [STEP 2: how does Position influence xG_diff](#s2)
* [STEP 3: study of features other than Position](#s3)
* [Discussion](#dis)
* [Conclusion](#con)

<a id="intro"></a>
# Introduction

In recent years, expected goals (xG) has become a common feature for media and mainstream broadcasters in the soccer industry. Introduced by Opta's Sam Green in 2012, xG has been created to estimate the quality of every scoring chance in a game. Although xG was initially used to measure the quality of every shot's chance, it soon evolved into a soccer analysis tool to measure players' performance, especially for attackers. In this report, a new measurement, Expected Goals Difference (xG_diff), is defined as the difference between the player's goals and xG to evaluate an attacking player’s skill. A positive xG_diff indicates the player scores more goals than the xG model expects; While a negative xG_diff indicates the player scores fewer goals than the xG model expects. <br>

For example, the vlogger Tifo IRL analyzed the player’s ability based on a non-penalty goal vs. non-penalty xG scatter plot (https://www.youtube.com/watch?v=lWQf87FMEqo). It makes intuitive sense that a positive correlation exists between xG and a player’s shooting ability for most readers. Scientifically, however, it is untested. <br>

<!-- INSERT a plot: intro_p1 -->

<!-- INSERT a plot: intro_p2 -->

The two plots displayed above depict the relationship between xG_diff and two features:  shooting and Whoscored rating. Neither of the plots demonstrates a notable trend suggesting a correlation between xG_diff and either shooting or Whoscored rating. It raised doubts regarding the reliability and accuracy of xG_diff as a metric to evaluate a player’s shooting ability or overall performance. Hence, the report aims to conduct a thorough investigation on xG_diff and address the question “**Does a higher xG_diff  indicate a better player?**”

<a id="sample"></a>
# Study sample

For our analysis, we selected a sample consisting of English Premier League (EPL) players who scored a minimum of five non-penalty goals in the 2020-2021 season. The total number of players included in the sample is 62. To gather data on player performance and expected goals (xG), we extracted relevant information from a reliable source, Understat (https://www.kaggle.com/datasets/invokerz/epl-xg-data-from-douglasbc). Additionally, for skills-related data, we utilized the statistics available in the widely recognized soccer video game FIFA 20, obtained during the baseline period when the game was initially released (https://www.kaggle.com/datasets/stefanoleone992/fifa-22-complete-player-dataset). Last, we extracted the rating information from Whoscored (https://www.whoscored.com/Regions/252/Tournaments/2/Seasons/8228/Stages/18685/Show/England-Premier-League-2020-2021) and manually added a single position label (position_short) to each player as a substitute for FIFA 20 positions (position_long) which usually contain more than one position for each player. 

The following table shows the summary of the top 14 variables that we select based on our soccer knowledge. 

<!-- INSERT a table: table1 -->

<a id="s1"></a>
# STEP 1: feature selection

Our first step is to find out the most significant factors that contribute to our outcome of interest, the difference between goals and xG (xG_diff). We employed a best subset regression model approach to analyze the relationship between various predictor variables and the outcome of interest and select the best model based on BIC. The maximum number of variables (nvmax) considered in the model was limited to 10 to ensure parsimony and prevent overfitting. We manually selected predictor variables that are potentially associated with xG_diff, including playing position, long shot skills, finishing skills, physical attributes, weak foot ability, work rate, age, pace, passing ability, dribbling skills, defending capabilities, and skill moves ability. By systematically evaluating all possible combinations of these variables, we aimed to identify the optimal subset of predictors that significantly contribute to explaining the variation in the outcome variable. This methodological approach allows for a comprehensive exploration of the potential impact of each predictor variable while avoiding issues associated with multicollinearity and model complexity.

<!-- INSERT something: something -->

The results obtained from the best subset regression analysis indicate that the regression model with the three lowest Drop in Bayesian Information Criterion (Drop in BIC) values includes different combinations of variables. Drop in BIC is the difference compared to the intercept-only model. The first model (BIC = -7.48) includes the variables pace and playing position, suggesting that these two factors have a significant influence on the outcome. The second model (BIC = -6.21)  incorporates, pace, playing position, and long shots skills, suggesting that long shots skills can explain part of the xG_diff variance after controlling for pace and playing position. Interestingly, the third model (BIC = -5.98) includes only the variable "playing position," implying that this single factor alone provides valuable insights into the outcome. Details about the model with the lowest BIC are demonstrated below.

<!-- INSERT something: something -->

Based on the results shown above, we observed a negative association between pace and xG_diff (p < 0.07). Furthermore, after adjusting for pace, central strikers(ST) exhibit a lower mean xG_diff compared to both midfielders(CM) and wingers(W), with a difference of 3.2 (p < 0.001) and 2.4 (p = 0.003), respectively. These significant differences in xG_diff across different playing positions, along with the low p-values, provide valuable guidance for our subsequent investigation into the factors contributing to these disparities in playing position.

<a id="s2"></a>
# STEP 2: how does Position influence xG_diff

Our second step is to investigate how position is correlated with npxG_diff. Firstly, we performed a linear regression using position (position_short) as the dependent variable and non-penalty expected goal difference (npxG_diff) as the independent variables. The result is printed below:

<!-- INSERT something: something -->

The result from the linear regression above implies that midfielders(CM), wingers(W), and defenders(DEF) all have higher mean npxG_diff than strikers(ST). npxG_diffs of midfielders are statistically significantly higher than the strikers (p < 0.001), with a substantial difference of 3.43. Wingers display a modest but statistically significant difference,  with a  1.89 higher npxG_diff than strikers (p = 0.013). Defenders (n=2) demonstrated a weaker difference of 3.05 more npxG_diff than strikers (p = 0.100). Given that only two defenders were included, we have limited power to detect the difference between defenders and strikers. <br>

In addition, we visualize the npxG distributions of strikers, wingers, and midfielders separately with the boxplots below. Defenders are not included due to limited size.

<!-- INSERT a plot: s2_p1 -->

The boxplots are consistent with the regression model results that midfielders and wingers have higher mean npxG_diff than strikers. We notice that strikers had a negative(-0.62) median npxG_diff, which indicates that most EPL strikers with 5+ non-penalty goals have a negative npxG_diff. In contrast, midfielders’(2.78) and wingers’ (0.81) median npxG_diff are positive, implying that most EPL midfielders and wingers with 5+ non-penalty goals have a positive npxG_diff. To provide a player-level understanding of position’s influence on npxG_diff, we also drew an interactive scatter plot below.

<!-- INSERT a plot: s2_p2 -->

This plot shows the total non-penalty goals and the sum of non-penalty xG for each EPL player with 5 plus non-penalty goals during the 2020/2021 season. The red line is when non-penalty goals are equal to non-penalty xG. Players located on the upper side of the red line have positive xG_diff. The plot indicates that most of the strikers have a negative npxG_diff. There are only 7 out of 33 non-strikers have negative npxG_diff. We recommend our readers play around with this interactive plot. You can hide a position by clicking on the position legend at the bottom, and you can view the detail of a player by moving the cursor on the point. <br>

Therefore, from all the analysis above, it is clear that there are more strikers than any other position in the negative xG_diff area. Although we didn’t investigate what are the fundamental causes of the phenomena in this study, we suggest the following hypothesis for future study: <br>

1. **Selection bias**

The first reason we thought may cause the gap of npxG_diff between strikers(ST) and non-strikers(CM, W, DEF) players is the selection bias when we filtered to get the 62 players we used. Since we only used the player who scored 5 or more non-penalty goals in the season, which could be a tricky standard for non-strikers because strikers are supposed to have more chance to score goals than midfielders, wingers, and defenders. Likewise, we did not consider defenders at all because they have fewer chances and goals, and this could be the problem if we use the same standard to filter out midfield players. After the filtration, we had 29 strikers and 33 non-strikers (need accurate number), corresponding to the total number of strikers and non-strikers who were originally on the list, the 33 non-strikers may be located in a higher percentile in the midfielder group than those 29 strikers located in their group in terms of “how good they are”. So, the reason that non-strikers have better performance in our research is just because we selected better non-strikers than strikers.

2. **Non-strikers are actually better at scoring than strickers**

If npxG_diff has any position correlation with the shooting ability, the result implies that non-strikers are better at scoring than strikers among 20-21 EPL players. Although it sounds counterintuitive, we believe there is worth some investigation into the shooting ability among different positions. Shooting is only one of the many important abilities of strikers. In other words, we believe it is worth some study to prove that “strikers are better at shooting than non-strikers rather than other skills such as positioning, physic, and speed."

3. **Confounder variables (Step 3)**

Another hypothesis is that there exist some confounder variables that affect both position and npxG_diff. We analyze some possible confounding variables in the next section.  Nevertheless, we still suggest other future studies on other possible confounding variables as position and npxG_diff are both multidimensional and complex features. 

<a id="s3"></a>
# STEP 3: study of features other than Position

In STEP 3, we investigate four features other than position: pace, shot zone, shot, and last action. 

## 3.1 Pace

<!-- INSERT a plot: s3_p1 -->

In Step 1, besides playing position, pace stands out to have a a suggestive association (p = 0.06) with npxG_diff, as revealed by the best subset regression model selection. In this figure, we plot the association between the player’s pace and his npxG_diff, stratifying by their playing position. Notably, Non-winger players tend to have a negative association between their paces, and npxG_diffs and strikers seem to have the strongest relationship. Based on these distinct patterns among players in different positions, especially comparing strikers to non-strikers, we conducted a linear model that included the player’s pace and playing position, with their interaction term. Although the interaction term is not statistically significant (coefficient = -0.13, p = 0.231 for comparing strikers to midfielders), we hypothesized that pace has varying effects on npxG_diff depending on the player's position. Specifically, we proposed that among strikers, the faster pace is negatively associated with npxG_diff, while the effect may be close to null for players in other positions. To further support our hypothesis, we performed a subsequent univariate linear model focusing solely on strikers. The results of this analysis indeed supported the association between pace and npxG_diff among strikers, showing a significant negative effect (coefficient = -0.14, p = 0.025). <br>

We do not consider the observed associations between pace and npxG_diff to be a causal relationship. We acknowledge the existence of unmeasured confounders that likely play a role in this association we have found. With this in mind, we propose some hypotheses to help explain the observed patterns: 1. Slower players may possess other exceptional skills, such as finishing, passing, or strength, which compensate for their lack of speed. , etc. 2. Faster players might frequently encounter situations where shooting becomes the only viable option, even if it presents disadvantages, such as facing a higher number of defenders or having fewer teammates supporting the play. This could explain why their pace is negatively associated with npxG_diff. 

## 3.2 Shot zone

<!-- INSERT a plot: s3_p2 -->

Since strikers did not perform well in the xG model and they tend to have more shots taken in the central area of the box, we want to show that more shots in this area may lead to negative xG_diff. <br>

<img src="https://imgur.com/2fvmLEN.png" width="400px" height="400px">

As the figure shown above, crowded Area is defined as the area between the two vertical sides of the six-yard box extending to the penalty area margin (six-yard box included). This plot visualizes the total shots made in the crowded area and the non-penalty xG difference for each EPL player with 5 plus non-penalty goals during the 2020/2021 season. The horizontal red line is when the non-penalty xG difference (npxG) is equal to zero which means non-penalty goals are equal to non-penalty xG. Players located on the upper side of the red line have positive xG_diff. The plot indicates that all the midfield players (except Mason Mount, who also played many games as a winger, wild position) have positive npxG_diff and all of them have crowded area shots less than 38. For 12 players (10 strikers and 2 wingers) who have more than 38 shots in the crowded area, only 2 of them have positive xG_diff (Salah and Benteke). <br>

Therefore, from all the analysis above, the players with more shots in the crowded area seem more likely to have negative xG_diff, but players in different positive may have different opportunities to enter the crowded area, so we also looked at the percentage of crowded area shots for a player and the xG_diff.

<!-- INSERT a plot: s3_p2_2 -->

The horizontal red line and the players are the same as in the plot above, but this plot shows the percentage of crowded area shots (shots in the crowded area/total shots) and the non-penalty xG difference. The plot does not show a clear trend as the percentage of shots in crowded area increased, the xG_diff will decrease. In fact, again, all the midfield players (except Mason Mount, who also played many games as a winger, wild position) have positive npxG_diff, like midfielder Willock, with the highest 64 percent shots in crowded area, still has 3.67 xG_diff. For strikers, their distributions seem randomly spread above or below the line.

## 3.3 Shot

<!-- INSERT a plot: s3_p3 -->

The scatter plot above visualizes the correlation between shots per 90 minutes and npxG_diff. We haven't found any significant correlation between shots per 90 minutes and npxG_diff.

<!-- INSERT a plot: s3_p3_1 -->

The second scatter plot above visualized the correlation between the total shots and npxG_diff. It seems that total shots are negatively correlated with npxG_diff for each position. Most players with positive npxG_diff have total shots of less than 80. It implies that a player who shoots more will have lower npxG_diff. We encourage future studies to investigate more on this effect. 

## 3.4 Last action

<!-- INSERT a plot: s3_p4 -->

The above barplot shows the average npxG_diff per shot between the 7 last actions among different positions. The 7 last actions are aerial, chipped, cross, pass, take-on, through-ball, and other; The three positions are midfielder(CM), striker(ST), and winger(W). The average npxG_diff is calculated as the expected goals divided by total shots grouped by last action and position. For example, CM with the last action chipped has an average npxG_diff of positive 0.13. It means that, on average, a shot performed by a midfielder from the last action “chipped” gains them 0.13 npxG_diff. 
From the plot, the most distinguished last action is the through-ball. Midfielder has significantly higher average npxG_diff (0.71) than strikers (-0.09) and wingers (0.09). Midfielders score all 5 through balls with an xG of 1.47. On the other hand, strikers only score 14 out of 61 through balls with an xG of 19.40. <br>

However, given the limited sample size, we cannot conclude that midfielders are better at scoring on through balls (n=5). We will leave this part to future study as the main focus of this report is between position and npxG_diff. Nevertheless, we suspect that midfielders are less willing to take shots on through balls than strikers. Since the last action only takes account of shot-completed behavior, midfielders who are more conservative at scoring may take advantage of the npxG_diff system.

<a id="dis"></a>
# Discussion

Our results from Step 2 indicated that a player’s position is one of the most impactful factors contributing to players’ xG_diff: midfield players tend to have higher xG_diff than strikers, which means midfielders score more goals than expected. Thus, we believe xG_diff solo is not an objective metric to evaluate the performance of a player in a single season. <br>

There are several limitations of our study. First, our research only included data from the 2020-2021 premier league season. For future studies, we suggest harmonizing data from multiple seasons and leagues to replicate our results and explore novel findings. Second, due to the limitation of sample size (n = 62), we were unable to see the correlation among many other features and effects on the xG model. For example, as aforementioned in Step 3, we believed variables like *last action*, will to some extent affect the xG model, but we could not conclude with some of the correlations we already saw because of the limited sample size. <br>

In addition, given that feature ratings from FIFA are not the best and most accurate measurement of a player’s skills, we perform the same exploratory analyses on FM 2020 (Football Manager 2020 Sports Interactive) player data (https://www.kaggle.com/datasets/ktyptorio/football-manager-2020). There is no significant association found between FM 2020 players’ finishing skill ratings and the npxG_diff. Despite that we replicated what we found in another dataset, both FIFA and FM ratings may not reflect the player’s skill set accurately and a player’s skills are more complicated than numbers from the games. <br>

Another potential direction to further explore is: what if the same player plays in a different position? Does it affect its xG value? Those are some interesting questions we suggest to study from what we saw in this report.

<a id="con"></a>
# Conclusion

Through exploratory data analysis and the best Subsets regression in Step 1, we found the two influential features of npxG_diff: pace and position. Then, given the significant coefficient of position, we investigate position’s effect on npxG_diff in Step 2. Players' position is significantly related to performance in the XG model. We found that midfielders have higher XG differences than strikers. Next, we investigated four more features (pace, shot zone, shot, and last action) on their effect on npxG_diff in Step 3. Although we cannot make any robust conclusion due to the limitations listed in the discussion, we suggest some interesting directions for future studies. <br>

Back to the question in the introduction “Does a higher xG_diff(npxG_diff)  indicate a better player?” According to what we saw in the report, we believe the answer is **NO**.  npxG_diff doesn’t show a positive correlation with player performance or shot ability metrics such as Whoscored rating and FIFA shot score. We also believe that the position should be taken considered when evaluating npxG_diff because midfielders have an average higher npxG_diff than strikers. <br>

**Note:** *all plots in this report are interactive plots created by plotly and highcharters packages in R. We recommend our readers play around with every interactive plot. For example, for most scatter plots, you can hide a group by clicking on the legend at the bottom, and view the detail of a player by moving the cursor on the point.*
