#####################################################
# Project 1 - Understanding the epidemiology of     #
#             enteric viral diseases in Vietnam     #
# Name: Fu-Chun Huang                               #
# Date: 03/07/2020                                  #
#####################################################

# install package
# install.packages("readxl")
# install.packages("tidyverse")
# install.packages("gridExtra")
# install.packages("geosphere")
# install.packages("leaflet")
# install.packages("ggrepel")
# install.packages("nnet")
# install.packages("geosphere")
# install.packages("lubridate")
# install.packages("rjags")
# install.packages(fastDummies)
# install.packages(broom)
library(ggrepel)
library(readxl)
library(tidyverse)
library(gridExtra)
library(geosphere)
library(leaflet)
library(nnet)
library(geosphere)
library(lubridate)
library(rjags)
library(fastDummies)
library(broom)
# import dataset
getwd()
setwd("C:/Users/user/Desktop/Dissertation Projects/Project 1/data")
enteric_data <- read_excel("Data for enteric virus MSc.xlsx", 
                  sheet = "04VZ metadata_707_long_edited_1")

# Exploring each variable
dim(enteric_data)
# [1] 707  88
# There is 707 observations and 88 features in this dataset.

# Questions:
# 1. In what parts of Vietnam (or Dong Thap central city)
# the (common) viruses are observed most? 
# Or how the common/uncommon viruses are distributed 
# in this area?
# centralcity distribution
enteric_data %>% 
  count(CentrallyCity) %>% 
  arrange(desc(n)) %>% 
  mutate(prop = paste0(round(100*n/sum(n), 2), "%"))

# Visualize the area for common, uncommon and unclassified virus
common_virus <- c("Kobuvirus", "Mamastrovirus", "Mastadenovirus", 
                  "Norovirus", "Rotavirus", "Sapovirus")

vrius_type <- enteric_data %>% 
  dplyr::select(PatientNo, CentrallyCity, LONGITUDE, 
                LATITUDE, 56:87) %>% 
  pivot_longer(cols = Alphapapillomavirus:Unclassifiedvirus, 
               names_to = "Virus", values_to = "Freq") %>% 
  filter(Freq == 1) %>%
  mutate(VirusType = ifelse(Virus %in% common_virus, "common",
                            ifelse(Virus == "Unclassifiedvirus", 
                                   "unclassified", "uncommon"))) %>%
  dplyr::select(-Virus) %>% 
  group_by(PatientNo, CentrallyCity, LONGITUDE, LATITUDE, VirusType) %>% 
  summarize(n=n()) %>% 
  pivot_wider(names_from = VirusType, values_from = n)

# The distribution of CentrallyCity for virus
data_city <- vrius_type %>%
  group_by(CentrallyCity) %>% 
  summarise(n=n()) %>%
  mutate(prop = round((n/sum(n))*100, 2)) %>% 
  arrange(desc(prop)) %>%
  mutate(lab.ypos = cumsum(prop) - 0.5*prop)
data_city

# The distribution of age by gender
enteric_data %>% 
  dplyr::select(Age, Gender) %>% 
  filter(Gender == 1) %>% 
  ggplot(enteric_data, aes(x = Age)) +
  geom_histogram(fill = "cornflowerblue", 
                 color = "white", 
                 binwidth = 10) + 
  labs(title="Patients by age for ",
       x = "Age")

age_gender <- enteric_data %>% 
  dplyr::select(Age, Gender) %>% 
  mutate(age_group = cut(Age, c(seq(0, 100, 5)), 
                         right = FALSE, include.lowest = TRUE))
  
age_gender %>%   
  count(age_group, Gender) %>%  
  ggplot(aes(x = age_group, y = n , fill = as.factor(Gender))) +
  geom_bar(stat = "identity") +
  labs(title="The distribution of Age by Gender", 
       x ="Age", y = "the number of patients") + 
  scale_fill_manual(values=c("#56B4E9", "#0072B2"), 
                    name="Gender",
                    breaks=c("1", "2"),
                    labels=c("Male", "Female")) 
  theme(axis.text.x = element_text(angle=45))

# how the common/uncommon viruses are distributed 
# in this area
dist_common <- enteric_data %>% 
  dplyr::select(CentrallyCity, ProvincialCity, 56:87) %>% 
  pivot_longer(cols = Alphapapillomavirus:Unclassifiedvirus, 
               names_to = "Virus", values_to = "Freq") %>% 
  filter(CentrallyCity == "Dong Thap", Freq == 1, Virus %in% common_virus) %>%
  group_by(CentrallyCity, ProvincialCity) %>%
  summarise(Total_Count = sum(Freq)) %>%
  arrange(desc(Total_Count))
  
dist_common
  
ggplot(dist_common, aes(ProvincialCity, Total_Count)) + 
  geom_bar(stat = "identity", fill="steelblue", width = 0.85) +
  geom_text(aes(label = Total_Count), vjust= 1, color = "black", size = 5)+
  theme(text = element_text(size = 13)) +
  coord_flip() +
  scale_x_discrete(limits=c("Lai Vung", "Chau Thanh", "Tam Nong",   
                            "Thap Muoi", "Lap Vo", "Thanh Binh",     
                            "TP. Cao Lanh", "Cao Lanh")) +
  labs(title="The common virus distribution in Dong Thap", 
       x="Provincial City", y="number of virus")
  
dist_uncommon <- enteric_data %>% 
  dplyr::select(CentrallyCity, ProvincialCity, 56:87) %>% 
  pivot_longer(cols = Alphapapillomavirus:Unclassifiedvirus, 
               names_to = "Virus", values_to = "Freq") %>% 
  filter(CentrallyCity == "Dong Thap", Freq == 1, !Virus %in% common_virus) %>%
  group_by(CentrallyCity, ProvincialCity) %>%
  summarise(Total_Count = sum(Freq)) %>%
  arrange(desc(Total_Count))
  
dist_uncommon
  
ggplot(dist_uncommon, aes(ProvincialCity, Total_Count)) + 
  geom_bar(stat = "identity", fill="steelblue", width = 0.85) +
  geom_text(aes(label = Total_Count), vjust= 1, color = "black", size = 5)+
  theme(text = element_text(size = 13)) +
  coord_flip() +
  scale_x_discrete(limits=c("Thi Xa Hong Ngu", "Thap Muoi", "Tam Nong",   
                            "Chau Thanh", "Lap Vo", "Thanh Binh",     
                            "Cao Lanh", "TP. Cao Lanh")) +
  labs(title="The uncommon virus distribution in Dong Thap", 
       x="Provincial City", y="number of virus")
  
  
# Compare the prevalence of different common enteric viruses
prevalence <- enteric_data %>% 
  dplyr::select(PatientNo, common_virus, is_coinf) %>% 
  pivot_longer(cols = Kobuvirus:Sapovirus, 
               names_to = "virus", values_to = "situation") %>% 
  filter(is_coinf != "NA", situation == 1) %>% 
  mutate(is_coinf = ifelse(is_coinf == 1, "single virus", "coinfection")) %>% 
  group_by(virus, is_coinf) %>% 
  summarise(n = n()) %>%
  mutate(proportion = paste0(round(100 * n / sum(n), 2), "%"))
  
#    virus          is_coinf         n proportion
#    <chr>          <chr>        <int> <chr>     
#  1 Kobuvirus      coinfection      4 80%       
#  2 Kobuvirus      single virus     1 20%       
#  3 Mamastrovirus  coinfection     14 63.64%    
#  4 Mamastrovirus  single virus     8 36.36%    
#  5 Mastadenovirus coinfection     27 52.94%    
#  6 Mastadenovirus single virus    24 47.06%    
#  7 Norovirus      coinfection     59 66.29%    
#  8 Norovirus      single virus    30 33.71%    
#  9 Rotavirus      coinfection     49 32.45%    
# 10 Rotavirus      single virus   102 67.55%    
# 11 Sapovirus      coinfection     42 73.68%    
# 12 Sapovirus      single virus    15 26.32%
  
prevalence$virus <- factor(prevalence$virus, levels = c(
  "Rotavirus", "Norovirus", 
  "Sapovirus", "Mastadenovirus", 
  "Mamastrovirus", "Kobuvirus"))

ggplot(prevalence, aes(x = virus, y = n))+ 
  geom_col(aes(fill = is_coinf), width = 0.9) +
  scale_x_discrete(label=abbreviate)+
  theme(text = element_text(size = 13), 
        axis.text.x = element_text(color = "black", size = 13)) +
  labs(title="The relation between common virus and infection", 
       x ="common virus", y = "the number of illness") + 
  scale_fill_manual(values=c("#56B4E9", "#0072B2"), 
                    name="infection situation") 

# Questions:
# 2. What are the risk factors corresponding to the coinfections?
data <- enteric_data
data <- data %>% 
  mutate(LATITUDE_h = ifelse(SiteRecruitment == 2, 12.66522, 
                             ifelse(SiteRecruitment == 4, 10.47634, 
                                    ifelse(SiteRecruitment == 5, 16.462706, 
                                           12.248679))), 
         LONGITUDE_h = ifelse(SiteRecruitment == 2, 108.05533, 
                              ifelse(SiteRecruitment == 4, 105.611971, 
                                     ifelse(SiteRecruitment == 5, 107.587915, 
                                            109.191941)))) %>% 
  mutate(is_coinf = ifelse(is_coinf == "NA", "no viruses",
                           ifelse(is_coinf == "1", 
                                  "single virus", "coinfection"))) %>% 
  mutate(distance = round(distHaversine(cbind(LONGITUDE, LATITUDE),
                                        cbind(LONGITUDE_h, LATITUDE_h))/1000, 0))

data %>% 
  dplyr::select(is_coinf) %>% 
  group_by(is_coinf) %>%
  summarise (count = n()) %>%
  mutate(proportion = paste0(round(100 * count / sum(count), 2), "%")) %>% 
  ggplot(aes(is_coinf, count)) + 
  geom_bar(stat = "identity", fill="steelblue", width = 0.85) +
  geom_text(aes(label = count), vjust= 1, color = "white", size = 5)+
  theme(text = element_text(size = 14), axis.title.x=element_blank(), 
        axis.text.x = element_text(color = "black", size = 14)) +
  scale_x_discrete(limits=c("no viruses", "single virus", 
                            "coinfection")) +
  labs(title="The infection distribution", 
       y = "number of patients")

# is_coinf     count proportion
# <chr>        <int> <chr>     
# 1 coinfection    190 26.87%    
# 2 no viruses     267 37.77%    
# 3 single virus   250 35.36% 

# create a new variables about month of hospital entry that 
# could help to explore coinfection depends on season or not, like 
# rainy season or dry season

factor <- c("Age", "Gender", "ContactDiar", 
            "Tap", "Well", "Rain", "River", "Pond", 
            "Bottled", "KeepAnimal", "KillingAnimal", 
            "EatCookRawMeat", "IF_Bacterial", "distance")

data_factor <- data %>% 
  dplyr::select(factor, is_coinf)

# separte the continuous variables and categorical variables
feature <- names(data_factor)
conti <- c("Age", "distance")
cate_feature <- feature[!feature %in% conti]
cont_feature <- feature[feature %in% conti]

# exam the correlation between two categorical variables using 
# chi-square test
# Hypotheses: 
# null:variables are independent of one another

pvale_result_cate <- data.frame(feature = cate_feature, 
                                p_value = rep(NA, length(cate_feature)))
row <- 1
for (iFeature in cate_feature){
  vec <- pull(data_factor, iFeature)
  t <- table(vec, data_factor$is_coinf)
  pvale_result_cate$p_value[row] <- 
    fisher.test(t, simulate.p.value = TRUE)$ p.value
  row = row + 1
}

pvale_result_cate %>% 
  arrange(p_value) %>% 
  filter(p_value <= 0.05)

# result:
#    feature      p_value
# 1   Gender 0.0004997501
# 2 is_coinf 0.0004997501
# 3     Well 0.0089955022

# We can can find that the variables of SiteRecruitment, 
# Gender and Well are not independent variables with is_coinf.

# exam the correlation between two categorical variables using 
# One-Way ANOVA test
# Hypotheses: 
# null:variables are independent of one another
pvale_result_cont <- data.frame(feature = cont_feature, 
                                p_value = rep(NA, length(cont_feature)))
row <- 1
for (iFeature in cont_feature){
  vec <- pull(data_factor, iFeature)
  pvale_result_cont$p_value[row] <- 
    oneway.test(vec ~ data_factor$is_coinf, na.action = na.omit, 
                var.equal=T)$p.value
  row = row + 1
}

pvale_result_cont %>% 
  arrange(p_value) %>% 
  filter(p_value <= 0.05)
#    feature      p_value
# 1      Age 2.836485e-19
# 3 distance 3.036090e-05

# We can can find that the variables of Age 
# and distance are not independent variables with is_coinf.

data_risk_factor <- data %>% 
  dplyr::select(PatientNo, CentrallyCity, SiteRecruitment, 
                LONGITUDE, LATITUDE, Well, Gender, Age, 
                distance, is_coinf) 

p <- colorFactor(palette = c("saddlebrown", "blue", "red"), 
                 domain = c("no viruses", "single virus", "coinfection"),
                 ordered = T)
cus_icon <- makeIcon(
  iconUrl = "https://img.icons8.com/cotton/64/000000/find-clinic.png",
  iconWidth = 38, iconHeight = 38,
  iconAnchorX = 15, iconAnchorY = 35)

map_site_2 <- leaflet() %>% 
  addTiles() %>%
  
  # Add 3 marker groups
  addMarkers(lng=108.05533, lat=12.66522, icon = cus_icon, popup="Site Recruitment - 2") %>% 
  #addMarkers(lng=108.05533, lat=12.66522, popup="The birthplace of R") %>%
  addCircleMarkers(data = data_risk_factor %>% filter(SiteRecruitment == 2, 
                                                      is_coinf == "no viruses"), 
                   lng=~LONGITUDE , lat=~LATITUDE, radius = 5, color = "saddlebrown", 
                   weight = 1, fillOpacity = 1, group = "no viruses") %>%
  addCircleMarkers(data = data_risk_factor %>% filter(SiteRecruitment == 2, 
                                                      is_coinf == "single virus"),
                   lng=~LONGITUDE , lat=~LATITUDE, radius = 5, color = "blue",
                   weight = 1, fillOpacity = 1, group = "single virus") %>%
  addCircleMarkers(data = data_risk_factor %>% filter(SiteRecruitment == 2, 
                                                      is_coinf == "coinfection"),
                   lng=~LONGITUDE , lat=~LATITUDE, radius = 5, color = "red",
                   weight = 1, fillOpacity = 1, group = "coinfection") %>%
  addLegend(position = "topright", pal = p, values = c("no viruses", "single virus", "coinfection"), 
            title = "infection situation")

map_site_2

map_site_4 <- leaflet() %>% 
  addTiles() %>%
  
  # Add 3 marker groups
  addMarkers(lng = 105.611971, lat = 10.47634, icon = cus_icon, popup="Site Recruitment - 4") %>% 
  # addMarkers(lng= 105.611971, lat = 10.47634, popup="The birthplace of R") %>%
  addCircleMarkers(data = data_risk_factor %>% filter(SiteRecruitment == 4, 
                                                      is_coinf == "no viruses"), 
                   lng=~LONGITUDE , lat=~LATITUDE, radius=5, color = "saddlebrown", 
                   weight = 1, fillOpacity = 1, group = "no viruses") %>%
  addCircleMarkers(data = data_risk_factor %>% filter(SiteRecruitment == 4, 
                                                      is_coinf == "single virus"),
                   lng=~LONGITUDE , lat=~LATITUDE, radius=5, color = "blue",
                   weight = 1, fillOpacity = 1, group = "single virus") %>%
  addCircleMarkers(data = data_risk_factor %>% filter(SiteRecruitment == 4, 
                                                      is_coinf == "coinfection"),
                   lng=~LONGITUDE , lat=~LATITUDE, radius=5, color = "red",
                   weight = 1, fillOpacity = 1, group = "coinfection") %>%
  addLegend(position = "topright", pal = p, values = c("no viruses", "single virus", "coinfection"), 
            title = "infection situation")

map_site_4

map_site_5 <- leaflet() %>% 
  addTiles() %>%
  
  # Add 3 marker groups
  addMarkers(lng = 107.587915, lat = 16.462706, icon = cus_icon, popup="Site Recruitment - 5") %>% 
  # addMarkers(lng= 107.587915, lat = 16.462706, popup="The birthplace of R") %>%
  addCircleMarkers(data = data_risk_factor %>% filter(SiteRecruitment == 5, 
                                                      is_coinf == "no viruses"), 
                   lng=~LONGITUDE , lat=~LATITUDE, radius=5, color = "saddlebrown", 
                   weight = 1, fillOpacity = 1, group = "no viruses") %>%
  addCircleMarkers(data = data_risk_factor %>% filter(SiteRecruitment == 5, 
                                                      is_coinf == "single virus"),
                   lng=~LONGITUDE , lat=~LATITUDE, radius=5, color = "blue",
                   weight = 1, fillOpacity = 1, group = "single virus") %>%
  addCircleMarkers(data = data_risk_factor %>% filter(SiteRecruitment == 5, 
                                                      is_coinf == "coinfection"),
                   lng=~LONGITUDE , lat=~LATITUDE, radius=5, color = "red",
                   weight = 1, fillOpacity = 1, group = "coinfection") %>%
  addLegend(position = "topright", pal = p, values = c("no viruses", "single virus", "coinfection"), 
            title = "infection situation")

map_site_5

map_site_6 <- leaflet() %>% 
  addTiles() %>%
  
  # Add 3 marker groups
  addMarkers(lng = 109.191941, lat = 12.248679, icon = cus_icon, popup="Site Recruitment - 6") %>% 
  # addMarkers(lng= 109.191941, lat = 12.248679, popup="The birthplace of R") %>%
  addCircleMarkers(data = data_risk_factor %>% filter(SiteRecruitment == 6, 
                                                      is_coinf == "no viruses"), 
                   lng=~LONGITUDE , lat=~LATITUDE, radius=5, color = "saddlebrown", 
                   weight = 1, fillOpacity = 1, group = "no viruses") %>%
  addCircleMarkers(data = data_risk_factor %>% filter(SiteRecruitment == 6, 
                                                      is_coinf == "single virus"),
                   lng=~LONGITUDE , lat=~LATITUDE, radius=5, color = "blue",
                   weight = 1, fillOpacity = 1, group = "single virus") %>%
  addCircleMarkers(data = data_risk_factor %>% filter(SiteRecruitment == 6, 
                                                      is_coinf == "coinfection"),
                   lng=~LONGITUDE , lat=~LATITUDE, radius=5, color = "red",
                   weight = 1, fillOpacity = 1, group = "coinfection") %>%
  addLegend(position = "topright", pal = p, values = c("no viruses", "single virus", "coinfection"), 
            title = "infection situation")

map_site_6

data_risk_factor %>% 
  dplyr::select(SiteRecruitment) %>% 
  count(SiteRecruitment)
#   SiteRecruitment     n
#             <dbl> <int>
# 1               2    23
# 2               4   670
# 3               5     6
# 4               6     8

data_risk_factor %>% 
  dplyr::select(CentrallyCity, SiteRecruitment) %>%
  count(CentrallyCity, SiteRecruitment)
#  CentrallyCity    SiteRecruitment     n
#  <chr>                      <dbl> <int>
# 1 Dak Lak                        2    20
# 2 Dak Nong                       2     3
# 3 Dong Thap                      4   670
# 4 Khanh Hoa                      6     8
# 5 Quang Binh                     5     1
# 6 Quang Tri                      5     3
# 7 Thua Thien - Hue               5     2

d <- data_risk_factor %>% 
  dplyr::select(SiteRecruitment, is_coinf, distance) %>% 
  group_by(SiteRecruitment, is_coinf) %>% 
  summarise(avg_dis = mean(distance), n=n())
#    SiteRecruitment CentrallyCity    is_coinf     avg_dis     n
#              <dbl> <chr>            <chr>          <dbl> <int>
#  1               2 Dak Lak          coinfection    29.6      7
#  2               2 Dak Lak          no viruses      9.83     6
#  3               2 Dak Lak          single virus   11.6      7
#  4               2 Dak Nong         coinfection    47        2
#  5               2 Dak Nong         single virus   36        1
#  6               4 Dong Thap        coinfection    10.1    170
#  7               4 Dong Thap        no viruses      8.27   261
#  8               4 Dong Thap        single virus    9.24   239
#  9               5 Quang Binh       coinfection   158        1
# 10               5 Quang Tri        coinfection    69        2
# 11               5 Quang Tri        single virus   56        1
# 12               5 Thua Thien - Hue coinfection    35        1
# 13               5 Thua Thien - Hue single virus   24        1
# 14               6 Khanh Hoa        coinfection    13        7
# 15               6 Khanh Hoa        single virus    5        1

data_model <- data_risk_factor %>% 
  dplyr::select(-LONGITUDE, -LATITUDE, -PatientNo)

data_model$Well <- as.numeric(data_model$Well) + 1
data_model$Gender <- factor(data_model$Gender)
data_model$SiteRecruitment <- factor(data_model$SiteRecruitment)
data_model$is_coinf <- factor(data_model$is_coinf)
data_model <- dummy_cols(data_model, select_columns = c("is_coinf"))

head(data_model)

model_risk_factor_without_site <- "model {
  # prior 
  beta0 ~ dnorm(beta.mu.0, beta.sigma.0) 
  beta.age ~ dnorm(beta.mu.0, beta.sigma.0)
  beta.distance ~ dnorm(beta.mu.0, beta.sigma.0)
  beta.gender[1] <- 0
  beta.gender[2] ~ dnorm(beta.mu.0, beta.sigma.0)
  beta.well[1] ~ dnorm(beta.mu.0, beta.sigma.0)
  beta.well[2] <- 0

  #Likelihood
  for(i in 1:n) { 
    logit(mu[i]) <- beta0+beta.age*Age[i] + 
    beta.gender[Gender[i]] + beta.well[Well[i]] + 
    beta.distance*distance[i]
    
    is_coinf[i] ~ dbern(mu[i]) 
  }
}"

model_risk_factor <- "model {
  # prior 
  beta0 ~ dnorm(beta.mu.0, beta.sigma.0) 
  beta.age ~ dnorm(beta.mu.0, beta.sigma.0)
  beta.distance ~ dnorm(beta.mu.0, beta.sigma.0)
  beta.gender[1] <- 0
  beta.gender[2] ~ dnorm(beta.mu.0, beta.sigma.0)
  beta.well[1] ~ dnorm(beta.mu.0, beta.sigma.0)
  beta.well[2] <- 0
  tau.alpha <- 1/pow(sigma.alpha,2)
  sigma.alpha ~ dunif(0, sigma.alpha.ub)
  
  # priors for independent intercepts per county 
  alpha[1] <- 0
  alpha[2] ~ dnorm(0, tau.alpha)
  alpha[3] <- 0
  alpha[4] ~ dnorm(0, tau.alpha)
  alpha[5] ~ dnorm(0, tau.alpha)
  alpha[6] ~ dnorm(0, tau.alpha)

  #Likelihood
  for(i in 1:n) { 
    logit(mu[i]) <- beta0+beta.age*Age[i] + 
    beta.gender[Gender[i]] + beta.well[Well[i]] + 
    beta.distance*distance[i] + alpha[SiteRecruitment[i]]
    
    is_coinf[i] ~ dbern(mu[i]) 
  }
}"
n <- nrow(data_model)
data_coinf <- list(n = n, is_coinf = data_model$is_coinf_coinfection, 
                   Age = data_model$Age, 
                   Gender = data_model$Gender, 
                   distance = data_model$distance,
                   SiteRecruitment = data_model$SiteRecruitment,
                   Well = data_model$Well, 
                   beta.mu.0 = 0, 
                   beta.sigma.0 = 0.01, sigma.alpha.ub = 10)

num.chains <- 3 
# Run JAGS  
results_conif <- jags.model(file = textConnection(model_risk_factor), 
                            data = data_coinf, 
                            n.chains = num.chains)
# Burn-in of 8000 iterations 
update(results_conif, n.iter = 8000)
# Longer run for making inferences, assuming chains have converged 
results_conif_long <- coda.samples(results_conif, variable.names = c("beta.age", 
                                                                     "beta.distance", "beta.gender[2]", "beta.well[1]",
                                                                     "alpha[2]", "alpha[4]", "alpha[5]", "alpha[6]"), 
                                   n.iter = 15000)
# Trace plots and density
par(mar = c(3,3,3,3))
plot(results_conif_long)

# Compute the Gelman-Rubin statistic
par(mfrow=c(2,2))
gelman.plot(results_conif_long)
gelman.diag(results_conif_long)

# summary(results_conif_long)
tidyMCMC(results_conif_long, conf.int = TRUE, conf.method = "HPDinterval")
#   term           estimate std.error conf.low conf.high
#   <chr>             <dbl>     <dbl>    <dbl>     <dbl>
# 1 alpha[2]        0.0317    0.609    -1.16      1.20  
# 2 alpha[4]        2.81      1.36      0.240     5.48  
# 3 alpha[5]       -0.0199    4.46     -9.60      9.77  
# 4 alpha[6]       -0.0224    4.44     -9.66      9.53  
# 5 beta.age       -0.0214    0.00431  -0.0300   -0.0133
# 6 beta.distance   0.0310    0.0101    0.0110    0.0508
# 7 beta.gender[2] -0.00504   0.184    -0.369     0.351 
# 8 beta.well[1]   -0.703     0.632    -1.94      0.560 
dic_conif <- dic.samples(model = results_conif, n.iter = 15000, type = "pD")
dic_conif
# Mean deviance:  765.6 
# penalty 7.144 
# Penalized deviance: 772.8 

data_coinf_without_site <- list(n = n, is_coinf = data_model$is_coinf_coinfection, 
                                Age = data_model$Age, 
                                Gender = data_model$Gender, 
                                distance = data_model$distance,
                                Well = data_model$Well, 
                                beta.mu.0 = 0, 
                                beta.sigma.0 = 0.01)

num.chains <- 3 
# Run JAGS  
results_conif_without_site <- jags.model(file = textConnection(model_risk_factor_without_site), 
                                         data = data_coinf_without_site, 
                                         n.chains = num.chains)
# Burn-in of 8000 iterations 
update(results_conif_without_site, n.iter = 8000)
# Longer run for making inferences, assuming chains have converged 
results_conif_without_site_long <- coda.samples(results_conif_without_site, 
                                                variable.names = c("beta.age", 
                                                                   "beta.distance", 
                                                                   "beta.gender[2]", 
                                                                   "beta.well[1]"), 
                                                n.iter=15000)
# Trace plots and density
par(mar = c(3,3,3,3))
plot(results_conif_without_site_long)

# Compute the Gelman-Rubin statistic
par(mfrow=c(2,2))
gelman.plot(results_conif_without_site_long)
gelman.diag(results_conif_without_site_long)

# summary(results_conif_long)
tidyMCMC(results_conif_without_site_long, conf.int = TRUE, conf.method = "HPDinterval")
#   term           estimate std.error conf.low conf.high
#   <chr>             <dbl>     <dbl>    <dbl>     <dbl>
# 1 beta.age        -0.0213   0.00422  -0.0296   -0.0131
# 2 beta.distance    0.0298   0.00954   0.0109    0.0483
# 3 beta.gender[2]  -0.0199   0.181    -0.371     0.335 
# 4 beta.well[1]    -0.818    0.466    -1.72      0.0856
dic_conif_without_site <- dic.samples(model = results_conif_without_site, 
                                      n.iter=15000, type="pD")
dic_conif_without_site
# Mean deviance:  774.7 
# penalty 5.076 
# Penalized deviance: 779.8  
diffdic(dic_conif, dic_conif_without_site)
# Difference: -6.79707
# Sample standard error: 6.254929
# The result of diffdic negative that means the model
# dic_conif is preferred.

data_single <- list(n = n, is_coinf = data_model$`is_coinf_single virus`, 
                    Age = data_model$Age, 
                    Gender = data_model$Gender, 
                    distance = data_model$distance,
                    SiteRecruitment = data_model$SiteRecruitment,
                    Well = data_model$Well, 
                    beta.mu.0 = 0, 
                    beta.sigma.0 = 0.01, sigma.alpha.ub = 10)

# Run JAGS  
results_single <- jags.model(file = textConnection(model_risk_factor), 
                             data = data_single, 
                             n.chains = num.chains)
# Burn-in of 8000 iterations 
update(results_single, n.iter = 8000)
# Longer run for making inferences, assuming chains have converged 
results_single_long <- coda.samples(results_single, variable.names = c("beta.age", 
                                                                       "beta.distance", "beta.gender[2]", "beta.well[1]",
                                                                       "alpha[2]", "alpha[4]", "alpha[5]", "alpha[6]"), 
                                    n.iter=15000)
# Trace plots and density
par(mar = c(3,3,3,3))
plot(results_single_long)

# Compute the Gelman-Rubin statistic
par(mfrow=c(2,2))
gelman.plot(results_single_long)
gelman.diag(results_single_long)

# summary(results_single_long)
tidyMCMC(results_single_long, conf.int = TRUE, conf.method = "HPDinterval")
#   term           estimate std.error conf.low conf.high
#   <chr>             <dbl>     <dbl>    <dbl>     <dbl>
# 1 alpha[2]       -0.763     0.640    -2.00     0.395  
# 2 alpha[4]       -1.69      1.34     -4.29     0.447  
# 3 alpha[5]        0.00777   3.66     -8.51     7.79   
# 4 alpha[6]        0.00739   3.64     -7.96     8.18   
# 5 beta.age       -0.0112    0.00320  -0.0176  -0.00508
# 6 beta.distance  -0.00677   0.00930  -0.0254   0.0112 
# 7 beta.gender[2] -0.299     0.164    -0.622    0.0167 
# 8 beta.well[1]    1.69      0.794     0.246    3.22   
dic_single <- dic.samples(model = results_single, n.iter=15000, type="pD")
dic_single
# Mean deviance:  897.3 
# penalty 6.91
# Penalized deviance: 904.2 

data_single_without_site <- list(n = n, is_coinf = data_model$`is_coinf_single virus`, 
                                 Age = data_model$Age, 
                                 Gender = data_model$Gender, 
                                 distance = data_model$distance,
                                 Well = data_model$Well, 
                                 beta.mu.0 = 0, 
                                 beta.sigma.0 = 0.01)

num.chains <- 3 
# Run JAGS  
results_single_without_site <- jags.model(file = textConnection(model_risk_factor_without_site), 
                                          data = data_single_without_site, 
                                          n.chains = num.chains)
# Burn-in of 8000 iterations 
update(results_single_without_site, n.iter = 8000)
# Longer run for making inferences, assuming chains have converged 
results_single_without_site_long <- coda.samples(results_single_without_site, 
                                                 variable.names = c("beta.age", 
                                                                    "beta.distance", 
                                                                    "beta.gender[2]", 
                                                                    "beta.well[1]"), 
                                                 n.iter=15000)
# Trace plots and density
par(mar = c(3,3,3,3))
plot(results_single_without_site_long)

# Compute the Gelman-Rubin statistic
par(mfrow=c(2,2))
gelman.plot(results_single_without_site_long)
gelman.diag(results_single_without_site_long)

# summary(results_conif_long)
tidyMCMC(results_single_without_site_long, conf.int = TRUE, conf.method = "HPDinterval")
#   term           estimate std.error conf.low conf.high
#   <chr>             <dbl>     <dbl>    <dbl>     <dbl>
# 1 beta.age       -0.0109    0.00318  -0.0171 -0.00463 
# 2 beta.distance  -0.00306   0.00868  -0.0200  0.0139  
# 3 beta.gender[2] -0.317     0.162    -0.632  -0.000969
# 4 beta.well[1]    1.16      0.577     0.0483  2.30 
dic_single_without_site <- dic.samples(model = results_single_without_site, 
                                       n.iter=15000, type="pD")
dic_single_without_site
# Mean deviance:  899.6 
# penalty 4.956 
# Penalized deviance: 904.5  
diffdic(dic_single, dic_single_without_site)

data_no_virus <- list(n = n, is_coinf = data_model$`is_coinf_no viruses`, 
                      Age = data_model$Age, 
                      Gender = data_model$Gender, 
                      distance = data_model$distance,
                      SiteRecruitment = data_model$SiteRecruitment,
                      Well = data_model$Well, 
                      beta.mu.0 = 0, 
                      beta.sigma.0 = 0.01, sigma.alpha.ub = 10)

# Run JAGS  
results_no_virus <- jags.model(file = textConnection(model_risk_factor), 
                               data = data_no_virus, 
                               n.chains = num.chains)
# Burn-in of 8000 iterations 
update(results_no_virus, n.iter = 8000)
# Longer run for making inferences, assuming chains have converged 
results_no_virus_long <- coda.samples(results_no_virus, variable.names = c("beta.age", 
                                                                           "beta.distance", "beta.gender[2]", "beta.well[1]",
                                                                           "alpha[2]", "alpha[4]", "alpha[5]", "alpha[6]"), 
                                      n.iter=15000)
# Trace plots and density
par(mar = c(3,3,3,3))
plot(results_no_virus_long)

# Compute the Gelman-Rubin statistic
par(mfrow=c(2,2))
gelman.plot(results_no_virus_long)
gelman.diag(results_no_virus_long)

# summary(results_no_virus_long)
tidyMCMC(results_no_virus_long, conf.int = TRUE, conf.method = "HPDinterval")
#   term           estimate std.error conf.low conf.high
#   <chr>             <dbl>     <dbl>    <dbl>     <dbl>
# 1 alpha[2]         1.53     0.833    -0.0364   3.14   
# 2 alpha[4]        -3.82     3.86    -12.0      1.35   
# 3 alpha[5]         0.0134   5.18    -11.4     11.1    
# 4 alpha[6]         0.0214   5.17    -11.2     11.4    
# 5 beta.age         0.0237   0.00310   0.0175   0.0297 
# 6 beta.distance   -0.0317   0.0116   -0.0544  -0.00915
# 7 beta.gender[2]   0.343    0.172     0.0183   0.689  
# 8 beta.well[1]    -1.37     0.816    -2.92     0.209  
dic_no_virus <- dic.samples(model = results_no_virus, n.iter=15000, type="pD")
dic_no_virus
# Mean deviance:  841.7 
# penalty 7.125 
# Penalized deviance: 848.8  

data_no_virus_without_site <- list(n = n, is_coinf = data_model$`is_coinf_no viruses`, 
                                   Age = data_model$Age, 
                                   Gender = data_model$Gender, 
                                   distance = data_model$distance,
                                   Well = data_model$Well, 
                                   beta.mu.0 = 0, 
                                   beta.sigma.0 = 0.01)

num.chains <- 3 
# Run JAGS  
results_no_virus_without_site <- jags.model(file = textConnection(model_risk_factor_without_site), 
                                            data = data_no_virus_without_site, 
                                            n.chains = num.chains)
# Burn-in of 8000 iterations 
update(results_no_virus_without_site, n.iter = 8000)
# Longer run for making inferences, assuming chains have converged 
results_no_virus_without_site_long <- coda.samples(results_no_virus_without_site, 
                                                   variable.names = c("beta.age", 
                                                                      "beta.distance", 
                                                                      "beta.gender[2]", 
                                                                      "beta.well[1]"), 
                                                   n.iter=15000)
# Trace plots and density
par(mar = c(3,3,3,3))
plot(results_no_virus_without_site_long)

# Compute the Gelman-Rubin statistic
par(mfrow=c(2,2))
gelman.plot(results_no_virus_without_site_long)
gelman.diag(results_no_virus_without_site_long)

# summary(results_conif_long)
tidyMCMC(results_no_virus_without_site_long, conf.int = TRUE, conf.method = "HPDinterval")
#   term           estimate std.error conf.low conf.high
#   <chr>             <dbl>     <dbl>    <dbl>     <dbl>
# 1 beta.age         0.0232   0.00306   0.0172    0.0292
# 2 beta.distance   -0.0333   0.0110   -0.0552   -0.0121
# 3 beta.gender[2]   0.381    0.170     0.0391    0.708 
# 4 beta.well[1]    -0.129    0.523    -1.11      0.945 
dic_no_virus_without_site <- dic.samples(model = results_no_virus_without_site, 
                                         n.iter=15000, type="pD")
dic_no_virus_without_site
# Mean deviance:  850 
# penalty 4.836 
# Penalized deviance: 854.8  

# 3. Whether/how coinfection impacts the disease severity?
# At first, we can use the symptom and length of stay to define
# the disease severity

# symptom : ThreeDaysFever, BloodStool, MucoidStool, NumberDiarEpi, 
# AbdominalPain
disease_severity <- c("ThreeDaysFever", "BloodStool", "MucoidStool", 
                      "NumberDiarEpi", "AbdominalPain",
                      "Length of stay")

# if patient stay in hopstial more than 3 days that means
# 
data_severity <- data %>% 
  select(PatientNo, disease_severity, is_coinf) %>% 
  filter(ThreeDaysFever != 9, 
         BloodStool != 9, 
         MucoidStool != 9, 
         AbdominalPain != 9, 
         NumberDiarEpi != "NA", 
         is_coinf != "no viruses") %>% 
  gather(key, val, -PatientNo, -is_coinf, -NumberDiarEpi, 
         -`Length of stay`) %>%
  mutate(val = ifelse(val == 2, 0, 1)) %>%
  spread(key, val) %>%
  mutate(extend_stay = ifelse(`Length of stay` > 3, 1, 0), 
         acuteDiar = ifelse(as.numeric(NumberDiarEpi) <= 14, 1, 0))

# Yes=1, No=0
data_severity$ThreeDaysFever <- as.factor(data_severity$ThreeDaysFever)
data_severity$BloodStool <- as.factor(data_severity$BloodStool)
data_severity$MucoidStool <- as.factor(data_severity$MucoidStool)
data_severity$AbdominalPain <- as.factor(data_severity$AbdominalPain)
data_severity$extend_stay <- as.factor(data_severity$extend_stay)
data_severity$acuteDiar <- as.factor(data_severity$acuteDiar)
data_severity$is_coinf <- as.factor(data_severity$is_coinf)
data_severity$is_coinf <- relevel(data_severity$is_coinf, ref="single virus")

fit_fever <- glm(ThreeDaysFever ~ is_coinf, 
                 family = binomial(), 
                 data = data_severity)
summary(fit_fever)
# p value = 0.0776
exp(cbind(coef(fit_fever), confint(fit_fever))) 
#                                  2.5 %   97.5 %
# (Intercept)         0.975000 0.7554453 1.258018
# is_coinfcoinfection 1.422222 0.9628649 2.106765

fit_blood <- glm(BloodStool ~ is_coinf, 
                 family = binomial(), 
                 data = data_severity)
summary(fit_blood)
# p value = 0.113
exp(cbind(coef(fit_blood), confint(fit_blood))) 
#                                      2.5 %     97.5 %
# (Intercept)         0.02155172 0.007674446 0.04689329
# is_coinfcoinfection 2.45647058 0.833243585 8.11618734

fit_mucoid <- glm(MucoidStool ~ is_coinf, 
                  family = binomial(), 
                  data = data_severity)
summary(fit_mucoid)
# p value = 0.0315
exp(cbind(coef(fit_mucoid), confint(fit_mucoid))) 
#                                    2.5 %    97.5 %
# (Intercept)         0.1285714 0.08421838 0.1883044
# is_coinfcoinfection 1.8237548 1.05693992 3.1747021

fit_absominal <- glm(AbdominalPain ~ is_coinf, 
                     family = binomial(), 
                     data = data_severity)
summary(fit_absominal)
# p value = 0.3708
exp(cbind(coef(fit_absominal), confint(fit_absominal))) 
#                                   2.5 %    97.5 %
# (Intercept)         0.7173913 0.5529561 0.9273185
# is_coinfcoinfection 0.8338745 0.5591313 1.2399875

fit_stat <- glm(extend_stay ~ is_coinf, 
                family = binomial(), 
                data = data_severity)
summary(fit_stat)
# p value = 0.3667
exp(cbind(coef(fit_stat), confint(fit_stat))) 
#                                   2.5 %   97.5 %
# (Intercept)         1.3235294 1.0246504 1.714859
# is_coinfcoinfection 0.8355556 0.5653282 1.234315

fit_diar <- glm(acuteDiar ~ is_coinf, 
                family = binomial(), 
                data = data_severity)
summary(fit_diar)
# p value = 0.402
exp(cbind(coef(fit_diar), confint(fit_diar))) 
#                                     2.5 %    97.5 %
# (Intercept)         28.6250000 15.1513922 63.231332
# is_coinfcoinfection  0.6598738  0.2430648  1.760247
