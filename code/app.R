library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)

# 加载数据
data <- readRDS("data/episode_pca_scores_filtered.rds")

# 20 类别及其颜色映射
categories <- c('Science', 'Technology', 
                'Comedy', 'Music', 'TV & Film', 'Arts', 'Fiction', 
                'Sports', 'Health', 'Lifestyle', 'Parenting', 'Self-Improvement', 
                'Business', 'Culture', 'Society & Culture', 'Religion & Spirituality', 
                'Education', 'History', 
                'News', 'True Crime')

category_colors <- setNames(
  c("#1F77B4", "#5DA5DA", 
    "#FF8C00", "#FFA500", "#FFC107", "#FFD700", "#FFFACD", 
    "#006400", "#2CA02C", "#66C266", "#B8E186", "#DFF0D8", 
    "#E377C2", "#FF69B4", "#FFC0CB", "#FFE4E1", 
    "#A0522D", "#C49A6D", 
    "#7F7F7F", "#CFCFCF"), 
  categories
)

# UI 部分
ui <- fluidPage(
  theme = bslib::bs_theme(bootswatch = "darkly", primary = "#1DB954"),
  titlePanel(h1("Spotify Episode Explorer: Find the Nearest Episodes!", style = "color: #1DB954;")),
  fluidRow(
    column(
      3,
      wellPanel(
        selectizeInput("show_name", "Select Shows:", 
                       choices = unique(data$show_name), 
                       selected = NULL, multiple = TRUE),
        selectInput("name", "Select an Episode:", choices = NULL),
        selectInput("pc1", "Select the First PC:", choices = paste0("PC", 1:10), selected = "PC1"),
        selectInput("pc2", "Select the Second PC:", choices = paste0("PC", 1:10), selected = "PC2")
      )
    ),
    column(
      9,
      tabsetPanel(
        tabPanel(
          "PCA Plot by Show Name",
          plotlyOutput("showPcaPlot", height = "400px")
        ),
        tabPanel(
          "Top 50 Nearest Episodes for specified episode",
          plotlyOutput("nearestPcaPlot", height = "400px"),
          htmlOutput("hoverInfo"),  # 悬停信息输出
          htmlOutput("nearestEpisode")
        )
      )
    ),
    div(
      style = "margin-top:30px; padding:10px; background-color:#1DB954; color:white; text-align:center; font-size:12px;",
      "Designed by Group 7 | Contact Info: wang3337@wisc.edu",
      tags$br(), "Contributor: Yuchen Xu, Yudi Wang"
    )
  )
)

# Server 部分
server <- function(input, output, session) {
  # 更新 Episode 下拉菜单
  observeEvent(input$show_name, {
    if (is.null(input$show_name)) {
      updateSelectInput(session, "name", choices = NULL)
    } else {
      choices <- c(unique(data %>% filter(show_name %in% input$show_name) %>% pull(name)))
      updateSelectInput(session, "name", choices = choices)
    }
  })
  
  # 图 1：多个 Show Name 的数据
  show_data <- reactive({
    validate(need(input$show_name, "Please select at least one Show."))
    data %>% filter(show_name %in% input$show_name) %>%
      mutate(category = show_name)  # 图例为 Show Name
  })
  
  # 图 2：所有数据下的最近邻数据
  nearest_data <- reactive({
    validate(need(input$name, "Please select an Episode under a show."))
    
    # 使用全数据进行最近邻计算
    target_row <- data %>% filter(name == input$name)
    if (nrow(target_row) == 0) return(NULL)
    
    pc1 <- input$pc1
    pc2 <- input$pc2
    distances <- sqrt((data[[pc1]] - target_row[[pc1]])^2 + 
                        (data[[pc2]] - target_row[[pc2]])^2)
    
    data %>%
      mutate(
        distance = distances,
        unique_id = row_number(),  # 添加唯一标识符
        selected = ifelse(name == input$name, "selected", "others"),
        hover_info = paste0(
          "Category: ", category, "<br>",
          "Show Name: ", show_name, "<br>",
          "Episode Name: ", name
        )
      ) %>%
      arrange(distance) %>%
      head(51)
  })
  
  # 图 1：多个 Show Name 的 PCA 图
  output$showPcaPlot <- renderPlotly({
    data_to_plot <- show_data()
    
    # 截断长文本
    data_to_plot <- data_to_plot %>%
      mutate(short_category = stringr::str_trunc(category, width = 15, side = "right"))
    
    gg <- ggplot(data_to_plot, aes_string(x = input$pc1, y = input$pc2, color = "short_category")) +
      geom_point(size = 3, alpha = 0.5) +  # 设置透明度 alpha = 0.6
      labs(
        title = "PCA Plot: Episodes by Show Name",
        x = input$pc1, y = input$pc2
      ) +
      theme_minimal() +
      scale_color_discrete(name = "Show Name") +
      theme(
        legend.key.size = unit(0.5, "cm"),  # 图例项大小
        legend.text = element_text(size = 8),  # 图例文字大小
        legend.title = element_text(size = 10)  # 图例标题大小
      )+
      theme_minimal() +
      theme(
        panel.background = element_rect(fill = "#2E2E2E", color = NA), # 浅灰色背景
        plot.background = element_rect(fill = "#2E2E2E", color = NA),  # 浅灰色画布背景
        legend.background = element_rect(fill = "#2E2E2E", color = NA), # 图例背景
        legend.key = element_rect(fill = "#2E2E2E", color = NA),       # 图例键背景
        legend.text = element_text(size = 8, color = "white"),         # 图例文字颜色
        legend.title = element_text(size = 10, color = "white"),       # 图例标题颜色
        axis.text = element_text(color = "white"),                     # 坐标轴文字颜色
        axis.title = element_text(color = "white"),                    # 坐标轴标题颜色
        panel.grid.major = element_line(color = "gray70"),             # 主网格线为浅灰色
        panel.grid.minor = element_line(color = "gray50"),             # 次网格线为更浅灰色
        plot.title = element_text(color = "white", size = 14)          # 标题颜色
      )
    
    
    # 在 ggplotly 中禁用悬停提示
    ggplotly(gg, tooltip = NULL) %>%  # 设置 tooltip 为 NULL 禁用悬停
      layout(
        legend = list(
          orientation = "v",  # 垂直布局
          x = 1.05,           # 调整图例位置
          y = 1,
          title = list(text = "<b>Show Name</b>"),  # 加粗标题
          font = list(size = 10),  # 图例字体大小
          itemsizing = "constant"  # 固定大小
        )
      )
  })
  
  # 图 2：最近邻 Episode 的 PCA 图
  output$nearestPcaPlot <- renderPlotly({
    data_to_plot <- nearest_data()
    if (is.null(data_to_plot)) return(plotly_empty())
    data_to_plot <- data_to_plot %>%
      mutate(category = factor(category, levels = names(category_colors))) 
    
    # 设置全局主题和颜色映射
    custom_theme <- theme_minimal() +
      theme(plot.title = element_text(size = 14, face = "plain", hjust = 0.5, margin = margin(b = 20)))+
      theme(
        panel.background = element_rect(fill = "#2E2E2E", color = NA), # 浅灰色背景
        plot.background = element_rect(fill = "#2E2E2E", color = NA),  # 浅灰色画布背景
        legend.background = element_rect(fill = "#2E2E2E", color = NA), # 图例背景
        legend.key = element_rect(fill = "#2E2E2E",color = NA),       # 图例键背景
        legend.text = element_text(size = 8, color = "white"),         # 图例文字颜色
        legend.title = element_text(size = 10, color = "white"),       # 图例标题颜色
        axis.text = element_text(color = "white"),                     # 坐标轴文字颜色
        axis.title = element_text(color = "white"),                    # 坐标轴标题颜色
        panel.grid.major = element_line(color = "gray70"),             # 主网格线为浅灰色
        panel.grid.minor = element_line(color = "gray50"),             # 次网格线为更浅灰色
        plot.title = element_text(color = "white", size = 14)          # 标题颜色
      )
    
    # 图层 + 颜色映射
    gg <- ggplot(data_to_plot, aes_string(x = input$pc1, y = input$pc2, color = "category", shape = "selected")) +
      geom_point(size = 3, aes(customdata = unique_id)) +  # 设置透明度
      scale_color_manual(values = category_colors, name = "Category") + # 颜色映射
      scale_shape_manual(values = c("others" = 16, "selected" = 11), guide = "none") +  # 形状映射
      labs(
        title = "PCA Plot: TOP 50 Nearest Episodes",
        x = input$pc1,
        y = input$pc2
      ) +
      custom_theme  # 应用主题
    
    # 输出到 Plotly 图表
    ggplotly(gg, tooltip = "none") %>%
      event_register("plotly_hover") 
  })
  
  # 悬停信息
  output$hoverInfo <- renderUI({
    hover <- event_data("plotly_hover")
    
    if (is.null(hover)) {
      # 返回固定占位的三行信息
      return(HTML("<div style='height:90px; color:gray;'>
                  <strong>Category:</strong> <br>
                  <strong>Show Name:</strong> <br>
                  <strong>Episode Name:</strong>
                </div>"))
    }
    
    data_to_plot <- nearest_data()
    if (is.null(data_to_plot)) {
      return(HTML("<div style='height:90px; color:gray;'>No data available for hover.</div>"))
    }
    
    # 确保 customdata 匹配有效点
    hovered_point <- data_to_plot[data_to_plot$unique_id == hover$customdata, ]
    if (nrow(hovered_point) == 0) {
      return(HTML("<div style='height:90px; color:gray;'>Invalid hover event.</div>"))
    }
    
    # 显示悬停数据
    HTML(paste0(
      "<div style='height:90px;'>
      <strong>Category:</strong> ", hovered_point$category, "<br>
      <strong>Show Name:</strong> ", hovered_point$show_name, "<br>
      <strong>Episode Name:</strong> ", hovered_point$name, "
    </div>"
    ))
  })
  
  # 最近 Episode 信息
  output$nearestEpisode <- renderUI({
    data_to_plot <- nearest_data()
    if (is.null(data_to_plot)) {
      return(HTML("<div><span style='color:gray;'>No data available. Please select an episode.</span></div>"))
    }
    
    nearest <- data_to_plot %>%
      filter(selected == "others") %>%
      slice_head(n = 1) %>%
      select(show_name, name)
    
    if (nrow(nearest) == 0) {
      return(HTML("<div><span style='color:gray;'>No nearest episode found.</span></div>"))
    }
    
    HTML(paste0(
      "<div style='margin-top:15px; padding:10px; background-color:#333; color:white; border-radius:5px;'>",
      "<strong>Nearest Episode:</strong><br>",
      "<strong>Show Name:</strong> ", nearest$show_name, "<br>",
      "<strong>Episode Name:</strong> ", nearest$name,
      "</div>"
    ))
  })
  
}

# 运行 App
shinyApp(ui, server) 