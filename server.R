library(shiny)
library(yaml)
require(shinysky)
library(igraph)
source("R/query.r")
source("R/db.r")

# Define server logic for random distribution application
shinyServer(function(input, output, session, clientData) {
  ## Set character encoding, shiny server does not use
  ## system locale like the R environment does
  Sys.setlocale("LC_ALL", "en_US.UTF-8")

  ## Establish database connection
  global.conf <- "conf/user_database.conf"
  conf <- connect.db(global.conf)

  ## Get the parameters from url
  person.id   <- "p.id" # globally unique person id
  cluster.id  <- "c.id" # globally unique cluster id
  project.name <- "project.name"
  project.id <- "project.id" 
  project.version <- "project.version"
  query <- reactive({ parseQueryString(clientData$url_search) })
  output$url <- renderText({
        # Return a string with key-value pairs
        #as.character(query()[person.id])
        paste(names(query()), query(), sep = "=", collapse=", ")
      })

  ## Make database query to get developers and graph data
  community.data <- reactive({
    f.name <- as.character(query()["f.name"])
    l.name <- as.character(query()["l.name"])
    project <- as.character(query()["project"])
    rev <- as.character(query()["revision"])
    dev.name <- paste(f.name, l.name)
    p.id <- query.person.id(conf$con, dev.name)
    c.id <- query.person.cluster(conf$con, p.id)
    
    if(is.null(p.id) | is.null(c.id)) {
      ## Run in demo mode
      p.id <- 1
      c.id <- 1
      get.person.cluster(conf$con, p.id, c.id)
    }
    else {
      get.person.cluster(conf$con, p.id, c.id)
    }
  })

  ## == Outputs ==
  ## Graph Output
  output$dev.graph <- renderPlot({
                        ## Get igraph object
                        g <- community.data()$g
                        
                        weight.factor <- 4 / max(log(E(g)$weight))
                        edge.weight <- weight.factor * log(E(g)$weight) 
                        ## igraph only allows a single arrow size
                        arrow.weight <- 0.75

                        ## Compute graph layout
                        layout <- community.data()$layout
                        scale <- 1 #input$graph.scale
                        node.size <- input$node.size
                        label.size <- input$node.label.size / 5
                        layout.exp <- layout.norm(layout,-1*scale, scale,
                                                  -1*scale, scale)

                        plot(g,
                             edge.width=edge.weight,
                             vertex.size=node.size,
                             vertex.shape="circle",
                             vertex.label.cex=label.size,
                             vertex.label.dist=0.25,
                             layout= layout.exp,
                             edge.arrow.size= arrow.weight,
                             rescale=FALSE,
                             xlim=c(-scale,scale),
                             ylim=c(-scale,scale))
                       })

  ## Use server-side renderText to generate html content
  ## We have to do this because sending text to the server side requires the
  ## text to be in between div tags, this causes problems when you want the
  ## text to be all on the same line. This problem is solved by just sending
  ## the entire div block text
  output$intro <- renderText({
                   project <- community.data()$project.name
                   version <- community.data()$project.version
                   get.intro(project, version)})

  output$q.1 <- renderText({
                  project <- community.data()$project.name
                  version <- community.data()$project.version
                  get.question.1(project, version)})

  output$q.2 <- renderText({
                  project <- community.data()$project.name
                  version <- community.data()$project.version
                  get.question.2(project, version)})

  output$q.3 <- renderText({
                  project <- community.data()$project.name
                  version <- community.data()$project.version
                  get.question.3(project, version)})

  output$q.4 <- renderText({
                  project <- community.data()$project.name
                  version <- community.data()$project.version
                  get.question.4(project, version)})

  output$q.5 <- renderText({
                  project <- community.data()$project.name
                  version <- community.data()$project.version
                  get.question.5(project, version)})

  output$q.7 <- renderText({
                  project <- community.data()$project.name
                  version <- community.data()$project.version
                  get.question.7(project, version)})

  ## Output developer list
  output$dev.1.name  <- renderText({ name <- community.data()$person.list.sample[[1]]$name })
  output$dev.1.email <- renderText({ email <- community.data()$person.list.sample[[1]]$email })
  output$dev.2.name  <- renderText({ name <- community.data()$person.list.sample[[2]]$name })
  output$dev.2.email <- renderText({ email <- community.data()$person.list.sample[[2]]$email })
  output$dev.3.name  <- renderText({ name <- community.data()$person.list.sample[[3]]$name })
  output$dev.3.email <- renderText({ email <- community.data()$person.list.sample[[3]]$email })
  output$dev.4.name  <- renderText({ name <- community.data()$person.list.sample[[4]]$name })
  output$dev.4.email <- renderText({ email <- community.data()$person.list.sample[[4]]$email })
  output$dev.5.name  <- renderText({ name <- community.data()$person.list.sample[[5]]$name })
  output$dev.5.email <- renderText({ email <- community.data()$person.list.sample[[5]]$email })
  output$dev.6.name  <- renderText({ name <- community.data()$person.list.sample[[6]]$name })
  output$dev.6.email <- renderText({ email <- community.data()$person.list.sample[[6]]$email })
  output$dev.7.name  <- renderText({ name <- community.data()$person.list.sample[[7]]$name })
  output$dev.7.email <- renderText({ email <- community.data()$person.list.sample[[7]]$email })
  output$dev.8.name  <- renderText({ name <- community.data()$person.list.sample[[8]]$name })
  output$dev.8.email <- renderText({ email <- community.data()$person.list.sample[[8]]$email })
  output$dev.9.name  <- renderText({ name <- community.data()$person.list.sample[[9]]$name })
  output$dev.9.email <- renderText({ email <- community.data()$person.list.sample[[9]]$email })
  output$dev.10.name  <- renderText({ name <- community.data()$person.list.sample[[10]]$name })
  output$dev.10.email <- renderText({ email <- community.data()$person.list.sample[[10]]$email })

  ## Set value tag for hidden inputs to form
  ## the hidden input is used to send data from server-side to form response
  ## e.g., we need to send the ids of the developers which is sampled on
  ## the server-side but then needs to be send with the form data
  observe({
    for (i in 1:10) {
      updateTextInput(session, paste("devId", i, sep=""),
                      value=community.data()$person.list.sample[[i]]$g.Id)
      updateTextInput(session, paste("devName", i, sep=""),
                      value=community.data()$person.list.sample[[i]]$name)
    }
    
    dataset <- community.data()$project.persons
    valueKey <- "email1"
    tokens <- dataset$name
    template <- HTML("{{name}} &lt;{{email1}}&gt;")
    updateTextInput.typeahead(session, "proj_names", dataset, valueKey, tokens, template)
    dataset <- community.data()$clust.names
    valueKey <- "name"
    tokens <- dataset$name
    template <- HTML("{{name}}")
    updateTextInput.typeahead(session, "clust_names", dataset, valueKey, tokens, template)
    updateTextInput(session, "respondentId", value=as.character(query()[person.id]))
    updateTextInput(session, "respondentName", value=community.data()$respondent.name)
    updateTextInput(session, "respondentEmail", value=community.data()$respondent.email)
    updateTextInput(session, "clustId", value=as.character(query()[cluster.id]))
    updateTextInput(session, "projName", value=community.data()$project.name)
    updateTextInput(session, "projId", value=community.data()$project.id)
    updateTextInput(session, "projVersion", value=community.data()$project.version)
    updateTextInput(session, "indexError", value=community.data()$index.error)
  })
})

output.something <- function(text) {
  print(text)
}

get.person.cluster <- function(con, person.id, cluster.id) {

  ## Get cluster edge list
  edge.list <- query.cluster.edges(con, cluster.id)

  ## Create igraph object
  g <- graph.data.frame(edge.list, directed=TRUE,)
  V(g)$g.Id <- V(g)$name

  ## Sanity check, person exists in cluster
  cluster.error <- !any(V(g)$g.Id == person.id)
  
  ## Get person names and emails
  person.list <- lapply(V(g)$g.Id, function(p.id) {
                                person <- query.person.name(con, p.id,
                                                            email=TRUE)
                                person$g.Id <- p.id
                                return(person)})

  ## Error string for indicating and index mismatch
  index.error.str <- "error: index mismatch"

  V(g)$name <- lapply(1:length(person.list),
                       function(i) {
                         if(person.list[[i]]$g.Id == V(g)$g.Id[i]) {
                           name <- person.list[[i]]$name
                         }
                         else {
                           name <- index.error.str
                         }
                        return(name)
                       })

  clust.names <- data.frame(name=unlist(V(g)$name))  

  ## Error flag for mapping graph index to person names
  ## set true when two indices do not agree
  index.error <- any(V(g)$name==index.error.str)
  
  ## Get respondent email
  respondent = query.person.name(con, person.id, email=TRUE)

  ## Identify person in graph with red node
  V(g)$color <- ifelse(V(g)$g.Id==person.id, "red", "gray")

  ## Perform layout here to avoid recomputing
  layout <- layout.kamada.kawai(g, niter=400)

  ## sample community, omit respondent
  person.list.to.sample <- person.list[!(V(g)$g.Id==person.id)]
  person.sample <- person.list.sample(person.list.to.sample, 10)

  ## query for project data
  project.data <- query.project.data(con, cluster.id)
  
  ## query for project person list
  project.persons <- query.project.persons(con, project.data$id)
  
  ## clean NA from persons
  project.persons[is.na(project.persons)] <- "NA"
  person.sample[is.na(person.sample)] <- "NA"
  person.list[is.na(person.list)] <- "NA"
  respondent[is.na(respondent)] <- "NA"
  clust.names$name <- lapply(clust.names$name, as.character)  
  clust.names[is.na(clust.names)] <- "NA"

  ## return values
  res <- list()
  res$g <- g
  res$layout <- layout
  res$clust.names <- clust.names
  res$person.list <- person.list
  res$person.list.sample <- person.sample
  res$respondent.email <- respondent$email
  res$respondent.name <- respondent$name
  res$project.name <- project.data$name
  res$project.version <- project.data$cycle
  res$project.id <- project.data$id
  res$project.persons <- project.persons
  res$index.error <- as.integer(index.error || cluster.error)
  return(res)
}

person.list.sample <- function(person.list, samp.size) {
  list.len <- length(person.list)
  samp.diff <- 0

  samples <- sample(1:list.len, min(samp.size, list.len))

  person.sample <- lapply(samples, function(i) person.list[[i]])
  
  if (samp.size > list.len) {
    samp.diff <- samp.size - list.len
    samp.size <- list.len
    null.person <- data.frame(name=NA, email=NA, g.id=NA)
    person.sample.null <- lapply(1:samp.diff, function (i) null.person)
    person.sample <- append(person.sample, person.sample.null)
  }
  
  return(person.sample)
}

get.intro <- function(project, version) {
  ## Text for introduction section
  t.1 <- "Thank you for taking the time to participate in our survey. You have
          been selected for this survey because of your contributions to "
  t.2 <- " during the development of "
  t.3 <- ". Several of the following questions will address the concept of collaboration that
          exists during software development in open-source projects. The nature
          of a collaborative relationship between two developers can manifest in
          a number of ways, such as, a coordinated development effort mediated
          by direct communication. Alternatively, an implicit collaborative relationship
          can exist by virtue of similar interests or expertise resulting in
          contributions to related software features or components, although in
          this case, no 
          direct communication link exists. We characterize collaboration in a
          broad scope, in which the nature of the relationship can arise from
          both explicit and implicit means. Please consider this definition of
          collaboration when formulating your responses. We also ensure that
          your responses will not be publicly released so you can rest assured
          that your responses will remain private."
  res <- paste(t.1, project, t.2, version, t.3, sep="")

  return(res)
}

get.question.1 <- function(project, version) {
  t.1 <- "Approximately how many developers did you collaborate with on"
  t.2 <- "during the development of"
  q <- paste(t.1, project, t.2, version)
  res <- paste(q, "?", sep="")
  return(res)
}

get.question.2 <- function(project, version) {
  t.1 <- "Whom did you closely collaborate with on"
  t.2 <- "during the development of"
  q <- paste(t.1, project, t.2, version)
  res <- paste(q, "?", sep="")
  return(res)
}

get.question.3 <- function(project, version) {
  t.1 <- "Whom do you consider to be highly influential in"
  t.2 <- "during the development of"
  q <- paste(t.1, project, t.2, version)
  res <- paste(q, "?", sep="")
  return(res)
}

get.question.4 <- function(project, version) {
  t.1 <- "What is the level of influence you had in"
  t.2 <- "during the development of"
  q <- paste(t.1, project, t.2, version)
  res <- paste(q, "?", sep="")
  return(res)
}

get.question.5 <- function(project, version) {
  t <- "What was the magnitude of collaboration you had with the
      following individuals during the development of"
  q <- paste(t, project, version,
      sep=" ")
  res <- paste(q,"?", sep="")
  return(res)
}

get.question.7 <- function(project, version) {
  t.1 <- "What development roles did you participate in"
  t.2 <- "during the development of"
  q <- paste(t.1, project, t.2, version)
  res <- paste(q, "?", sep="")
  return(res)
}
