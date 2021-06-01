#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinythemes)
library(shinyWidgets)
library(dplyr)
library(tidyverse)
library(patchwork)

df1 <- readxl::read_excel(here::here("TBC.xlsx")) %>%
    janitor::clean_names()

df2 <- df1 %>%
    rename(
        "class" = "zhi_ye",

        "position1" = "di_yi_zhuan_jing",
        "position2"= "di_er_zhuan_jing")






# Define UI for application that draws a histogram
ui <- fluidPage(

    theme = shinytheme("superhero"),

    navbarPage("糯米团EPGP手册", collapsible = TRUE,

               tabPanel("EPGP制度说明", fluid = TRUE, icon = icon("book"),
                        h3("ep为对工会贡献值"),
                        h3("gp为在工会团拿的所有装备的价值总和"),
                        br(),

                        h3("pr=ep/gp 为下一件装备的需求权利值"),
                        h3("以此公式为基础，就有："),
                        tags$ul(
                            tags$li("需求权利值(pr)高的人先拿装备 (特殊装备除外)”）"),
                            tags$li("需求权利值(pr)相同时Roll点决定"),
                            tags$li("备注：EPGP不会根据副本分开算分而是持续累计 (从T4到T6本的全部统一计分)")
                        ),
                        h3("衰减制度说明"),
                        h4("每周将工会所有人的ep与gp值减少10%。其中gp减少到基础值（100分）不再减少"),
                        tags$ul(
                            tags$li("此举将避免憋分拿装备这种对团队整体提升极端不利的行为发生"),
                            tags$li("也避免了团队老人囤积大量分数，导致新人无法融入团队的现象发生"),
                            tags$li("同样避免了长时间不出勤的人员，出勤就和团队主力竞争装备的现象")
                        ),
                        br(),

                        h3("ep增加规则说明"),
                        tags$ul(
                            tags$li("集合分20分，解散分20分"),
                            tags$li("开荒阶段boss每30分钟10分，不到30分钟按30分钟算"),
                            tags$li("已开荒过的boss每只10分,不同的副本BOSS分可能会不同"),
                            tags$li("替补按正常人员100%比例给分 "),
                            tags$li("备注：EPGP不会根据副本分开算分而是持续累计 (从T4到T6本的全部统一计分)")
                        ),
                        br(),

                        h3("gp增加规则"),
                        tags$ul(
                            tags$li("所有人有基础gp值100分"),
                            tags$li("gp不会衰减小于基础值")
                            )
                        ),
               tabPanel("GP计算器", fluid = TRUE, icon = icon("calculator"),

                        column(4, numericInput("itemLv", label = "输入装备等级",
                                     value = 115,
                                     min = 0,
                                     max = 500),
                        numericInput("rareLv", label = "橙装 = 5； 紫装 = 4； 蓝装 = 3",
                                    value = 4,
                                    min = 3,
                                    max = 5,
                                    step = 1),
                        numericInput("slots", label = "填写装备部位的修正值",
                                    value = 1,
                                    min = 0.5,
                                    max = 1.5),

                        uiOutput("gp")
                        ),
                        column(8,
                               h6("GP计算公式如下图"),
                               img(src = "tab3.png", style = "width: 400px", align = "left"),
                               br(),
                               img(src = "tab1.png", style = "width: 500px", align = "left"),
                               img(src = "tab2.png", style = "width: 300px", align = "left"))
                        ),

               tabPanel("糯米团现有在册人员配置", fluid = TRUE, icon = icon("id-card"),
                        h3("该数据来源是微信群文档 -- 《糯米团第二次人口普查》"),
                        h4("不定期更新，没填的朋友可以去填下"),
                        uiOutput("link"),
                        br(),


                        plotOutput("population")),

               tabPanel("TBC必要任务", fluid = TRUE, icon = icon("exclamation"),
                        h2("必要任务一般为钥匙任务"),
                        h3("不完成这些任务将无法进入指定的副本，比如：不完成卡拉赞钥匙系列任务将无法进入卡拉赞"),
                        br(),
                        h4("卡拉赞钥匙任务 （优先级高）"),
                        p("起始点：卡拉赞副本门口"),
                        p("任务：奥术扰动 + 幽灵的活动（同时完成）"),
                        p("须知：须知：卡拉赞门任务后续需要去时光之穴。
                        时光之穴的进入条件：门口有个巡逻的血精灵NPC，对话之后得到观光任务，耗时5分钟左右。
                          然后先打通救萨尔，才能进入18M —— 18M是卡拉赞钥匙的最后一步"),
                        uiOutput("klz"),
                        br(),

                        h4("毒蛇神殿开门任务"),
                        p("起始点：H奴隶围栏"),
                        p("后续：击杀夜之魇（卡拉赞）和格鲁尔"),
                        uiOutput("dushe"),
                        br(),

                        h4("风暴开门任务（任务链极长！）"),
                        p("起始点：影月谷中间祭坛"),
                        p("后续：需要击杀一些H 5人本的尾王，以及玛瑟里顿"),
                        uiOutput("fengbao"),
                        br(),

                        h4("BT开门任务（任务链很长！）"),
                        p("起始点：占星者/奥尔多 的影月谷营地"),
                        p("任务：巴尔里石板"),
                        uiOutput("bt")

                        ),

               tabPanel("公会政策", fluid = TRUE, icon = icon("search-dollar"),
                        h4("关于萨满"),
                        h5("由于萨满在TBC的raid里面的重要地位，公会对于萨满职业有优待。每个CD衰减完之后，额外获得-15GP （该数值暂定）的奖励。"),
                        br(),
                        h4("关于多修"),
                        h5("所有能多修的职业，拿第二天赋的套装免费，但是不得与其他人的第一天赋竞争"),
                        h5("具体操作方式：拿到第二套套装之后，先加上相应的GP，活动完之后再扣除。"),
                        br(),
                        h4("蛋刀、橙弓  按照EP顺位来获取")
                        )

               )




)



# Define server logic required to draw a histogram
server <- function(input, output) {

    # output$ex1 <- renderPrint({
    #     withMathJax(
    #         helpText("$$4 ^ (\\frac{装等}{45} + 稀有度 - 4) \\times 装备部位修正$$")
    #         )
    # })

    output$gp <- renderUI({

        gp <- round(4 ^((input$itemLv / 45) + (input$rareLv - 4)) * input$slots, 0)


        print(paste0("你选择的装备GP价值为: ",gp)) # how to make
        })

    output$population <- renderPlot({
        p1 <- df2 %>%
            group_by(class) %>%
            ggplot(aes(x =forcats::fct_infreq(class))) +
            geom_bar() +
            labs(x = "职业",
                 y = NULL)




        p2 <- df2 %>%
            # replace_na(class_2nd)
            group_by(position1) %>%
            ggplot(aes(x =forcats::fct_infreq(position1))) +
            geom_bar() +
            labs(x = "专精",
                 y = NULL,
                 title = "第一专精")

        p3 <- df2 %>%
            # replace_na(class_2nd)
            group_by(position2) %>%
            ggplot(aes(x =forcats::fct_infreq(position2))) +
            geom_bar() +
            annotate("text", x = 4, y = 4, label = "未定", color = 'red', size = 10)+
            labs(x = "专精",
                 y = NULL,
                 title = "第二专精")



        p1 +p2/p3
    })

    url <- a("腾讯文档", href = "https://docs.qq.com/sheet/DU05tdnFkYmNoRWZH")

    output$link <- renderUI({
        tagList("点击这个链接:", url)
    })

    url_klz <- a("奥术扰动", href = "http://db.nfuwow.com/70/?quest=9824")

    output$klz <- renderUI({
        tagList("任务以及后续请参考:", url_klz)
    })

    url_dushe <- a("瓦丝琪的印记", href = "http://db.nfuwow.com/70/?quest=10900")

    output$dushe <- renderUI({
        tagList("任务以及后续请参考:", url_dushe)
    })

    url_fengbao <- a("古尔丹之手", href = "http://db.nfuwow.com/70/?quest=10680")

    output$fengbao <- renderUI({
        tagList("任务以及后续请参考:", url_fengbao)
    })

    url_bt <- a("巴尔里石板", href = "http://db.nfuwow.com/70/?quest=10568")

    output$bt <- renderUI({
        tagList("任务以及后续请参考:", url_bt)
    })
}

# Run the application
shinyApp(ui = ui, server = server)
