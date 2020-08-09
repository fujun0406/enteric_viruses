# Project - Enteric Viruses in Vietnam
## Content
* [Overview](#overview)
* [Background](#background)
* [Exploratory Data Analysis](#exploratory-data-analysis)
* [Building Model](#building-model)
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
In the VIZIONS, the enteric disease study took place in several hospitals between 2012 and 2015 in Vietnam ([Rabaa et al. 2015](https://pubmed.ncbi.nlm.nih.gov/26403795/)). There are 707 patients with symptoms of enteric disease admitted to hospital and 440 samples were tested to carry virus. The majority of subjects (95%) from Dong Thap General Hospital.
| Site | Hospitals |
| ----------- | ----------- |
| 1 | Ba Vi District Hospital, Ha Noi |
| 2 | Dak Lak General Hospital, Buon Ma Thuot City, Dak Lak Province |
| 4 | Dong Thap General Hospital, Cao Lanh City, Dong Thap Province |
| 5 | Hue Central Hospital, Hue City, Thua Thien Hue Province |
| 6 | Khanh Hoa General Hospital, Nha Trang City, Khanh Hoa Province |
| 7 | The Hospital for Tropical Diseases (HTD), Ho Chi Minh City |
| 8 | National Hospital for Tropical Diseases (NHTD), Ha Noi |

For each individual, we have information from hospital records and questionnaire, including demography, symptom, hospital data, laboratory test and behaviour, having 88 features (in Figure1).

![](/image/covariate.JPG "The features of dataset")*Figure 1: The covariate for the dataset.*

In this project, subjects were divided into three categories based on the numbered of infected virus, having no viruses (38%), single virus (35%) and coinfections which means multiple viruses (27%) (in Figure 2). The majority of patients’ age are under 5 years old and the population of gender in each age group are quite similar (in Figure 3).

![](/image/infection_situation.jpeg "The distribution of virus infection")*Figure 2: The distribution infected patients*
![](/image/age_by_gender.jpeg "Age and gender distribution")*Figure 3: Age and gender distribution*

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

### Logistic Regression

## Conclusion
