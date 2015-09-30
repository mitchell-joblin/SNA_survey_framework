## Description
This survey framework allows you to quickly generate interactive surveys to validate social network analysis approaches.
The survey is designed to be deployed as a web application and all survey results are automatically stored into a MySQL database.
Since the framework is written in R, it requires very little effort to take existing R infrastructure and integrate into a survey.
An example survey can be found here: http://rfhinf067.hs-regensburg.de/survey/?p.id=1&c.id=1.

## Required Programs
* Install GNU R, MySQL, and Apache HTTP server

  Add `deb http://cran.r-project.org/bin/linux/ubuntu precise/`
  to `/etc/apt/sources.list`, and execute

```
## First update system
sudo apt-get update

## R
sudo apt-get install r-base r-base-dev

## MySQL
sudo apt-get install mysql-server php5-mysql

## Apache webserver
sudo apt-get install apache2        
```

## R package dependencies

* Install the required R packages in an R shell with
```
install.packages(c("igraph", "shiny", "yaml", "lubridate",
                   "devtools", "logging", "plyr", "stringr",
                   "RMySQL"), dependencies=T)
```
* Install the shinysky packages using devtools by opening an R console and entering:
```
library(devtools)
devtools::install_github("AnalytixWare/ShinySky")
```
## Loading a test database

* A filled database is required to run the application, a test database has been included in the repository

* In the `conf` directory, two configuration files contain the parameters used to connect to the databases
  * `user_database.conf` contains the parameters for connecting to the database storing the user data
  * `survey_db.conf` contains the parameters for connecting to the database storing the survey responses

* To load the test database, first create a database user with the username and password set as `codeface`,
create a database called `user_data`, then navigate to the `User_db` directory and enter the following
```     
## Create a database called user_data
mysql> CREATE DATABASE user_data;
mysql> exit;

## Load the test database
mysql -ucodeface -pcodeface user_data < user_data.sql
```
## Running the Web application

* Run the application by entering the following commands into an R terminal while in the project root directory
```
library(shiny)
runApp(".")
```

## Important files
* server.R
  * The server script for querying the database and presenting the dynamic content to the user interface

* www/index.html
  * The entire user interface for the survey, all survey questions, presentation of R graphics, and the response fields

* www/login.html
  * The login page where survey participants can enter their personal information

* www/process_survey.php
  * The processing script to store responses from the survey into the response database

* conf/user_database.conf 
  * The parameters for connecting to the database storing the user data
  
* conf/survey_db.conf 
  * The parameters for connecting to the database storing the survey responses

* datamodel/survey.mwb
  * The MySQL database model for storing the survey responses
