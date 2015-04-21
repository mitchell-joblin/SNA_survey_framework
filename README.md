## Description
This survey framework allows you to quickly generate interactive surveys to validate social network analysis approaches.
The survey is designed to be deployed as a web application and all survey results are automatically stored into a MySQL database.
Since the framework is written in R, it requires very little effort to take existing R infrastructure and integrate into a survey.
An example survey can be found here: http://rfhinf067.hs-regensburg.de/survey/?p.id=1&c.id=1.

## Required Programs
* Install GNU R, mysql

  Add `deb http://cran.r-project.org/bin/linux/ubuntu precise/`
  to `/etc/apt/sources.list`, and execute

        sudo -E apt-get update
        sudo -E apt-get install r-base r-base-dev

## R package dependencies

* Install the required R packages in an R shell with

        install.packages(c("igraph", "shiny", "yaml", "lubridate",
                           "shinysky", "logging", "plyr", "stringr",
                           "RMySQL"), dependencies=T)

## Loading a test database

* A filled database is required to run the application, a test database has been included in the repository

* To load the test database, first create a database user (e.g., codeface) then navigate to the `User_db` directory and enter the following
        
        mysql -ucodeface -pcodeface < user_data.sql

## Running the Web application

* Run the application by entering the following commands into an R terminal while in the project root directory

        library(shiny)
        runApp(".")
