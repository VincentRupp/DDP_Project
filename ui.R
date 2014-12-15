shinyUI(
  fluidPage(
    # Application title
    titlePanel("Decorate a Tree"),
    sidebarPanel(
      sliderInput("wtree","Tree Width",min=0.10,max=1.0,value=1.0,step=0.05),
      sliderInput("htree","Tree Height",min=0.10,max=1.0,value=1.0,step=0.05),
      numericInput('n', 'Number of Ornaments', value=0,
                   min = 0, max = 1000, step = 1),
      selectInput("ornamentColor","Ornament Color",
                  choices=c("firebrick1",
                            "darkolivegreen1",
                            "dodgerblue",
                            "darkseagreen1",
                            "chocolate",
                            "gold")),
      sliderInput("ornamentSize","Ornament Size",min=1,max=10,value=3,step=1),
      submitButton('Submit')
    ),
    mainPanel(
      plotOutput("p")
    ),
    fluidRow(
      h3("Documentation:"),
      p("Use the sliders to control the relative height and width of the tree (1.0 = default)."),
      p("Enter the number of ornaments you'd like to randomly add to the tree."),
      p("Use the drop-down menu to control the color of the ornaments."),
      p("When everything is set how you like, click Submit to see your tree!"),
      p("Note that the tree is reset when you click Submit, so adding ornaments of different sizes and colors is not possible.")
    )
  )
)