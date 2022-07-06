Building a Recommender System in R

In this project, I built a recommender system that will recommend movies to users. This will show my strategy for preprocessing data, 
exploring data, and creating the system itself using 'recommenderLab'

'recommenderLab' is a R package that provides a framework to test and develop recommender algorithms. Various algorithms are supported, 
including User-based collaborative filtering (UBCF), item-based collaborative filtering (IBCF), Association rule-based recommender (AR), 
and many more. It was developed in 2016 by Micharl Hahsler.

When doing a market based analysis you want to look at the items in your current basket and predict the next best item(s) that would fit with the present items in the basket. This is a simplified version of item-based collaborative filtering; collecting preferences or taste information from many users allows you to make associations between the present items and associated items. Instead of items in a basket, we hve genres in a movie, and the model will output which genre is most often associated with the input genres. 




 
