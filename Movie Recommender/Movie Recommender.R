# Building a Recommender System in R

In this project, I am going to build a recommender system that will recommend 
movies to users! This will show my strategy for preprocessing data, exploring 
data, and creating thie system itself using 'recommenderLab'

'recommenderLab' is a R package that provides a framework to test and develop 
recommender algorithms. Various algorithms are supported, invluding User-based 
collaborative filtering (UBCF), item-based collaborative filtering (IBCF), 
Association rule-based recommender (AR), and many more. It was developed in 
2016 by Micharl Hahsler.

## Load Packages
install.packages("aws.s3")
install.packages("tidyverse")
install.packages("qdapTools")
install.packages("recommenderlab")

library(aws.s3)
library(tidyverse)
library(qdapTools)
library(recommenderlab)


#Load Data
movies <- read.csv ("movies.csv")
ratings <- read.csv ("ratings.csv")
tags <- read.csv ("tags.csv")


#Data Preprocessing
-Create two tables
 - Matrix for recommender model (only numberic values)
 - Cleaned, fully joined table with all data for final output_column()

### 1. Split genres to one genre per column per movie, only keep numeric values
movies_clean <- movies %>%
  cbind(mtabulate(str_split(movies$genres, "\\|"))) %>%
  select(-title, -genres, -'(no genres listed)')

### 2. Add average rating to movies, filter out movies without rating
movies_rated <- movies_clean %>%
  inner_join(ratings, by = "movieId")

### 3. Prepare dataset for recommender engine as matrix
movies_matrix <- movies_rated %>%
  select(-avg_rating) %>%
  column_to_rownames(var = "movieId") %>%
  as.matrix() %>%
  as("binaryRatingMatrix")

### 4. Retrieve full list of genres as a vector
genres <- movies_matrix %>%
  colnames() %>%
  as_tibble()

### 5. Retrieve top 15 of movie tags to filter out rarely used tags
tags_sel <- tags %>%
  filter(!(tag %in% c("sci-fi", "action", "comedy", "BD-R", "funny", "horror", "romance"))) %>% #filter out tags that are genres or irrelevant
  group_by(tag) %>%
  tally() %>%
  slice_max(n, n = 15)

### 6. Retrieve top 15 of movie genres to get idea on most occurring genres or combination of genres
genre_sel <- movies %>%
  group_by(genres) %>%
  tally() %>%
  slice_max(n, n = 15)

### 7. Clean up tags, one per movie, separated by ",", only top 15 tags
tags_valid <- tags %>%
  select(-userId, -timestamp) %>%
  filter(tag %in% tags_sel$tag) %>%
  group_by(movieId) %>%
  mutate(tag = paste0(unique(tag), collapse = ",")) %>%
  unique()

# 8. Add tags column
movies_full <- movies %>%
  inner_join(ratings, by = "movieId") %>%
  left_join(tags_valid, by = "movieId") %>%
  select(-X, -X.1, -X.2, -X.3, -X.4, -X.5, -X.6, -X.7, -X.8, -X.9, -X.10)


### Recommender engine and predictions
When doing a market based analysis you want to look at the items in your current 
basket and predict the next best item(s) that would fit with the present items
in the basket. This is a simplified version of item-based collaborative filtering;
collecting preferences or taste information from many users allows you to make
associations between the present items and associated items. Instead of items
in a basket, we have genres in a movie, and the model will output which genre is
most often associated with the input genres. 


### 1. Set up recommender engine and perform item based collaborative filtering
recom <- Recommender(movies_matrix, method = "IBCF", param = list(k = 5))


### 2. Create user genre choices and preprocess as matrix
genre_choice <- c('Action', 'Adventure', 'Mystery')

genre_choice_matrix <- genres %>%
  mutate(genre = as.numeric(value %in% genre_choice)) %>%
  pivot_wider(names_from = value, values_from = genre) %>%
  as.matrix() %>%
  as("binaryRatingMatrix")


### 3. Make predictions and retrieve highest matching genre
pred <- predict(recom, newdata = genre_choice_matrix, n = 1)
fav_genre <- getList(pred) %>%
  as.character()
fav_rating <- getRatings(pred) %>%
  as.numeric()


### 4. Create user tag choices
The possible tags are:
  
tag_choice <- c("based on a book")


### 5. Retrieve highest rated movies from fav_genre, filter for chosen tag
top5 <- movies_full %>%
  filter(str_detect(movies_full$genres, fav_genre) == TRUE,
        str_detect(movies_full$tag, tag_choice) == TRUE) %>%
  mutate(match = fav_rating * avg_rating) %>%
  arrange(desc( match)) %>%
  select(title, match)
head(top5)
