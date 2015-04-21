suppressPackageStartupMessages(library(RMySQL))
suppressPackageStartupMessages(library(stringr))
suppressPackageStartupMessages(library(plyr))
suppressPackageStartupMessages(library(logging))

query.project.name <- function(con, pid) {
  dat <- dbGetQuery(con, str_c("SELECT name FROM project WHERE id=", sq(pid)))

  return(dat$name)
}

## Query an edgelist for a given cluster. Note that for single-contributor
## clusters, there are no edges, so we need to take this case into account.
query.cluster.edges <- function(con, cluster.id) {
  dat <- dbGetQuery(con, str_c("SELECT * FROM ",
                               "edgelist WHERE clusterId=", cluster.id))

  if (dim(dat)[1] > 0) {
    return(dat[,c("fromId", "toId", "weight")])
  } else {
    return(NULL)
  }
}


## Map a systematic person ID to a proper name
## We consider the caser person.id because this can eliminate the need for
## special casing in the caller
query.person.name <- function(con, person.id, email=FALSE) {
  if (is.na(person.id)) {
    return(NA)
  }

  if (email) {
    dat <- dbGetQuery(con, str_c("SELECT name, email1 as email FROM person WHERE id=", person.id))
    if (dim(dat)[1] > 0) {
      return(dat[, c("name", "email")])
    }
  }
  else {
    dat <- dbGetQuery(con, str_c("SELECT name FROM person WHERE id=", person.id))
    if (dim(dat)[1] > 0) {
      return(dat$name)
    }
  }

  return(NA)
}


query.project.data <- function (con, cluster.id) {
  query <- str_c("SELECT project.id, name, cycle FROM cluster, project, revisions_view
                  WHERE cluster.id=", cluster.id)
  res <- dbGetQuery(con, query)
  return(res)
}


query.project.data <- function (con, cluster.id) {
  query <- str_c("SELECT project.id, name, cycle FROM cluster, project, revisions_view
                 WHERE cluster.projectId=project.id
                 AND revisions_view.releaseRangeID=cluster.releaseRangeId
                 AND cluster.id=", cluster.id)
  res <- dbGetQuery(con, query)
  return(res)
}


query.sanity.survey <- function (con, cluster.id, person.id) {
  query <- str_c("SELECT count(*) sane FROM codeface.cluster_user_mapping
                 WHERE clusterId=", cluster.id,
                 " AND personId=", person.id)
  res <- dbGetQuery(con, query)
  return(res)
}


query.project.persons <- function (con, project.id) {
  query <- str_c("SELECT name, email1 FROM codeface.person
        WHERE projectId=", project.id)
  res <- dbGetQuery(con, query)
  res$name <- as.character(res$name)
  Encoding(res$name) <- "UTF-8"
  return(res)
}


query.person.id <- function(con, name) {
  query <- str_c("SELECT id FROM person
                WHERE name=", sq(name))
  res <- dbGetQuery(con, query)

  if(nrow(res) == 0) {
    res <- NULL
  }
  else {
    res <- res$id[[1]]
  }
  return(res)
}

query.person.cluster <- function(con, p.id) {
  query <- str_c("SELECT clusterId FROM cluster_user_mapping, cluster
                 WHERE clusterNumber != -1
                 AND clusterMethod=\'Spin Glass Community\'
                 AND personId=", sq(p.id))
  res <- dbGetQuery(con, query)
  return(res$clusterId)
}



