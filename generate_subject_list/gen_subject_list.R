source("R/config.r")
source("R/query.r")

## Configuration Parameters
sample.size <- 5
min.clust.size <- 5
num.servers <- 7
host <- "codeface-survey.de:3838/survey_"

## Sample a cluster of developers
## dev.clusters: a list (clusters) of lists (developers ids in that cluster)
## n: the number of developers to sample from each cluster
sample.clusters <- function(dev.clusters, n) {
  sample.list <- lapply(dev.clusters, function(ids) {
			size <- min(n, length(ids))
                        if(size==1){
                          return(ids)
                        } else {
			  return (sample(ids, size))
                        }})
  return(sample.list)
}

## Generate the survey string containing all the necessary data
## to construct the survey url
generate.survey.string <- function(dev.df, clusters.sample) {
  total.survey.list <- list()
  for(c.id in names(clusters.sample)) {
    cluster.data <- dev.df[dev.df$clusterId == c.id,][1,]
    dev.ids <- as.character(unlist(clusters.sample[c.id]))
    string.list <- lapply(dev.ids, 
                         function (p.id) {
                           str <- c()
                           str$project.id <- as.character(cluster.data$id)
                           str$name <- cluster.data$name
                           str$tag <- cluster.data$tag
                           str$p.id <- p.id
                           str$c.id <- c.id
                           str$email <- dev.df[dev.df$personId==p.id, "email"]
                         return(str)
                       })
    total.survey.list <- append(total.survey.list, string.list)
  }
  return(total.survey.list)
}

## Generates the individual urls given the survey list and the
## location of the application server (host)
generate.email.url.list <- function(host, survey.list) {
  server.ids <- 1:num.servers
  email.url.list <- do.call(rbind, lapply(survey.list, 
                                    function (x) {
                                      email <- x$email
				                              # randomly select a survey application, we select for a number 1-4
                                      # to uniformly distribute the links across multiple servers
                                      # this is because shiny-server (free) will only allow 15 connections
                                      # per application before it bounces a connection
                                      server.id <- sample(server.ids, 1) 
                                      url <- paste(host, server.id, "/?p.id=", x$p.id, "&c.id=", x$c.id, sep="")
		                                  project <- x$name
                                      revision <- x$tag
                                      res <- data.frame(email, url, project, revision)
                                      return(res)
                                    }))
  return(email.url.list)
}

## Check that all developers are in the clusters we expect them in
sanity.check <- function(con, survey.list) {
  
  ##verify that sanity check works, by reversing query parameters
  sane.list.check <- lapply(survey.list, 
                       function(x) {
                        res <- query.sanity.survey(con, as.integer(x$p.id), as.integer(x$c.id)) == 1
                       return(res)})
  sane.check <- all(unlist(sane.list.check))
  if(sane.check) {
    warning("Sanity check failed!")
  }
  
  ## Perform real sanity check
  sane.list <- lapply(survey.list, 
                      function(x) {
                        res <- query.sanity.survey(con, as.integer(x$c.id), as.integer(x$p.id)) == 1
                        return(res)})
  sane <- all(unlist(sane.list))

  return(sane)
}

remove.prev.respondents <- function(new.df, old.df) {
  old.ids <- lapply(as.character(old.df$url), function(url) {strsplit(strsplit(url,"&")[[1]][1], "=")[[1]][2]})
  old.ids <- as.integer(unlist(old.ids))
  rmv.ids <- intersect(new.df$personId, old.ids)
  rmv.emails <- intersect(new.df$email, old.df$email)
  df.rmv.ids <- new.df[!(new.df$personId %in% rmv.ids),]
  df.rmv.ids.emails <- df.rmv.ids[!(df.rmv.ids$email %in% rmv.emails),]
  return(df.rmv.ids.emails)
}

##******************************
##            Main
##******************************
## Establish database connection
global.conf <- "conf/database.conf"
conf <- connect.db(global.conf)

## load old email list
old.df <- read.table("generate_subject_list/emails_and_urls.txt", header=TRUE)

dev.df <- query.per.dev.clusters(conf$con, min.clust.size)

## Add emails to survey list
email <- lapply(dev.df$personId,
                  function(x) {
                    x <- query.person.name(conf$con, x, email=TRUE)$email
                  return(x)
                })

dev.df <- data.frame(dev.df, email=unlist(email))

dev.df <- remove.prev.respondents(dev.df, old.df)

clusters <- split(dev.df$personId, dev.df$clusterId)

clusters.sample <- sample.clusters(clusters, sample.size)

survey.subject.list <- generate.survey.string(dev.df, clusters.sample)

## Sanity check, varify that each person does exist in the cluster we expect
sane <- sanity.check(conf$con, survey.subject.list)

if(sane) {
  ## Create dataframe with columns email and unique url for participant
  email.url.list <- generate.email.url.list(host, survey.subject.list)
  
  ## Output file
  file.name = "generate_subject_list/emails_and_urls_tag.txt"
  write.table(email.url.list, file.name, row.names=FALSE, sep=" ")
  
  message(paste("Output file written to \"", file.name, "\"",sep=""))
} else {
  stop("Sanity check failed")
}

## check that none of the email addresses match
new.df <- read.table("generate_subject_list/emails_and_urls_tag.txt", header=TRUE)
matches <- (old.df$email %in% new.df$email)

if(any(matches)) {
  print(old.df$email[matches])
  stop("Error: matches in email lists")
} else{
  message("Output successful")
}
