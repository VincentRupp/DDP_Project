library(ggplot2)

shinyServer(function(input,output) {
  getTreePlot <- function(sec1,sec2,sec3,trunk) {
    
    #Create the tree plot
    p <- ggplot()
    p <- p + scale_x_continuous(limits=c(-40,40))
    p <- p + scale_y_continuous(limits=c(0,100))
    p <- p + geom_polygon(data=sec1,
                          mapping=aes(x=x,y=y),fill="darkgreen")
    p <- p + geom_polygon(data=sec2,
                          mapping=aes(x=x,y=y),fill="darkgreen")
    p <- p + geom_polygon(data=sec3,
                          mapping=aes(x=x,y=y),fill="darkgreen")
    p <- p + geom_polygon(data=trunk,
                          mapping=aes(x=x,y=y),fill="tan4")
    return(p)
  }
  
  getOrnaments <- function(n,sec) {
    ornamentPoints <- data.frame(x=rep(0,n),y=rep(0,n))
    i <- 0
    while (i < n) {
      #generate a random point in the interval
      xpos <- runif(n=1,min=sec[1,"x"],max=sec[4,"x"])
      ypos <- runif(n=1,min=sec[1,"y"],max=sec[2,"y"])
      
      #check if it's below both slanted lines
      #slope of a line: m = (y2-y1)/(x2-x1)
      #point-slope equation of a line: y - y1 = m (x - x1)
      #predicted y-value: yhat = m(xpos - x1) + y1
      m1 <- (sec[2,"y"]-sec[1,"y"])/(sec[2,"x"]-sec[1,"x"])
      m2 <- (sec[4,"y"]-sec[3,"y"])/(sec[4,"x"]-sec[3,"x"])
      yhat1 <- m1*(xpos - sec[1,"x"]) + sec[1,"y"]
      yhat2 <- m2*(xpos - sec[4,"x"]) + sec[4,"y"]
      
      #If it's valid, use the point
      if (ypos <= yhat1 & ypos <= yhat2) {
        i <- i + 1
        ornamentPoints[i,"x"] <- xpos
        ornamentPoints[i,"y"] <- ypos
      }
    }
    return(ornamentPoints)
  }
  
  drawOrnaments <- function(p,ornaments) {
    p <- p + geom_point(data=ornaments,aes(x=x,y=y),shape=19,
                        color=input$ornamentColor,size=input$ornamentSize)
    return(p)
  }
    
  output$p <- renderPlot({
    #Establish three trapezoids to serve as the tree and a rectangular trunk
    #The top of the tree could be a triangle, but ornament-attaching will be
    #more straightforward if they're all the same shape
    sec1 <- data.frame(x=c(-32,-16,16,32),y=c(12,42,42,12))
    sec2 <- data.frame(x=c(-22,-7,7,22),y=c(42,72,72,42))
    sec3 <- data.frame(x=c(-12,-.01,.01,12),y=c(72,96,96,72))
    trunk <- data.frame(x=c(-2,-2,2,2),y=c(12,0,0,12))
    
    #Establish width factor wtree and height factor htree
    wtree <- input$wtree
    htree <- input$htree
    
    #Adjust the actual tree for the width and height scaling
    sec1$x <- sec1$x * wtree
    sec1$y <- sec1$y * htree
    sec2$x <- sec2$x * wtree
    sec2$y <- sec2$y * htree
    sec3$x <- sec3$x * wtree
    sec3$y <- sec3$y * htree
    trunk$x <- trunk$x * wtree
    trunk$y <- trunk$y * htree
    
    p <- getTreePlot(sec1,sec2,sec3,trunk)
    
    area1 <- 0.5*(sec1[2,"y"]-sec1[1,"y"])*sum(abs(sec1[,"x"]))
    area2 <- 0.5*(sec2[2,"y"]-sec2[1,"y"])*sum(abs(sec2[,"x"]))
    area3 <- 0.5*(sec3[2,"y"]-sec3[1,"y"])*sum(abs(sec3[,"x"]))
    areaTotal <- area1 + area2 + area3
    area1 <- area1 / areaTotal
    area2 <- area2 / areaTotal
    area3 <- area3 / areaTotal
    
    #determine how many ornaments to add to each section of the tree
    #min 1 for each section, if enough are requested
    n <- floor(input$n)  #total ornaments
    n3 <- max(1,floor(area3 * n))
    if (n < 3) {n3 <- 0}
    n2 <- max(1,floor(area2*(n-n3)))
    if (n < 2) {n2 <- 0}
    n1 <- max(1,floor(area1*(n-n3-n2)))
    
    #get points for all the ornaments
    if (n3 > 0) {ornaments3 <- getOrnaments(n3,sec3)}
    if (n2 > 0) {ornaments2 <- getOrnaments(n2,sec2)}
    if (n1 > 0) {ornaments1 <- getOrnaments(n1,sec1)}
    
    if (n > 0) {
      ornaments <- rbind(ornaments3,ornaments2,ornaments1)
      p <- drawOrnaments(p,ornaments)
    }
    
   return(p)
    
  })
})