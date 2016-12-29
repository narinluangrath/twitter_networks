library(streamR)
library(ROAuth)
library(RCurl)
library(RJSONIO)
library(igraph)
library(rjson)

# Collects tweets that match the pattern track_this for 
# timeout_min minutes. Saves these tweets using the name
# file_name to the location file_location.

get_tweets <- function(file_name, track_this, timeout_min, file_location) {
  setwd(file_location)
  
  requestURL = "https://api.twitter.com/oauth/request_token"
  accessURL = "https://api.twitter.com/oauth/access_token"
  authURL = "https://api.twitter.com/oauth/authorize"
  
  consumerKey = "[removed]"
  consumerSecret = "[removed]"
  
  download.file(url="http://curl.haxx.se/ca/cacert.pem",
                destfile="cacert.pem")
  
  my_oauth = OAuthFactory$new(consumerKey=consumerKey,
                              consumerSecret=consumerSecret,
                              requestURL=requestURL,
                              accessURL=accessURL, authURL=authURL)
  
  my_oauth$handshake(cainfo = "cacert.pem")

  timeout_sec = timeout_min * 60
  filterStream(file.name=file_name,
               track=track_this,
               timeout=timeout_sec,
               oauth=my_oauth )
}

# Example: Collect tweets with the hashtag #Star
get_tweets("star.txt", "#Star", 60, "C:/users/nluangrath/Desktop")
