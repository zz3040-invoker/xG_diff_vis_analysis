# XG Analysis on EPL 2020 players with interactive plots: do players with higher xG difference mean they are "better" shooters?
**Last Edit**: 08/06/2023

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