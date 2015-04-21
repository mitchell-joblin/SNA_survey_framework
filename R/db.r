suppressPackageStartupMessages(library(RMySQL))
suppressPackageStartupMessages(library(stringr))
suppressPackageStartupMessages(library(lubridate))
suppressPackageStartupMessages(library(yaml))
suppressPackageStartupMessages(library(logging))
basicConfig()

sq <- function(string) {
  return(str_c("'", string, "'"))
}

get.project.id <- function(con, name) {
  res <- dbGetQuery(con, str_c("SELECT id FROM project WHERE name=", sq(name)))

  return(res$id)
}


## Establish the connection and store the relevant configuration
## parameters in the project specific configuration structure
init.db <- function(conf) {
  drv <- dbDriver("MySQL")
  con <- dbConnect(drv, host=conf$dbhost, user=conf$dbuser,
                   password=conf$dbpwd, dbname=conf$dbname)
  conf$pid <- get.project.id(con, conf$project)
  conf$con <- con
  dbGetQuery(con, "SET NAMES utf8")

  if (is.null(conf$pid)) {
    stop("Internal error: No ID assigned to project ", conf$project, "\n",
         "(Did you not run the VCS analysis before the ml analysis?)\n")
  }

  conf <- augment.conf(conf)

  return(conf)
}

## Same in blue for use cases when no single project is considered.
## We augment the configuration with the con object in this case.
## Can also be used to initialise connections inside parallel worker threads.
init.db.global <- function(conf) {
  drv <- dbDriver("MySQL")
  con <- dbConnect(drv, host=conf$dbhost, user=conf$dbuser,
                   password=conf$dbpwd, dbname=conf$dbname)
  conf$con <- con
  dbGetQuery(con, "SET NAMES utf8")
  return(conf)
}

## provided with a configuration file connect to db and return connection object
connect.db <- function(conf.file) {
  conf <- load.config(conf.file)
  conf <- init.db.global(conf)
  return(conf)
}

## Load global and local configuration and apply some sanity checks
## TODO: More sanity checks, better merging of conf objects
load.config <- function(global.file) {
  loginfo(paste("Loading global config file '", global.file, "'", sep=""), logger="config")
  if (!(file.exists(global.file))) {
    stop(paste("Global configuration file", global.file, "does not exist!"))
  }
  conf <- yaml.load_file(global.file)
  
  if (is.null(conf$dbhost) || is.null(conf$dbname) ||
        is.null(conf$dbuser) || is.null(conf$dbpwd)) {
    stop("Malformed global configuration: Database information is incomplete!\n")
  }
  
  return(conf)
}