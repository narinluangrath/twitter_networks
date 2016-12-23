# twitter_networks
R scripts to collect tweets and analyze the retweet network

This project was inspired by the following article: http://www.sciencedirect.com/science/article/pii/S0747563215300625

The author analyzes the retweet/mention network for tweets containing the hashtag #RaceTogether but looking at users with the highest betweenness centrality. This code provides an automated method for finding and analyzing the top 5 users with the highest betweeness centrality for any keyword (e.g. #RaceTogether, #Starbucks, #Computers, etc.)

GET_TWEETS.R contains a single function get_tweets(file_name, track_this, timout_min, file_location), which you can use to collect tweets.
- file_name is a string representing the name of the textfile the tweets will be saved to (e.g. "my_tweets.txt")
- track_this is a string representing the tweet keyword you want to track (e.g. "#Aleppo") 
- timeout_min is an integer representing the number of minutes you wish to collect tweets (e.g. 60)
- file_locatoin is a string representing the directory you wish to save the tweets to

For example, running get_tweets("tweets.txt", "#twitter", 60, "C:/users/johndoe/Desktop") will collect tweets containing the hashtag #twitter for 60 minutes and save the results to the Desktop in a text file called "tweets.txt"

You'll need to set up a Twitter app and edit the variables consumerKey and consumerSecret in the GET_TWEETS.R function. This code uses Twitter's Streaming API to collect data.

DATA_MANIPULATION.R contains a single function get_data(file_name, file_location), which analyzes tweets.
- file_name is a string representing the tweets you wish to analyze. We assume file_name is the output generated using GET_TWEETS.R (e.g. "my_tweets.txt").
- file_location is a string representing the file location of file_name (e.g. "C:/users/johndoe/Desktop").

get_data will print multiple graphs (saved as pdf files) to file_location:
- A graph of the entire retweet network. Nodes are users and an edge A -> B exists iff B retweeted or mentioned A.
- A graph of the largest connected component in the entire retweet network (a subgraph).
- A graph of each of the top 5 users with the highest betweenness centrality.


