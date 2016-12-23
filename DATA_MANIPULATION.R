library(RCurl)
library(RJSONIO)
library(igraph)
library(rjson)

# Generates a retweet network and relevent statistics from the
# tweets in file_name. We assume file_name is a text file of 
# tweets generated using the function in GET_TWEETS.R. 
# Nodes in this network users and an edge A -> B exists only
# if B mentions or retweets A.
#
# Prints to the console the top five users with highest 
# betweenness centrality. Saves to the file_location
# several graphs relevent to the network.

get_data <- function(file_name, file_location) {
  setwd(file_location)
  
  from <- character(0)
  to <- character(0)
  
  tweets <- readLines(file_name)
  non_empty_index = nchar(tweets) > 0
  tweets = tweets[non_empty_index]
  for (tweet in tweets) {
    tweet_parsed <- try(fromJSON(tweet), silent = T)
    if (class(tweet_parsed) == "try-error") {next}
    
    to_name <- tweet_parsed$user$screen_name
    
    if (length(tweet_parsed$retweeted_status) > 0) {
      from_name <- tweet_parsed$retweeted_status$user$screen_name
      from <- c(from, from_name)
      to <- c(to, to_name)
    }
    
    mentions = tweet_parsed$entities$user_mentions
    for (mention in mentions) {
      from_name <- mention$screen_name
      from <- c(from, from_name)
      to <- c(to, to_name)
    }
  }
  
  g_df <- data.frame(from, to)
  g <- graph_from_data_frame(g_df, directed=F)
  
  
  subg <- function(name) {
    new_from <- character(0)
    new_to <- character(0)
    for (i in 1:length(from)) {
      if (from[i] == name) {
        new_from <- c(new_from, from[i])
        new_to <- c(new_to, to[i])
      }
      if (to[i] == name) {
        new_from <- c(new_from, from[i])
        new_to <- c(new_to, to[i])       
      }
    }
    if (length(new_from) > 0) {
      new_g = graph_from_data_frame(data.frame(new_from, new_to), directed=T)
      pdf(paste(name, ".pdf", sep=""))
      plot(new_g,      
           edge.arrow.size=0.5, 
           vertex.label.cex=0.5, 
           vertex.label.family="Helvetica",
           vertex.label.font=2,
           vertex.shape="circle", 
           vertex.size=1, 
           vertex.label.color="red", 
           edge.width=0.25,
           main=name)
      dev.off()
    }
  }
  
  bet_array <- as.array(betweenness(g))
  top_bet <- sort(bet_array, decreasing=T)[1:5]
  
  print("Top betweenness values")
  print(top_bet)

  V(g)$color <- "grey"
  V(g)[names(top_bet)]$color <- "blue"
  
  num_verts <- length(V(g))
  vert_sizes <- rep(1, num_verts)
  names(vert_sizes) <- names(V(g))
  vert_sizes[names(top_bet)] <- rep(4, 5)
  
  vert_labels <- rep(NA, num_verts) 
  names(vert_labels) <- names(V(g))
  vert_labels[names(top_bet)] <- names(V(g)[names(top_bet)])
  
  pdf(paste(file_name, ".pdf", sep=""))
  plot(g, 
       vertex.size=vert_sizes, 
       vertex.label=vert_labels, 
       main=file_name,      
       edge.arrow.size=0.5, 
       vertex.label.cex=0.5, 
       vertex.label.family="Helvetica",
       vertex.label.font=2,
       vertex.shape="circle", 
       vertex.label.color="red", 
       edge.width=0.5)
  dev.off()
  
  dg <- decompose.graph(g)
  g_connect <- dg[[1]]
  
  bet_array <- as.array(betweenness(g_connect))
  top_bet <- sort(bet_array, decreasing=T)[1:5]
  
  print("Top betweenness values (in largest connected subgraph)")
  print(top_bet)
  
  V(g_connect)$color <- "grey"
  V(g_connect)[names(top_bet)]$color <- "blue"
  
  num_verts <- length(V(g_connect))
  vert_sizes <- rep(1, num_verts)
  names(vert_sizes) <- names(V(g_connect))
  vert_sizes[names(top_bet)] <- rep(4, 5)
  
  vert_labels <- rep(NA, num_verts) 
  names(vert_labels) <- names(V(g_connect))
  vert_labels[names(top_bet)] <- names(V(g_connect)[names(top_bet)])
  
  pdf(paste("largest_component.pdf", sep=""))
  plot(g_connect,        
       vertex.size=vert_sizes, 
       vertex.label=vert_labels, 
       main=file_name,      
       edge.arrow.size=0.75, 
       vertex.label.cex=0.5, 
       vertex.label.family="Helvetica",
       vertex.label.font=2,
       vertex.shape="circle", 
       vertex.label.color="red", 
       edge.width=0.5,
       main="largest_component")
  dev.off()
    
  for (name in names(top_bet)) {
    subg(name)
  }
  
  g <- graph_from_data_frame(g_df, directed=T)
  print("# times they were retweeted (out-degree)")
  print(degree(g, mode="out")[names(top_bet)])
  print("# times they retweeted (in-degree)")
  print(degree(g, mode="in")[names(top_bet)])
}

get_data("rogue_one.txt", "C:/users/nluangrath/Desktop")