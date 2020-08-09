# Project - Enteric Viruses in Vietnam
## Content
* [Overview](#overview)
* [Exploratory Data Analysis](#exploratory-data-analysis)

## Overview
Emerging infectious diseases (EIDs) have a significant influence on public health and economy [Jones et al. 2008](https://www.nature.com/articles/nature06536). Vietnam has experienced a number of emerging diseases outbreaks which cause by zoonotic pathogens. The Vietnam Initiative on Zoonotic Infections (VIZIONs) project aim to understand the nature, public health and the origins of infectious disease cases. The enteric viruses study is part of components. In this project, 
* Based on the number of infected viruses to classify patients into three groups, including no viruses, single virus and multiple viruses.
* Using Bayesian mixed effects logistic regression model to investigate the risk factors for infection group.
* Using logistic regression to detect the impact between single virus infection and multiple viruses infection.

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

For each individual, we have information from hospital records and questionnaire, including demography, symptom, hospital data, laboratory test and behaviour, having 88 features. 
![covariate](https://github.com/fujun0406/enteric_viruses/blob/master/image/covariate.JPG) 

In this project, subjects were divided into three categories based on the numbered of infected virus, having no viruses (38%), single virus (35%) and coinfections which means multiple viruses (27%). 
![virus infection for patients](https://github.com/fujun0406/enteric_viruses/blob/master/image/infection_situation.jpeg)

