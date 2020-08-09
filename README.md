# Project - Enteric Viruses in Vietnam
## Content
* [Overview](#overview)
* [Background](#background)
* [Exploratory Data Analysis](#exploratory-data-analysis)
* [Building Model](#building-model)
  * [Bivariate Analysis](#bivariate-analysis)
  * [Bayesian Mixed Effects Logistic Regression](#bayesian-mixed-effects-logistic-regression)
  * [Logistic Regression](#logistic-regression)
* [Conclusion](#conclusion)

## Overview
Emerging infectious diseases (EIDs) have a significant influence on public health and economy [Jones et al. 2008](https://www.nature.com/articles/nature06536). Vietnam has experienced a number of emerging diseases outbreaks which cause by zoonotic pathogens. The Vietnam Initiative on Zoonotic Infections (VIZIONs) project aim to understand the nature, public health and the origins of infectious disease cases. The enteric viruses study is part of components. In this project, 
* Based on the number of infected viruses to classify patients into three groups, including no viruses, single virus and multiple viruses.
* Using Bayesian mixed effects logistic regression model to investigate the risk factors for infection group.
* Using logistic regression to detect the impact between single virus infection and multiple viruses infection.

## Background
EIDs are those diseases whose have appeared in population for the first time, or have existed but rapidly increasing in incidence or geographic range ([Morse & Schluederberg 1990](https://academic.oup.com/jid/article-abstract/162/1/1/923706?redirectedFrom=fulltext)). Vietnam is recognized as a country where it has been an epicenter of disease emergence. To tackle the scientific issues, the Vietnam Initiative on Zoonotic Infections (VIZIONs) project ran between 2011 and 2016 aiming to gather data and improve the aetiological and epidemiological of approaches for pathogen detection and discovery and enteric viruses study is one of programmes. 

Some reports have suggested that disease severity is related to the number of viruses. In this project, we aim to examine the risk factors associated with viral acute enteric infections (AEIs) by the number of viruses and whether infection with multiple viruses results in increased disease severity. Therefore, we can provide people insights about zoonotic disease transmission and symptom for enteric viruses in Vietnam.

## Exploratory Data Analysis
In the VIZIONS, the enteric disease study took place in several hospitals (Table 1) between 2012 and 2015 in Vietnam ([Rabaa et al. 2015](https://pubmed.ncbi.nlm.nih.gov/26403795/)). There are 707 patients with symptoms of enteric disease admitted to hospital and 440 samples were tested to carry virus. The majority of subjects (95%) from Dong Thap General Hospital.
| Site | Hospitals |
| ----------- | ----------- |
| 1 | Ba Vi District Hospital, Ha Noi |
| 2 | Dak Lak General Hospital, Buon Ma Thuot City, Dak Lak Province |
| 4 | Dong Thap General Hospital, Cao Lanh City, Dong Thap Province |
| 5 | Hue Central Hospital, Hue City, Thua Thien Hue Province |
| 6 | Khanh Hoa General Hospital, Nha Trang City, Khanh Hoa Province |
| 7 | The Hospital for Tropical Diseases (HTD), Ho Chi Minh City |
| 8 | National Hospital for Tropical Diseases (NHTD), Ha Noi |

<em>Table 1: VIZIONS institutions within Vietnam.</em>

For each individual, we have information from hospital records and questionnaire, including demography, symptom, hospital data, laboratory test and behaviour, having 88 features (in Figure1).

<img src="/image/covariate.JPG" width="600"/> 

<em>Figure 1: The covariate for the dataset.</em>

In this project, subjects were divided into three categories based on the numbered of infected virus, having no viruses (38%), single virus (35%) and coinfections which means multiple viruses (27%) (in Figure 2). The majority of patients’ age are under 5 years old and the population of gender in each age group are quite similar (in Figure 3).

<img src="/image/infection_situation.jpeg" width="500"/> 

<em>Figure 2: The distribution infected patients.</em>

<img src="/image/age_by_gender.jpeg" width="820"/> 

<em>Figure 3: Age and gender distribution.</em>

In this dataset, it is unequal weighting for each site. Most patients who reach the inclusion criteria live in site 4.

<img src="/image/site2.png" width="410"/> <img src="/image/site4.png" width="410"/> 
<img src="/image/site5.png" width="410"/> <img src="/image/site6.png" width="410"/>

<em>Figure 4: The distribution of virus infection for hospital sites. (top left is site 2, top right is site 4, bottom left is site 5 and bottom right is site 6)</em>

## Building Model
The purposes of the project are the risk factors which associated with infection situation and the impact between infected coinfection and single virus on disease severity. We employ bivariate analysis to detect the relationship between potential risk factors and three infection groups. By utilizing bayesian mixed effects logistic regression with hospital sites as random effect to construct model, it can provide information about risk factors associated with infection. Then we will use logistic regression to determine the relationship between viruses and disease severity.

### Bivariate Analysis
The potential risk factors include water sources, keep animal, killing animal, eat cook raw mwat, age, gender etc, that having 14 features. We use Fisher test to assess the association and it shows that the variables of gender, well, age and distance are related to infection situation.

### Bayesian Mixed Effects Logistic Regression
We ran three different Markov chains. A burn-in of 8000 Markov chain Monte Carlo iterations is used, followed by 15000 iterations during which values for the coefficients were stored.

#### Estimation
The Bayesian mixed effects logistic regression model for each group is presented in Table 2. It can be seen from the 95% CrI of well is not a significant risk factor for no virus infection and there is no significant difference between each hospital site. For single virus, the 95% CrI of distance is not a significant risk factor and there is no significant difference between each hospital site. The 95% CrI shows age and distance have significant association with people who infected multiple viruses and hospital site 4 is significantly different from others that shows that multiple viruses prevalence is higher for people who lived nearby hospital site 4 than other areas.

| |no viruses (95% CrI) | single virus (95% CrI) | multiple viruses (95% CrI) |
| ----------- | ----------- | ----------- | ----------- |
| site 2 | 1.53 (-0.04, 3.14) | -0.76 (-2.00, 0.39) | 0.03 (-1.16, 1.20) |
| site 4 | -3.82 (-12.00, 1.35) | -1.69 (-4.29, 0.45) | 2.81 (0.24, 5.48) |
| site 5 | 0.01 (-11.40, 11.10) | 0.01 (-8.51, 7.79) | -0.02 (-9.60, 9.77) |
| site 6 | 0.02 (-11.20, 11.40) | 0.01 (-7.96, 8.18) | -0.02 (-9.66, 9.53) |
| gender | 0.34 (0.02, 0.69) | -0.29 (-0.62, 0.02) | -0.01 (-0.37, 0.35) |
| well | -1.37 (-2.92, 0.21) | 1.69 (0.25, 3.22) | -0.70 (-1.94, 0.56) |
| age | 0.02 (0.01, 0.03) | -0.01 (-0.02, -0.01) | -0.02 (-0.03, -0.01) |
| distance | -0.03 (-0.05, -0.01) | -0.01 (-0.03, 0.01) | 0.03 (0.01, 0.05) |
| DIC | 848.8 | 904.2 | 772.8 |

<em>Table 2: Covariates for the Bayesian mixed effects logistic regression model. (CrI: Bayesian credible interval, male is baseline in gender and not used well water is baseline in water)</em>

#### Convergence Diagnostics
Diagnostic tests for Bayesian mixed effects logistic regression model include trace plot, density plots and Brooks-Gelman-Rubin(BGR) plot. The trace plots (Figure 5) for multiple viruses showing the three Markov chains have good mixing and suggest quick convergence as all three chains appear to be centred around the same value. And the plot of BGR (Figure 6) suggests relatively fast convergence. The results of single virus infection and no viruses infection also show they are converge.

<img src="/image/trace_plot_coinf_with_site_1.jpeg" width="410"/> <img src="/image/trace_plot_coinf_with_site_2.jpeg" width="410"/> 

<em>Figure 5: Trace plot for multiple viruses group.</em>

<img src="/image/gelman_plot_coinf_with_site.jpeg" width="500"/>

<em>Figure 6: BGR plot for multiple viruses group.</em>

### Logistic Regression
The features three days fever, blood in stool, mucoid in stool, abdominal pain, acute diarrhoea and extended stay are used to measure disease severity and use those features as dependent variables.  Patients with multiple virus illnesses had higher rates of severe clinical disease compared with children with single virus infections. Patients with single virus detections were less frequently admitted to have mucoid in stool (OR = 1.82, p value = 0.032) or three days fever (OR = 1.42, p value = 0.078) compared with the group of patients with multiple viruses (Table 3). No differences are observed when comparing rates of blood in stool, abdominal pain, acute diarrhoea or extended stay. 

| Correlation, n (%) | Single virus illnesses (n = 237) | Multiple virus illnesses (n = 179) | OR(95% CI) | p value |
| ----------- | ----------- | ----------- | ----------- | ----------- | 
| three days fever | 117 (49.4%) | 104 (58.1%) | 1.42 (0.96, 2.11) | 0.078 |
| blood in stool | 5 (2%) | 9 (5%) | 2.46 (0.83, 8.12) | 0.113 |
| mucoid in stool | 27 (11.4%) | 34 (19%) | 1.82 (1.06, 3.17) | 0.032 |
| abdominal pain | 99 (41.8%) | 67 (37.4%) | 0.83 (0.56, 1.24) | 0.371 |
| acute diarrhoea | 229 (96.6%) | 170 (95%) | 0.66 (0.24, 1.76) | 0.402 |
| extended stay (> 3 days) | 135 (56.9%) | 94 (52.5%) | 0.66 (0.24, 1.76) | 0.367 |

<em>Table 3: Correlation of severe disease, by single or multiple virus illnesses. (CI: confidence interval and OR: Odds ratio for multiple virus illnesses compared with single virus illnesses)</em>

## Conclusion










