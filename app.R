library(shiny)
library(shinydashboard)
library(shinyjs)
library(dplyr)
library(plotly)
library(DBI)
library(RMySQL)
library(DT)
library(shinyWidgets)
library(tidyr)
library(lubridate)
options(shiny.autoreload = TRUE)
db_connect <- function() {
  db <- dbConnect(
    RMySQL::MySQL(),
    user = "root",
    password = "200023@Sai",
    dbname = "finance_tracker",
    host = "localhost",
    port = 3306
  )
  return(db)
}
ui <- dashboardPage(
  dashboardHeader(
    title = "Personal Finance Tracker", 
    tags$li(
      class = "dropdown",
      style = "position: relative; left: -30px;", 
      conditionalPanel(
        condition = "output.showAlertFlag", # Control visibility via server
        tags$div(
          style = "position: relative; display: inline-block;",
          dropdownButton(
            label = NULL,
            icon = icon("bell"),
            status = "danger",
            circle = TRUE,
            uiOutput("alert_notifications")
          ),
          tags$span(
            id = "alert_count",
            class = "badge badge-danger",
            style = "position: absolute; top: 5px; right: 15px; background-color: red; color: white; border-radius: 50%; padding: 5px;",
            textOutput("alert_count_badge", inline = TRUE)
          )
        )
      )
    ),
    tags$li(
      class = "dropdown",
      # Logout buttons
      uiOutput("logout_button"),
      style = "display: inline-block; vertical-align: middle;"
    )
  ),
  dashboardSidebar(sidebarMenuOutput("dynamicMenu")),
  dashboardBody(
    hidden(div(
      id = "user_content",
      tabItems(
        tabItem(
          tabName = "dashboard",
          fluidRow(
            valueBoxOutput("incomeBox", width = 4),
            valueBoxOutput("expenseBox", width = 4),
            valueBoxOutput("balanceBox", width = 4)
          ),
          fluidRow(
            box(
              title = "Expenses Overview",
              status = "primary",
              solidHeader = TRUE,
              tableOutput("expenses_table"),
              width = 6
            ),
            box(
              title = "Expense Distribution",
              status = "primary",
              solidHeader = TRUE,
              plotlyOutput("expenses_plot"),
              width = 6
            )
          ),
          fluidRow(
            box(
              title = "Monthly Trends",
              status= "primary",
              solidHeader = TRUE,
              plotlyOutput("monthly_trends_plot"),
              width = 12
            )
          )
        ),
        tabItem(tabName = "add_income", fluidRow(
          box(
            title = "Add Income/Expense",
            status = "primary",
            solidHeader = TRUE,
            
            # Add a dropdown to select Income or Expense
            selectInput(
              inputId = "trans_type",
              label = "Transaction Type:",
              choices = c("Income", "Expense"),
              selected = "Income"
            ),
            
            # Conditionally display input fields based on selection
            conditionalPanel(
              condition = "input.trans_type == 'Income'",
              #select the category
              selectInput(
                inputId = "income_category",
                label = "Category:",
                choices = c("Main Income", "Side Income"),
                selected = "Main Income"
              ),
              selectInput(
                inputId = "income_subcategory",
                label = "Subcategory:",
                choices = c("Salary", "Freelance Work", "Investments", "Other")
              ),
              conditionalPanel(
                condition = "input.income_subcategory == 'Other'",
                textInput("subcategory_others", "Enter the Subcategory:", "")
              ),
              numericInput(
                "income",
                "Enter your Income:",
                value = 0,
                min = 0,
                step = 100
              ),
              # Date input for Income
              dateInput(
                inputId = "income_date",
                label = "Date of Income:",
                value = Sys.Date(),
                format = "yyyy-mm-dd"
              ),
              textAreaInput(
                inputId = "income_notes",
                label = "Notes:",
                value = "",
                placeholder = "Additional information about the income"
              ),
              actionButton("add_income", "Add Income"),
              actionButton("clear_income", "Clear Income")
            ),
            
            conditionalPanel(
              condition = "input.trans_type == 'Expense'",
              selectInput(
                inputId = "expenses_category",
                label = "Category:",
                choices = c("Housing", "Personal", "Transportation", "Other"),
                selected = "Housing"
              ),
              conditionalPanel(
                condition = "input.expenses_category == 'Other'",
                textInput("expenses_other_category", "Enter the Category:")
              ),
              selectInput(
                inputId = "expenses_subcategory",
                label = "Subcategory:",
                choices = c(
                  "Electricity",
                  "Food",
                  "Rent",
                  "Insurance",
                  "Internet",
                  "Water",
                  "Parking Fee",
                  "Shopping",
                  "Gas",
                  "Vehicle insurance",
                  "Other"
                ),
                selected = "Rent"
              ),
              conditionalPanel(
                condition = "input.expenses_subcategory == 'Other'",
                textInput("expenses_other_subcategory", "Enter the Subcategory:", ""),
              ),
              numericInput(
                "amount",
                "Expense Amount:",
                value = 0,
                min = 0,
                step = 10
              ),
              # Date input for Expense
              dateInput(
                inputId = "expense_date",
                label = "Date of Expense:",
                value = Sys.Date(),
                format = "yyyy-mm-dd"
              ),
              selectInput(
                inputId = "payment_method",
                label = "Payment Method",
                choices = c("Credit Card", "Cash", "Bank Transfer")
              ),
              textAreaInput(
                inputId = "expenses_notes",
                label = "Notes:",
                value = "",
                placeholder = "Additional information about the expenses"
              ),
              actionButton("add_expenses", "Add Expenses"),
              actionButton("clear_expenses", "Clear Expenses"),
            ),
            
            width = 6,
            textOutput("dynamicText")
          )
        )),
        tabItem(tabName = "edit_income", fluidRow(
          box(
            title = "Edit Income Records",
            status = "primary",
            solidHeader = TRUE,
            DTOutput("editable_income_table"),
            width = 12
          )
        )),
        tabItem(tabName = "edit_expenses", fluidRow(
          box(
            title = "Edit Expense Records",
            status = "primary",
            solidHeader = TRUE,
            DTOutput("editable_expense_table"),
            width = 12
          )
        )),
        tabItem(
          tabName = "predict_savings",
          box(
            sliderInput(
              "months",
              "Select number of months to predict:",
              min = 1,
              max = 12,
              value = 6
            ),
            numericInput(
              "income_goal",
              "Adjust Monthly Income Goal:",
              value = 0,
              min = 0,
              step = 1000
            ),
            numericInput(
              "spending_goal",
              "Adjust Monthly Spending Goal:",
              value = 0,
              min = 0,
              step = 1000
            ),
            numericInput(
              "savings_goal",
              "Adjust Monthly Savings Goal:",
              value = 0,
              min = 0,
              step = 1000
            ),
            downloadButton("downloadReport", "Download Savings Report"),
            width = 4
          ),
          box(
            plotlyOutput("savings_plot"),
            DTOutput("summaryTable"),
            width = 8
          ),
        ),
        tabItem(tabName = "goals_tab", fluidRow(
          box(
            title = "Add a New Goal",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            textInput("goal_name", "Goal Name:", placeholder = "Enter your goal (e.g., Emergency Fund)"),
            numericInput(
              "goal_amount",
              "Goal Amount ($):",
              value = 0,
              min = 0,
              step = 100
            ),
            numericInput(
              "saved_amount",
              "Saved Amount ($):",
              value = 0,
              min = 0,
              step = 100
            ),
            selectInput(
              "goal_status",
              "Status:",
              choices = c("Not Started", "In Progress", "Completed")
            ),
            actionButton("add_goal", "Add Goal")
          )
        ), fluidRow(
          box(
            title = "Your Financial Goals",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            DTOutput("goals_table")
          )
        )),
        tabItem(tabName = "loan_applications", fluidRow(
          box(
            title = "Apply for a Loan",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            numericInput(
              "loan_amount",
              "Loan Amount:",
              value = 1000,
              min = 100,
              step = 100
            ),
            selectInput(
              "loan_type",
              "Loan Type:",
              choices = c("Personal", "Home", "Auto", "Education", "Business")
            ),
            textInput("loan_purpose", "Loan Purpose:", placeholder = "e.g., Medical expenses, Education fee"),
            numericInput(
              "loan_duration",
              "Loan Duration (Months):",
              value = 12,
              min = 1,
              max = 360
            ),
            sliderInput(
              "interest_rate",
              "Interest Rate (%):",
              min = 1,
              max = 20,
              value = 5
            ),
            actionButton("apply_loan", "Apply for Loan", class = "btn btn-success")
          )
        ), fluidRow(
          box(
            title = "Your Loan Applications",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            DTOutput("loan_applications_table")
          )
        )),
        tabItem(
          tabName = "budgeting",
          fluidRow(
            box(
              title = "Set Monthly Budgets",
              solidHeader = TRUE,
              status = "primary",
              width = 6,
              selectInput("budget_category", "Category:",
                          choices = c("Housing", "Personal", "Transportation", "Other")),
              numericInput("budget_amount", "Budget Amount ($):", value = 0, min = 0, step = 50),
              actionButton("set_budget", "Set Budget"),
              actionButton("clear_budgets", "Clear All Budgets", class = "btn btn-danger")
            ),
            box(
              title = "Current Budgets",
              solidHeader = TRUE,
              status = "primary",
              width = 6,
              DTOutput("budget_table")
            )
          ),
          fluidRow(
            box(
              title = "Budget Alerts",
              solidHeader = TRUE,
              status = "danger",
              width = 12,
              uiOutput("budget_alerts")
            )
          )
        )
      )
    )),
    hidden(div(
      id = "admin_content", tabItems(
        tabItem(
          tabName = "admin_dashboard",
          fluidRow(
            valueBoxOutput("total_users_box", width = 4),
            valueBoxOutput("active_users_box", width = 4),
            valueBoxOutput("loan_status_box", width = 4)
          ),
          fluidRow(
            box(
              title = "User Activity Trends Over Time",
              width = 12,
              solidHeader = TRUE,
              status = "primary",
              plotlyOutput("activity_trend_plot")
            )
          )
        ),
        tabItem(
          tabName = "user_account_management",
          DTOutput("user_table"),
          actionButton("add_user", "Add User"),
          actionButton("delete_user", "Delete User"),
        ),
        tabItem(
          tabName = "user_login_activity",
          box(
            title = "User Login Activity",
            width = 12,
            solidHeader = TRUE,
            status = "primary",
            DTOutput("login_activity")
          )
        ),
        tabItem(tabName = "loan_management", fluidRow(
          box(
            title = "Loan Applications",
            status = "primary",
            solidHeader = TRUE,
            DTOutput("loan_table"),
            width = 12
          )
        ))
      )
    )),
    hidden(div(
      id = "advisor_content", tabItems(
        tabItem(tabName = "client_overview", fluidRow(
          box(
            title = "Client List",
            width = 12,
            DTOutput("financial_summary_table")
          )
        )),
        tabItem(tabName = "financial_summary", fluidRow(
          box(
            title = "Select Client",
            selectInput("selected_client", "Choose a Client:", choices = NULL),
            width = 4
          ), box(div(
            h4("Savings Rate"),
            valueBoxOutput("savings_rate_box", width = 6)
          ))
        ), fluidRow(
          box(
            title = "Income vs. Expenses",
            width = 6,
            plotlyOutput("income_expenses_plot")
          ),
          box(
            title = "Expenses Overview",
            width = 6,
            plotlyOutput("expense_breakdown_plot")
          )
        )),
        tabItem(tabName = "client_goals", fluidRow(
          box(
            title = "Select User",
            status = "primary",
            solidHeader = TRUE,
            width = 4,
            selectInput(
              "selected_user",
              "Select User:",
              choices = NULL,
              selected = NULL
            )
          )
        ), fluidRow(
          box(
            title = "Financial Goals Tracking",
            width = 12,
            DTOutput("goals_advisor")
          )
        ))
      )
    )),
    hidden(div(
      id = "bank_rep_content", tabItems(
        tabItem(tabName = "Bank_loan_applications", fluidRow(
          box(
            title = "Search and Filter Loan Applications",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            fluidRow(
              column(
                3,
                selectInput(
                  "filter_status",
                  "Filter by Status:",
                  choices = c("All", "Pending", "Approved", "Rejected"),
                  selected = "All"
                )
              ),
              column(
                3,
                selectInput(
                  "filter_loan_type",
                  "Filter by Loan Type:",
                  choices = c("All", "Personal", "Home", "Auto", "Education", "Business"),
                  selected = "All"
                )
              ),
              column(
                3,
                numericInput(
                  "filter_min_amount",
                  "Min Loan Amount:",
                  value = 0,
                  min = 0,
                  step = 100
                )
              ),
              column(
                3,
                numericInput(
                  "filter_max_amount",
                  "Max Loan Amount:",
                  value = 10000,
                  min = 0,
                  step = 100
                )
              )
            ),
            actionButton("apply_filters", "Apply Filters")
          ),
          box(
            title = "All Loan Applications",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            DTOutput("all_loans_table")
          )
        )),
        tabItem(tabName = "insights", fluidRow(
          box(
            title = "Loan Application Insights",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            plotlyOutput("loan_status_pie"),
            plotlyOutput("loan_type_bar"),
            plotlyOutput("loan_trend_line")
          )
        )),
        tabItem(tabName = "income_expenses", fluidRow(
          box(
            title = "Select User",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            selectInput(
              inputId = "selected_users",
              label = "Choose a User:",
              choices = c("All Users" = "all"),
              # Default to 'All Users'
              selected = "all"
            )
          )
        ), fluidRow(
          box(
            title = "User Income Overview",
            status = "primary",
            solidHeader = TRUE,
            width = 6,
            plotlyOutput("user_income_bar")
          ),
          box(
            title = "User Expense Distribution",
            status = "primary",
            solidHeader = TRUE,
            width = 6,
            plotlyOutput("user_expense_pie")
          )
        ), fluidRow(
          box(
            title = "User Income and Expense Summary",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            DTOutput("income_expense_table")
          )
        ))
      )
    ))
    ,
    tabItems(
      tabItem(tabName = "user_profile", useShinyjs(), fluidRow(
        wellPanel(
          id = "login_registration_box",
          style = "width: 400px;",
          tabsetPanel(
            id = "login_register_tabs",
            tabPanel(
              "Login",
              textInput("username", "Username:", placeholder = "Enter your username"),
              passwordInput("password", "Password:", placeholder = "Enter your password"),
              actionButton("login_button", "Login"),
              textOutput("login_error_user"),
              br(),
              actionLink("show_register", "Create a new account")
            ),
            tabPanel(
              "Register",
              textInput("new_username", "Username:", placeholder = "Choose a username"),
              textInput("email", "Email:", placeholder = "Enter your email"),
              textInput("fullname", "Fullname:", placeholder = "Enter your Fullname"),
              passwordInput("new_password", "Password:", placeholder = "Choose a password"),
              actionButton("create_account", "Create Account"),
              textOutput("registration_status"),
              br(),
              actionLink("show_login", "Already have an account? Login here")
            )
          )
        )
      )),
      tabItem(tabName = "admin_panel", fluidRow(
        wellPanel(
          id = "admin_login_registration_box",
          style = "width: 400px;",
          tabsetPanel(
            id = "admin_login_register_tabs",
            tabPanel(
              "Admin Login",
              textInput("admin_username", "Username:", placeholder = "Enter your username"),
              passwordInput("admin_password", "Password:", placeholder = "Enter your password"),
              actionButton("admin_login_button", "Login", class = "btn btn-primary"),
              textOutput("login_error_admin"),
            )
          )
        )
      )),
      tabItem(tabName = "advisor_login", fluidRow(
        wellPanel(
          id = "advisor_login_box",
          style = "width: 400px;",
          tabsetPanel(
            id = "advisor_login_tabs",
            tabPanel(
              "Advisor Login",
              textInput("advisor_username", "Username:", placeholder = "Enter your username"),
              passwordInput("advisor_password", "Password:", placeholder = "Enter your password"),
              actionButton("advisor_login_button", "Login", class = "btn btn-primary"),
              textOutput("login_error_advisor")
            )
          )
        )
      )),
      tabItem(tabName = "bank_rep_login", fluidRow(
        wellPanel(
          id = "bank_rep_login_box",
          style = "width: 400px;",
          tabsetPanel(
            id = "bank_rep_login_tabs",
            tabPanel(
              "Bank Representative Login",
              textInput("bank_rep_username", "Username:", placeholder = "Enter your username"),
              passwordInput("bank_rep_password", "Password:", placeholder = "Enter your password"),
              actionButton("bank_rep_login_button", "Login", class = "btn btn-primary"),
              textOutput("login_error_bank_rep")
            )
          )
        )
      )),
      tabItem(
        tabName = "about",
        h2("Personal Finance Tracker"),
        p("This app helps you track your expenses and manage your income.")
      )
    ),
  )
)

# Define server logic with validation
server <- function(input, output, session) {
  # Establish database connection
  db <- db_connect()
  # Close connection when app stops
  session$onSessionEnded(function() {
    dbDisconnect(db)
  })
  
  income <- reactiveVal(0)
  expenses <- reactiveVal(0)
  # Reactive variable to control visibility
  showAlerts <- reactiveVal(FALSE) # Set to TRUE if you want to show alerts
  output$dynamicMenu <- renderMenu({
    menu <- sidebarMenu(
      id = "tabs",
      menuItem("User login" , tabName = "user_profile", icon = icon("user")),
      menuItem(
        "Admin login",
        tabName = "admin_panel",
        icon = icon("cogs")
      ),
      menuItem(
        "Financial Advisor",
        tabName = "advisor_login",
        icon = icon("user-tie")
      ),
      menuItem(
        "Bank Representative Login",
        tabName = "bank_rep_login",
        icon = icon("building")
      ),
      menuItem(
        "About",
        tabName = "about",
        icon = icon("info-circle")
      )
    )
    if (login_status() && !isTruthy(input$logout_button_ui)) {
      menu <- sidebarMenu(
        menuItem(
          "Dashboard",
          tabName = "dashboard",
          icon = icon("dashboard")
        ),
        menuItem(
          "Add Transaction",
          tabName = "add_income",
          icon = icon("plus")
        ),
        menuItem(
          "Edit Income",
          tabName = "edit_income",
          icon = icon("edit")
        ),
        menuItem(
          "Edit Expenses",
          tabName = "edit_expenses",
          icon = icon("edit")
        ),
        menuItem(
          "Predict Future Savings",
          tabName = "predict_savings",
          icon = icon("chart-line")
        ),
        menuItem(
          "Goals",
          tabName = "goals_tab",
          icon = icon("bullseye")
        ),
        menuItem(
          "Loan Applications",
          tabName = "loan_applications",
          icon = icon("file-alt")
        ),
        menuItem(
          "Budgeting and Alerts",
          tabName = "budgeting",
          icon = icon("bell")
        )
      )
    }
    if (admin_login_status()) {
      menu <- sidebarMenu(
        menuItem(
          "DashBoard",
          tabName = "admin_dashboard",
          icon = icon("dashboard")
        ),
        menuItem(
          "User Account Management",
          tabName = "user_account_management",
          icon = icon("users")
        ),
        menuItem(
          "User Login Activity",
          tabName = "user_login_activity",
          icon = icon("user-check")
        ),
        menuItem(
          "Loan Management",
          tabName = "loan_management",
          icon = icon("money-check")
        )
      )
    }
    if (advisor_login_status()) {
      menu <- sidebarMenu(
        menuItem(
          "Client Overview",
          tabName = "client_overview",
          icon = icon("users")
        ),
        menuItem(
          "Client Financial Summary",
          tabName = "financial_summary",
          icon = icon("chart-line")
        ),
        menuItem(
          "Client Goals",
          tabName = "client_goals",
          icon = icon("bullseye")
        )
      )
    }
    if (bank_rep_login_status()) {
      menu <- sidebarMenu(
        menuItem(
          "User Income & Expenses",
          tabName = "income_expenses",
          icon = icon("chart-bar")
        ),
        menuItem(
          "Loan Applications",
          tabName = "Bank_loan_applications",
          icon = icon("users")
        ),
        menuItem(
          "Insights",
          tabName = "insights",
          icon = icon("chart-line")
        )
      )
    }
    menu
  })
  # Reactive value to store login status
  login_status <- reactiveVal(FALSE)
  admin_login_status <- reactiveVal(FALSE)
  advisor_login_status <- reactiveVal(FALSE)
  bank_rep_login_status <- reactiveVal(FALSE)
  user_id <- reactiveVal(NULL)  # Initialize reactive value for user ID
  # Toggle between login and registration forms
  observeEvent(input$show_register, {
    updateTabsetPanel(session, "login_register_tabs", selected = "Register")
  })
  observeEvent(input$show_login, {
    updateTabsetPanel(session, "login_register_tabs", selected = "Login")
  })
  # User login function
  observeEvent(input$login_button, {
    username <- input$username
    password <- input$password
    query <- sprintf("SELECT * FROM Users WHERE username = '%s'
    AND password = '%s'",
                     username,
                     password)
    user_data <- dbGetQuery(db, query)
    if (nrow(user_data) == 1) {
      login_status(TRUE) # Successful login
      shinyjs::show("user_content")
      shinyjs::hide("login_registration_box")
      user_id <- user_data$user_id
      session$userData$user_id <- user_id
      user_id(user_data$user_id)
      req(session$userData$user_id)  # Ensure the user is logged in
      loans <- load_loans(session$userData$user_id)  # Fetch loans for the logged-in user
      user_loans(loans)
      refresh_budget_data()
      showAlerts(TRUE)
      output$logout_button <- renderUI({
        actionButton("logout_button_ui", "Logout", class = "btn btn-danger")
      })
      ip_address <- session$request$REMOTE_ADDR
      db <- db_connect()
      dbExecute(
        db,
        sprintf(
          "INSERT INTO login_activity (user_id, timestamp, ip_address) VALUES (%d, NOW(), '%s')",
          user_id,
          ip_address
        )
      )
      dbDisconnect(db)
    } else {
      output$login_error_user <- renderText("Invalid username or password!")
      shinyjs::delay(1000, {
        output$login_error_user <- renderText(" ")
      })
    }
  })
  # User registration function
  observeEvent(input$create_account, {
    req(
      input$new_username != "" &&
        input$new_password != "" &&
        input$email != "" && input$fullname != ""
    )
    new_username <- input$new_username
    new_password <- input$new_password
    new_email <- input$email
    new_fullname <- input$fullname
    creation_time <- Sys.time()
    query <- sprintf("SELECT * FROM Users WHERE username = '%s'", new_username)
    res <- dbGetQuery(db, query)
    if (nrow(res) == 0) {
      if (nchar(new_username) < 4) {
        output$registration_status <- renderText("Username must be at least 4 characters long.")
        return(NULL)
      }
      if (!grepl("@gmail\\.com$", new_email)) {
        output$registration_status <- renderText("Please enter a valid Gmail address (ending with @gmail.com).")
        return(NULL)
      }
      if (nchar(new_password) < 6 ||
          !grepl("[A-Za-z]", new_password) ||
          !grepl("[0-9]", new_password)) {
        output$registration_status <- renderText("Password must be at least 6 characters long and contain both letters and numbers.")
        return(NULL)
      }
      query <- sprintf(
        "INSERT INTO users (username, password,fullname,email, created_at) VALUES ('%s', '%s','%s','%s', '%s')",
        new_username,
        new_password,
        new_fullname,
        new_email,
        creation_time
      )
      dbExecute(db, query)
      output$registration_status <- renderText("Account created successfully!")
      updateTabsetPanel(session, "login_register_tabs", selected = "Login")
    } else {
      output$registration_status <- renderText("Username already exists.")
    }
  })
  #admin login function
  observeEvent(input$admin_login_button, {
    req(input$admin_username != "" && input$admin_password != "")
    username <- input$admin_username
    password <- input$admin_password
    
    query <- sprintf("SELECT * FROM admins WHERE username = '%s' AND password = '%s'",
                     username,
                     password)
    res <- dbGetQuery(db, query)
    
    if (nrow(res) == 1) {
      admin_login_status(TRUE)  # Successful login
      shinyjs::show("admin_content")
      shinyjs::hide("admin_login_registration_box")
      refresh_login_activity()
      updateUserTable()
      output$logout_button <- renderUI({
        actionButton("logout_button_admin", "Logout", class = "btn btn-danger")
      })
    } else {
      output$login_error_admin <- renderText("Invalid username or password!")
      shinyjs::delay(1000, {
        output$login_error_admin <- renderText(" ")
      })
    }
  })
  
  observeEvent(input$advisor_login_button, {
    req(input$advisor_username != "" && input$advisor_password != "")
    username <- input$advisor_username
    password <- input$advisor_password
    query <- "SELECT advisor_id, username, CAST(created_at AS CHAR) AS created_at FROM advisors"
    res <- dbGetQuery(db, query)
    if (nrow(res) == 1) {
      advisor_login_status(TRUE)  # Successful login
      shinyjs::show("advisor_content")  # Show advisor dashboard content
      shinyjs::hide("advisor_login_box")  # Hide the login box
      output$logout_button <- renderUI({
        actionButton("logout_button_advisor", "Logout", class = "btn btn-danger")
      })
    } else {
      output$login_error_advisor <- renderText("Invalid username or password!")
      shinyjs::delay(1000, {
        output$login_error_advisor <- renderText(" ")
      })
    }
  })
  
  # Logout functionality for advisor
  observeEvent(input$logout_button_advisor, {
    advisor_login_status(FALSE)  # Log out the advisor
    shinyjs::hide("advisor_content")  # Hide the advisor dashboard content
    shinyjs::show("advisor_login_box")  # Show the login box again
    output$logout_button <- renderUI(NULL)  # Remove the logout button
  })
  
  observeEvent(input$bank_rep_login_button, {
    req(input$bank_rep_username != "" && input$bank_rep_password != "")
    username <- input$bank_rep_username
    password <- input$bank_rep_password
    
    query <- sprintf(
      "SELECT rep_id, username, CAST(created_at AS CHAR) AS created_at
     FROM bank_representatives WHERE username = '%s' AND password = '%s'",
      username,
      password
    )
    res <- dbGetQuery(db, query)
    
    if (nrow(res) == 1) {
      bank_rep_login_status(TRUE)  # Successful login
      shinyjs::show("bank_rep_content") # Show Bank Representative dashboard content
      shinyjs::hide("bank_rep_login_box")  # Hide the login box
      output$logout_button <- renderUI({
        actionButton("logout_button_bank_rep", "Logout", class = "btn btn-danger")
      })
    } else {
      output$login_error_bank_rep <- renderText("Invalid username or password!")
      shinyjs::delay(1000, {
        output$login_error_bank_rep <- renderText(" ")
      })
    }
  })
  
  
  observeEvent(input$logout_button_bank_rep, {
    bank_rep_login_status(FALSE)  # Log out the advisor
    shinyjs::hide("bank_rep_content")  # Hide the advisor dashboard content
    shinyjs::show("bank_rep_login_box")  # Show the login box again
    output$logout_button <- renderUI(NULL)  # Remove the logout button
  })
  
  # Update the income after adding new income
  observeEvent(input$add_income, {
    # Insert income into the database
    income_category <- input$income_category
    income_subcategory <- ifelse(
      input$income_subcategory == "Other",
      input$subcategory_others,
      input$income_subcategory
    )
    income_amount <- input$income
    income_date <- as.Date(input$income_date)
    income_notes <- input$income_notes
    user_id <- session$userData$user_id
    
    query <- sprintf(
      "INSERT INTO income (user_id, income_category, income_subcategory, income_amount, income_date, income_notes)
    VALUES ('%s', '%s', '%s', '%f', '%s', '%s')",
      user_id,
      income_category,
      income_subcategory,
      income_amount,
      income_date,
      income_notes
    )
    dbExecute(db, query)
    
    # Fetch updated income data and update reactive values
    income_data <- dbGetQuery(db,
                              sprintf("SELECT * FROM income WHERE user_id = '%s'", user_id))
    session$userData$income_amount <- sum(as.numeric(income_data$income_amount), na.rm = TRUE)
    income(session$userData$income_amount)  # Update reactive value to refresh the UI
    refresh_income_table()
    output$dynamicText <- renderText("Income successfully added!")
  })
  
  observeEvent(input$clear_income, {
    updateSelectInput(session, "income_category", selected = "Housing")
    updateSelectInput(session, "income_subcategory", selected = "Rent")
    updateSelectInput(session, "payment_method", selected = "credit Card")
    updateNumericInput(session, "income", value = 0)
    updateDateInput(session, "income_date", value = Sys.Date())
    updateTextInput(session, "income_other_category", value = "")
    updateTextInput(session, "subcategory_others", value = "")
    updateTextInput(session, "income_other_subcategory", value = "")
    updateTextInput(session , "income_notes", value = "")
  })
  
  
  # user Logout logic
  observeEvent(input$logout_button_ui, {
    login_status(FALSE)
    shinyjs::hide("user_content")
    shinyjs::show("login_registration_box")
    output$logout_button <- renderUI(NULL)
    showAlerts(FALSE)
  })
  # admin logout logic
  observeEvent(input$logout_button_admin, {
    admin_login_status(FALSE)
    shinyjs::hide("admin_content")
    
    shinyjs::show("admin_login_registration_box")
    output$logout_button <- renderUI(NULL)
  })
  # Reactive value to store expenses
  values <- reactiveValues(expenses = data.frame(
    Description = character(),
    Amount = numeric(),
    stringsAsFactors = FALSE
  ))
  # Update expenses when "Add Expense" button is clicked
  observeEvent(input$add_expense, {
    req(input$description != "" && input$amount > 0)
    new_expense <- data.frame(
      Description = input$description,
      Amount = input$amount,
      stringsAsFactors = FALSE
    )
    values$expenses <- rbind(values$expenses, new_expense)
    showNotification("Amount added successfully!", type = "message")
  })
  # Clear expenses when "Clear All Expenses" button is clicked
  observeEvent(input$clear_expenses, {
    values$expenses <- data.frame(
      Description = character(),
      Amount = numeric(),
      stringsAsFactors = FALSE
    )
  })
  
  globalData_Overview <- reactiveValues(expense_overview = NULL)
  globalData_Distribution <- reactiveValues(expense_distribution = NULL)
  
  observeEvent(input$login_button, {
    req(session$userData$user_id)
    # Fetch and calculate total income
    income_query <- sprintf("SELECT * FROM income WHERE user_id = '%s'",
                            session$userData$user_id)
    income_data <- dbGetQuery(db, income_query)
    session$userData$income_amount <- sum(as.numeric(income_data$income_amount), na.rm = TRUE)
    income(session$userData$income_amount)  # Update reactive value
    
    # Fetch and calculate total expenses
    expenses_query <- sprintf("SELECT * FROM expenses WHERE user_id = '%s'",
                              session$userData$user_id)
    expenses_data <- dbGetQuery(db, expenses_query)
    session$userData$expenses_amount <- sum(as.numeric(expenses_data$amount), na.rm = TRUE)
    expenses(session$userData$expenses_amount)  # Update reactive value
    globalData_Overview$expense_overview <- data.frame(
      Category = expenses_data$category,
      Subcategory = expenses_data$subcategory,
      Amount = expenses_data$amount
    )
    globalData_Distribution$expense_distribution <- expenses_data %>%
      group_by(category) %>%
      summarize(TotalAmount = sum(amount, na.rm = TRUE))
  })
  
  # Calculate total income, total expenses, and remaining balance
  output$incomeBox <- renderValueBox({
    valueBox(
      formatC(income(), format = "f", big.mark = ","),
      "Total Income ($)",
      icon = icon("dollar-sign"),
      color = "green"
    )
  })
  
  output$expenseBox <- renderValueBox({
    valueBox(
      formatC(expenses(), format = "f", big.mark = ","),
      "Total Expenses ($)",
      icon = icon("shopping-cart"),
      color = "red"
    )
  })
  
  output$balanceBox <- renderValueBox({
    balance <- income() - expenses()
    valueBox(
      formatC(balance, format = "f", big.mark = ","),
      "Remaining Balance ($)",
      icon = icon("wallet"),
      color = "blue"
    )
  })
  
  #Display expenses table
  output$expenses_table <- renderTable({
    globalData_Overview$expense_overview
  })
  # Plot expenses
  output$expenses_plot <- renderPlotly({
    plot_ly(
      globalData_Distribution$expense_distribution,
      x = ~ category,
      y = ~ TotalAmount,
      type = "bar",
      color = ~ category
    ) %>%
      layout(
        title = "Expense Distribution",
        xaxis = list(title = "Expense Description"),
        yaxis = list(title = "Amount ($)")
      )
  })
  
  table_refresh_trigger <- reactiveVal(0)
  
  
  # Define updateUserTable as a reactive expression to fetch data from the database
  updateUserTable <- reactive({
    table_refresh_trigger()
    db <- db_connect()
    users <- dbGetQuery(db, "SELECT * FROM users")
    dbDisconnect(db)
    return(users)
  })
  
  output$user_table <- renderDT({
    # Get the data, remove the `user_id` and `password` columns
    user_data <- updateUserTable()[, c("username", "email", "created_at")]
    
    # Set new column names based on the selected columns
    colnames(user_data) <- c("Username", "Email", "Creation Date")
    
    # Render the DataTable with new column names
    datatable(user_data, selection = 'single', editable = TRUE)
  })
  
  # Capture edits and update the database
  observeEvent(input$user_table_cell_edit, {
    info <- input$user_table_cell_edit  # Contains row, column, and new value
    
    # Load current data to get the primary key for updating
    db <- db_connect()
    user_data <- dbGetQuery(db, "SELECT user_id, username, email, created_at FROM users")  # Replace "users" with your actual table name
    dbDisconnect(db)
    
    # Define mapping of column indices to column names in the database
    col_map <- c("username", "email", "created_at")
    db_column <- col_map[info$col]  # Get the column name to update
    new_value <- info$value  # New value to be saved
    
    # Retrieve the `user_id` for the row being edited
    user_id <- user_data[info$row, "user_id"]  # Add 1 since DataTable indexing starts at 0
    
    # Update the database
    query <- sprintf("UPDATE users SET %s = '%s' WHERE user_id = %d",
                     db_column,
                     new_value,
                     user_id)
    db <- db_connect()
    dbExecute(db, query)
    dbDisconnect(db)
    
    # Optionally, refresh the table if needed (e.g., if using reactive trigger)
    # refresh_user_table() # Uncomment if using a reactive trigger for refreshing
  })
  
  # Add User Modal and Logic
  observeEvent(input$add_user, {
    showModal(
      modalDialog(
        title = "Add User",
        textInput("new_user_name", "User Name"),
        passwordInput("new_user_password", "Password"),
        textInput("new_full_name", "Full Name"),
        textInput("new_user_email", "Email", placeholder = "Enter a valid email address"),
        footer = tagList(
          modalButton("Cancel"),
          actionButton("confirm_add_user", "Add User")
        )
      )
    )
    
    observeEvent(input$confirm_add_user, {
      # Check if username already exists
      db <- db_connect()
      existing_user <- dbGetQuery(db,
                                  sprintf(
                                    "SELECT * FROM users WHERE username = '%s'",
                                    input$new_user_name
                                  ))
      dbDisconnect(db)
      
      if (nrow(existing_user) > 0) {
        # Show error if the username already exists
        showModal(
          modalDialog(
            title = "Error",
            "The username already exists. Please choose a different username.",
            easyClose = TRUE,
            footer = NULL
          )
        )
      } else {
        # Proceed with insertion if the username is unique
        creation_time <- Sys.time()
        query <- sprintf(
          "INSERT INTO users (username, password,fullname, email, created_at) VALUES ('%s', '%s','%s', '%s', '%s')",
          input$new_user_name,
          input$new_user_password,
          input$new_full_name,
          input$new_user_email,
          creation_time
        )
        
        # Error handling for database insertion
        tryCatch({
          db <- db_connect()
          dbExecute(db, query)
          dbDisconnect(db)
          
          # Refresh the table after adding a new user
          table_refresh_trigger(table_refresh_trigger() + 1)
          
          # Close the modal after successful addition
          removeModal()
        }, error = function(e) {
          # Show error message if insertion fails
          showModal(modalDialog(
            title = "Error",
            paste("An error occurred:", e$message),
            easyClose = TRUE,
            footer = NULL
          ))
        })
      }
    })
  })
  
  # Delete User Logic
  observeEvent(input$delete_user, {
    selected_user <- input$user_table_rows_selected
    if (!is.null(selected_user)) {
      # Load the user data
      users <- updateUserTable()# Use the reactive function here to get the current users table
      user_id <- users$user_id[selected_user]  # Get the selected user's ID
      db <- db_connect()
      # Directly insert user_id into the SQL statement
      dbExecute(db, paste0("DELETE FROM Users WHERE user_id = ", user_id))
      dbDisconnect(db)
      table_refresh_trigger(table_refresh_trigger() + 1)
    }
  })
  
  # Update the expenses after adding a new expense
  observeEvent(input$add_expenses, {
    # Handle conditional input
    category <- ifelse(
      input$expenses_category == "Other",
      input$expenses_other_category,
      input$expenses_category
    )
    subcategory <- ifelse(
      input$expenses_subcategory == "Other",
      input$expenses_other_subcategory,
      input$expenses_subcategory
    )
    expense_amount <- input$amount
    expense_date <- as.Date(input$expense_date)
    payment_method <- input$payment_method
    expenses_notes <- input$expenses_notes
    user_id <- session$userData$user_id
    
    # Insert expense into the database
    query <- sprintf(
      "INSERT INTO expenses (user_id, category, subcategory, amount, expense_date, payment_method, notes)
    VALUES ('%s', '%s', '%s', '%f', '%s', '%s', '%s')",
      user_id,
      category,
      subcategory,
      expense_amount,
      expense_date,
      payment_method,
      expenses_notes
    )
    dbExecute(db, query)
    
    # Fetch updated expenses data and update reactive values
    expenses_data <- dbGetQuery(db,
                                sprintf("SELECT * FROM expenses WHERE user_id = '%s'", user_id))
    session$userData$expenses_amount <- sum(as.numeric(expenses_data$amount), na.rm = TRUE)
    expenses(session$userData$expenses_amount)  # Update reactive value to refresh the UI
    refresh_expense_table()
    refresh_budget_data()
    globalData_Overview$expense_overview <- data.frame(
      Category = expenses_data$category,
      Subcategory = expenses_data$subcategory,
      Amount = expenses_data$amount
    )
    globalData_Distribution$expense_distribution <- expenses_data %>%
      group_by(category) %>%
      summarize(TotalAmount = sum(amount, na.rm = TRUE))
    
    output$dynamicText <- renderText({
      paste("Expense added for",
            category,
            "-",
            subcategory,
            ": $",
            expense_amount)
    })
  })
  # Clear the data
  observeEvent(input$clear_expenses, {
    # Reset the inputs to default
    updateSelectInput(session, "expenses_category", selected = "Housing")
    updateSelectInput(session, "expenses_subcategory", selected = "Rent")
    updateNumericInput(session, "amount", value = 0)
    updateDateInput(session, "expense_date", value = Sys.Date())
    updateSelectInput(session, "payment_method", selected = "Credit Card")
    updateTextAreaInput(session, "expenses_notes", value = "")
    
    output$dynamicText <- renderText({
      "Inputs cleared!"
    })
  })
  
  income_table_refresh <- reactiveVal(0)
  
  # Editable income table
  output$editable_income_table <- renderDT({
    req(session$userData$user_id)  # Ensure user is logged in
    income_table_refresh()
    user_id <- session$userData$user_id
    income_data <- dbGetQuery(db,
                              sprintf("SELECT * FROM income WHERE user_id = '%s'", user_id))
    new_colnames <- c("id",
                      "UserId",
                      "Category",
                      "SubCategory",
                      "Others",
                      "Amount",
                      "Date",
                      "Notes")
    datatable(
      income_data,
      colnames = new_colnames,
      editable = TRUE,
      options = list(columnDefs = list(list(
        visible = FALSE, targets = c(1, 2)
      ))),
    )
  })
  
  # Function to refresh the income table
  refresh_income_table <- function() {
    income_table_refresh(income_table_refresh() + 1)  # Increment the trigger to force a refresh
  }
  
  expense_table_refresh <- reactiveVal(0)
  
  # Editable expenses table
  output$editable_expense_table <- renderDT({
    req(session$userData$user_id)  # Ensure user is logged in
    expense_table_refresh()
    user_id <- session$userData$user_id
    expenses_data <- dbGetQuery(db,
                                sprintf("SELECT * FROM expenses WHERE user_id = '%s'", user_id))
    datatable(expenses_data, editable = TRUE)
    new_colnames <- c(
      "id",
      "UserId",
      "Category",
      "SubCategory",
      "Amount",
      "Expense Date",
      "Payment Method",
      "Notes"
    )
    datatable(
      expenses_data,
      colnames = new_colnames,
      editable = TRUE,
      options = list(columnDefs = list(list(
        visible = FALSE, targets = c(1, 2)
      )))
    )
  })
  
  # Function to refresh the expense table
  refresh_expense_table <- function() {
    expense_table_refresh(expense_table_refresh() + 1)  # Increment the trigger to force a refresh
  }
  
  observeEvent(input$editable_income_table_cell_edit, {
    info <- input$editable_income_table_cell_edit
    req(info)  # Ensure info is not NULL
    
    # Get the logged-in user's ID
    user_id <- session$userData$user_id
    
    # Fetch the currently visible data for the logged-in user
    visible_data <- dbGetQuery(db,
                               sprintf("SELECT * FROM income WHERE user_id = '%s'", user_id))
    
    # Map the visible row index to the actual database ID
    actual_id <- visible_data$id[info$row]
    
    # Identify the column being updated
    column <- colnames(visible_data)[info$col]
    
    # Construct the SQL query
    query <- sprintf(
      "UPDATE income
     SET %s = '%s'
     WHERE id = %d AND user_id = '%s'",
      column,
      info$value,
      actual_id,
      # Use the mapped database ID
      user_id
    )
    
    # Execute the query
    dbExecute(db, query)
  })
  
  observeEvent(input$editable_expense_table_cell_edit, {
    info <- input$editable_expense_table_cell_edit
    req(info)
    
    # Get the logged-in user ID
    user_id <- session$userData$user_id
    
    # Fetch the currently visible data
    visible_data <- dbGetQuery(db,
                               sprintf("SELECT * FROM expenses WHERE user_id = '%s'", user_id))
    
    # Map the visible row index to the actual database ID
    actual_id <- visible_data$id[info$row]
    
    # Identify the column being updated
    column <- colnames(visible_data)[info$col]
    
    # Construct the SQL query
    query <- sprintf(
      "UPDATE expenses
     SET %s = '%s'
     WHERE user_id = '%s' AND id = %d",
      column,
      info$value,
      user_id,
      actual_id
    )
    
    # Execute the query
    dbExecute(db, query)
  })
  
  fetch_data <- function() {
    db <- db_connect()
    on.exit(dbDisconnect(db)) # Ensure the database disconnects even if an error occurs
    user_id <- session$userData$user_id
    income_data <- dbGetQuery(db,
                              sprintf(
                                "SELECT * FROM income WHERE user_id = %d",
                                user_id
                              ))
    expenses_data <- dbGetQuery(db,
                                sprintf(
                                  "SELECT * FROM expenses WHERE user_id = %d",
                                  user_id
                                ))
    
    list(income_data = income_data, expenses_data = expenses_data)
  }
  
  
  get_data <- reactive({
    data <- fetch_data()
    income_data <- data$income_data
    expenses_data <- data$expenses_data
    
    # Convert dates to Date type
    income_data <- income_data %>%
      mutate(income_date = as.Date(income_date))
    
    expenses_data <- expenses_data %>%
      mutate(expense_date = as.Date(expense_date))
    
    # Aggregate monthly data
    monthly_income <- income_data %>%
      mutate(month = floor_date(income_date, "month")) %>%
      group_by(month) %>%
      summarize(monthly_income = sum(income_amount), .groups = "drop")
    
    monthly_expenses <- expenses_data %>%
      mutate(month = floor_date(expense_date, "month")) %>%
      group_by(month) %>%
      summarize(monthly_expense = sum(amount), .groups = "drop")
    
    # Merge and calculate savings
    monthly_data <- full_join(monthly_income, monthly_expenses, by = "month") %>%
      mutate(
        monthly_income = coalesce(monthly_income, 0),
        monthly_expense = coalesce(monthly_expense, 0),
        monthly_savings = monthly_income - monthly_expense
      )
    
    monthly_data
  })
  
  # Prediction logic
  predict_savings <- reactive({
    monthly_data <- get_data()
    if (nrow(monthly_data) < 2) {
      return(list(monthly_data = monthly_data, future_months = data.frame()))
    }
    
    # Ensure there are enough points for the chosen degree
    unique_points <- length(unique(as.numeric(monthly_data$month)))
    degree <- min(2, unique_points - 1)  # Ensure degree is less than unique points
    
    # Fit polynomial regression
    model <- lm(monthly_savings ~ poly(as.numeric(month), degree = degree), data = monthly_data)
    
    # Predict future months
    future_months <- data.frame(
      month = seq(
        max(monthly_data$month) + months(1),
        by = "month",
        length.out = input$months
      )
    )
    
    future_months$predicted_future_savings <- predict(model, newdata = future_months) +
      input$income_goal - input$spending_goal + input$savings_goal
    
    list(monthly_data = monthly_data, future_months = future_months)
  })
  
  # Plot income vs expense
  output$income_expense_plot <- renderPlotly({
    data <- get_data()
    plot_ly(data, x = ~month) %>%
      add_trace(y = ~monthly_income, name = "Income", type = "bar", marker = list(color = "blue")) %>%
      add_trace(y = ~monthly_expense, name = "Expenses", type = "bar", marker = list(color = "red")) %>%
      layout(
        title = "Monthly Income vs Expenses",
        barmode = "group",
        xaxis = list(title = "Month"),
        yaxis = list(title = "Amount ($)")
      )
  })
  
  # Plot predicted savings
  output$savings_plot <- renderPlotly({
    data <- predict_savings()
    monthly_data <- data$monthly_data
    future_months <- data$future_months
    
    plot_ly() %>%
      add_trace(
        x = ~monthly_data$month,
        y = ~monthly_data$monthly_savings,
        name = "Past Savings",
        type = "scatter",
        mode = "lines+markers",
        line = list(color = "lightblue")
      ) %>%
      add_trace(
        x = ~future_months$month,
        y = ~future_months$predicted_future_savings,
        name = "Predicted Savings",
        type = "scatter",
        mode = "lines+markers",
        line = list(color = "green")
      ) %>%
      layout(
        title = "Predicted Savings for Future Months",
        xaxis = list(title = "Month"),
        yaxis = list(title = "Savings ($)")
      )
  })
  
  # Render the summary table
  output$summaryTable <- renderDT({
    data <- predict_savings()
    future_months <- data$future_months
    
    if (nrow(future_months) == 0) {
      return(datatable(data.frame("No Data Available")))
    }
    
    summary_table <- data.frame(
      Month = future_months$month,
      Predicted_Future_Savings = round(future_months$predicted_future_savings, 2)
    )
    
    datatable(summary_table,
              options = list(pageLength = 5),
              rownames = FALSE)
  })
  
  # Download handler for savings report
  output$downloadReport <- downloadHandler(
    filename = function() {
      paste("Savings_Report_", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      data <- predict_savings()
      future_months <- data$future_months
      write.csv(future_months, file, row.names = FALSE)
    }
  )
  
  login_activity_refresh <- reactiveVal(0)
  
  output$login_activity <- renderDT({
    db <- db_connect()
    # Join login_activity with users to get usernames
    login_activity <- dbGetQuery(
      db,
      "
    SELECT login_activity.timestamp, users.username, login_activity.ip_address
    FROM login_activity
    JOIN users ON login_activity.user_id = users.user_id
    ORDER BY login_activity.timestamp DESC
    LIMIT 50
  "
    )
    dbDisconnect(db)
    datatable(login_activity, options = list(pageLength = 10))
  })
  
  refresh_login_activity <- function() {
    login_activity_refresh(login_activity_refresh() + 1)  # Increment the trigger to force a refresh
  }
  
  # Reactive expressions
  total_users <- reactive({
    db <- db_connect()
    total <- dbGetQuery(db, "SELECT COUNT(*) AS total FROM users")
    dbDisconnect(db)
    total$total
  })
  
  output$total_users_box <- renderValueBox({
    valueBox(
      total_users(),
      "Total Registered Users",
      icon = icon("users"),
      color = "red"
    )
  })
  
  active_users <- reactive({
    db <- db_connect()
    active <- dbGetQuery(
      db,
      "
      SELECT COUNT(DISTINCT user_id) AS active
      FROM login_activity
      WHERE timestamp > NOW() - INTERVAL 30 DAY
    "
    )
    dbDisconnect(db)
    active$active
  })
  
  output$active_users_box <- renderValueBox({
    valueBox(
      active_users(),
      "Active Users (Last 30 Days)",
      icon = icon("user-check"),
      color = "green"
    )
  })
  
  # Reactive function to fetch login activity trends
  login_activity_trends <- reactive({
    db <- db_connect()
    query <- "
    SELECT DATE(timestamp) as date, COUNT(*) as login_count
    FROM login_activity
    GROUP BY DATE(timestamp)
    ORDER BY DATE(timestamp) ASC"
    
    # Execute query and retrieve data
    activity_data <- dbGetQuery(db, query)
    dbDisconnect(db)
    
    # Ensure date column is in Date format
    activity_data$date <- as.Date(activity_data$date)
    return(activity_data)
  })
  
  # Render the login activity trend plot
  output$activity_trend_plot <- renderPlotly({
    activity_data <- login_activity_trends()
    
    plot_ly(
      activity_data,
      x = ~ date,
      y = ~ login_count,
      type = 'scatter',
      mode = 'lines+markers'
    ) %>%
      layout(
        title = "User Login Activity Trends",
        xaxis = list(title = "Date"),
        yaxis = list(title = "Number of Logins")
      )
  })
  
  # Render the financial summary table
  output$financial_summary_table <- renderDT({
    db <- db_connect()
    # Query the financial summary data
    query <- "SELECT * FROM user_financial_summary ORDER BY user_id"
    financial_summary <- dbGetQuery(db, query)
    dbDisconnect(db)
    new_colnames <- c("ClientID",
                      "Name",
                      "Total Income",
                      "Total Expenses",
                      "Net Balance")
    # Render data table
    datatable(financial_summary,
              colnames = new_colnames,
              # options = list(columnDefs = list(list(
              #   visible = FALSE, targets = c(2)
              # ))),
              rownames = FALSE)
  })
  
  
  
  # Populate the dropdown with client names
  observeEvent(input$advisor_login_button, {
    db <- db_connect()
    query <- "SELECT DISTINCT fullname FROM user_individual_transactions"
    data <- dbGetQuery(db, query)
    updateSelectInput(session, "selected_client", choices = data$fullname)
    dbDisconnect(db)
  })
  
  # Load client data from the database when the app starts or when "refresh" is clicked
  observeEvent(input$selected_client, {
    req(input$selected_client)
    db <- db_connect()
    query <- sprintf(
      "SELECT * FROM user_individual_transactions WHERE fullname = '%s'",
      input$selected_client
    )
    fetched_data <- dbGetQuery(db, query)
    dbDisconnect(db)
    # Summarize the data by transaction date and type
    summary_data <- fetched_data %>%
      group_by(transaction_date, type) %>%
      summarize(total_amount = sum(amount), .groups = 'drop')
    # Plot income and expenses with Plotly
    # Plot the summarized data
    output$income_expenses_plot <- renderPlotly({
      plot_ly(
        summary_data,
        x = ~ transaction_date,
        y = ~ total_amount,
        color = ~ type,
        type = "bar"
      ) %>%
        layout(
          title = "Income and Expense Overview by Date",
          xaxis = list(title = "Transaction Date"),
          yaxis = list(title = "Total Amount"),
          barmode = "group"
        )
    })
    
    # Calculate total income and total expenses
    total_income <- sum(fetched_data$amount[fetched_data$type == "Income"])
    total_expenses <- sum(fetched_data$amount[fetched_data$type == "Expense"])
    
    # Calculate savings
    savings <- total_income - total_expenses
    # Calculate savings percentage
    savings_percentage <- (savings / total_income) * 100
    # Savings Rate Box
    output$savings_rate_box <- renderValueBox({
      valueBox(
        paste(round(savings_percentage, 2), "%"),
        "Average Savings Rate",
        icon = icon("percent"),
        color = "green"
      )
    })
    output$expense_breakdown_plot <- renderPlotly({
      expense_data <- fetched_data %>%
        filter(type == "Expense") %>%
        group_by(category) %>%
        summarize(total_expense = sum(amount))
      plot_ly(
        expense_data,
        labels = ~ category,
        values = ~ total_expense,
        type = 'pie'
      ) %>%
        layout(title = "Expense Distribution by Category")
    })
  })
  
  # Load goals from the database for the logged-in user
  load_goals <- function(user_id) {
    db <- db_connect()
    query <- sprintf(
      "SELECT goal_id, goal_name, goal_amount, saved_amount, status FROM user_goals WHERE user_id = %d",
      user_id
    )
    goals_data <- dbGetQuery(db, query)
    dbDisconnect(db)
    return(goals_data)
  }
  
  # Initialize a reactive variable to store user goals
  user_goals <- reactiveVal(data.frame())
  
  # When the user logs in, load their goals
  observeEvent(input$login_button, {
    req(session$userData$user_id)
    user_goals(load_goals(session$userData$user_id))
  })
  
  # Render the goals table with delete buttons, excluding unnecessary columns
  output$goals_table <- renderDT({
    goals_data <- user_goals()
    
    # Select only the necessary columns for display
    display_data <- goals_data[, c("goal_name", "goal_amount", "saved_amount", "status")]
    
    # Add delete buttons to each row if `goal_id` column exists
    if ("goal_id" %in% colnames(goals_data)) {
      display_data$Action <- sprintf(
        '<button class="btn btn-danger btn-sm delete-btn" data-id="%d">Delete</button>',
        goals_data$goal_id
      )
    }
    
    datatable(display_data,
              escape = FALSE,
              options = list(pageLength = 5))
  })
  
  # JavaScript callback to register the delete button event handler
  observe({
    runjs(
      "
    $('#goals_table').on('click', '.delete-btn', function() {
      var goal_id = $(this).data('id');  // Get goal_id from button's data-id attribute
      Shiny.setInputValue('delete_goal', goal_id, {priority: 'event'});
    });
  "
    )
  })
  
  # Add a new goal
  observeEvent(input$add_goal, {
    req(session$userData$user_id)  # Ensure the user is logged in
    db <- db_connect()
    
    query <- sprintf(
      "INSERT INTO user_goals (user_id, goal_name, goal_amount, saved_amount, status)
    VALUES (%d, '%s', %f, %f, '%s')",
      session$userData$user_id,
      input$goal_name,
      input$goal_amount,
      input$saved_amount,
      input$goal_status
    )
    
    dbExecute(db, query)
    dbDisconnect(db)
    
    # Reload the goals data to include the new entry
    user_goals(load_goals(session$userData$user_id))
    
    showNotification("Goal added successfully!", type = "message")
  })
  
  # Delete a goal when delete button is clicked
  observeEvent(input$delete_goal, {
    goal_id <- as.numeric(input$delete_goal)
    db <- db_connect()
    
    query <- sprintf("DELETE FROM user_goals WHERE goal_id = %d", goal_id)
    dbExecute(db, query)
    dbDisconnect(db)
    
    # Reload goals data to update the table
    user_goals(load_goals(session$userData$user_id))
    
    showNotification("Goal deleted successfully!", type = "error")
  })
  
  
  # Populate the selectInput with user options
  observe({
    db <- db_connect()
    query <- "SELECT user_id, fullname FROM users"
    users <- dbGetQuery(db, query)
    dbDisconnect(db)
    
    # Update the selectInput with user names
    updateSelectInput(
      session,
      "selected_user",
      choices = setNames(users$user_id, users$fullname),
      selected = NULL
    )
  })
  
  # Render the filtered goals table
  output$goals_advisor <- renderDT({
    req(input$selected_user)  # Ensure a user is selected
    db <- db_connect()
    
    # Query to filter goals by selected user
    query <- sprintf(
      "SELECT fullname, goal_name, goal_amount, saved_amount, status, created_at
     FROM user_goals_advisor
     WHERE user_id = %d",
      as.numeric(input$selected_user)
    )
    goals <- dbGetQuery(db, query)
    dbDisconnect(db)
    # Define new column names for display
    new_colnames <- c("Name",
                      "Goal Name",
                      "Goal Amount",
                      "Saved Amount",
                      "Status",
                      "Created Date")
    
    # Render the datatable
    datatable(
      goals,
      colnames = new_colnames,
      rownames = FALSE,
      options = list(pageLength = 5)
    )
  })
  
  # Simulated User ID (Replace with session-based logic if required)
  #user_id <- 1  # Simulate a logged-in user with ID = 1
  
  # Load loans from the database for the logged-in user
  load_loans <- function(user_id) {
    db <- db_connect()
    query <- sprintf(
      "SELECT loan_id, loan_amount, loan_type, loan_purpose, loan_duration, interest_rate, application_date, status FROM user_loans WHERE user_id = %d",
      user_id
    )
    loans_data <- dbGetQuery(db, query)
    dbDisconnect(db)
    return(loans_data)
  }
  
  # Initialize a reactive variable to store user loans
  user_loans <- reactiveVal(data.frame())
  
  # When the user applies for a loan, insert it into the database
  observeEvent(input$apply_loan, {
    req(user_id())
    
    db <- db_connect()
    query <- sprintf(
      "INSERT INTO user_loans (user_id, loan_amount, loan_type, loan_purpose, loan_duration, interest_rate, status)
      VALUES (%d, %f, '%s', '%s', %d, %f, 'Pending')",
      user_id(),
      input$loan_amount,
      input$loan_type,
      input$loan_purpose,
      input$loan_duration,
      input$interest_rate
    )
    dbExecute(db, query)
    dbDisconnect(db)
    
    # Reload the loans data to include the new entry
    user_loans(load_loans(user_id()))
    
    showNotification("Loan application submitted successfully!", type = "message")
  })
  #
  # observe({
  #   req(session$userData$user_id)  # Ensure the user is logged in
  #   loans <- load_loans(session$userData$user_id)  # Fetch loans for the logged-in user
  #   user_loans(loans)  # Update the reactive variable
  # })
  
  output$loan_applications_table <- renderDT({
    req(session$userData$user_id)  # Ensure user is logged in before rendering the table
    
    loans_data <- user_loans()  # Get the reactive loan data
    
    if (is.null(loans_data) ||
        nrow(loans_data) == 0) {
      # Check for empty or NULL data
      # Create a placeholder "No Data Found" message
      no_data <- data.frame(Message = "No data found for loan applications.")
      datatable(no_data,
                rownames = FALSE,
                options = list(dom = 't', # Hide unnecessary table components
                               paging = FALSE))  # Disable pagination for the message)
    } else {
      # Select only the necessary columns for display
      display_data <- loans_data[, c(
        "loan_amount",
        "loan_type",
        "loan_purpose",
        "loan_duration",
        "interest_rate",
        "application_date",
        "status"
      )]
      
      # Add delete buttons to each row if `loan_id` column exists
      if ("loan_id" %in% colnames(loans_data)) {
        display_data$Action <- sprintf(
          '<button class="btn btn-danger btn-sm delete-btn" data-id="%d">Delete</button>',
          loans_data$loan_id
        )
      }
      
      datatable(display_data,
                escape = FALSE,
                options = list(pageLength = 5))
    }
  })
  
  # JavaScript callback to register the delete button event handler
  observe({
    runjs(
      "
      $('#loan_applications_table').on('click', '.delete-btn', function() {
        var loan_id = $(this).data('id');  // Get loan_id from button's data-id attribute
        Shiny.setInputValue('delete_loan', loan_id, {priority: 'event'});
      });
      "
    )
  })
  
  # Delete a loan when the delete button is clicked
  observeEvent(input$delete_loan, {
    loan_id <- as.numeric(input$delete_loan)
    db <- db_connect()
    
    query <- sprintf("DELETE FROM user_loans WHERE loan_id = %d", loan_id)
    dbExecute(db, query)
    dbDisconnect(db)
    
    # Reload loans data to update the table
    user_loans(load_loans(user_id()))
    
    showNotification("Loan deleted successfully!", type = "error")
  })
  
  # Fetch all loan applications for the Bank Representative
  fetch_all_loans <- function() {
    db <- db_connect()
    query <- "SELECT loan_id, user_id, loan_amount, loan_type, loan_purpose, loan_duration, interest_rate, application_date, status FROM user_loans"
    all_loans <- dbGetQuery(db, query)
    dbDisconnect(db)
    return(all_loans)
  }
  
  # Reactive value to store all loan applications
  all_loans <- reactiveVal(data.frame())
  
  # Load all loan applications on app start or refresh
  observe({
    all_loans(fetch_all_loans())
  })
  
  # Reactive data for all loans
  all_loans <- reactiveVal(fetch_all_loans())
  
  # Apply filters when the user clicks "Apply Filters"
  observeEvent(input$apply_filters, {
    loans <- fetch_all_loans()  # Fetch all loans
    
    # Apply status filter
    if (input$filter_status != "All") {
      loans <- loans[loans$status == input$filter_status, ]
    }
    
    # Apply loan type filter
    if (input$filter_loan_type != "All") {
      loans <- loans[loans$loan_type == input$filter_loan_type, ]
    }
    
    # Apply amount range filter
    loans <- loans[loans$loan_amount >= input$filter_min_amount &
                     loans$loan_amount <= input$filter_max_amount, ]
    
    # Update the reactive data with filtered loans
    all_loans(loans)
  })
  
  # Reactive data for all loans
  all_loans <- reactiveVal(fetch_all_loans())
  
  # Apply filters when the user clicks "Apply Filters"
  observeEvent(input$apply_filters, {
    loans <- fetch_all_loans()  # Fetch all loans
    
    # Apply status filter
    if (input$filter_status != "All") {
      loans <- loans[loans$status == input$filter_status, ]
    }
    
    # Apply loan type filter
    if (input$filter_loan_type != "All") {
      loans <- loans[loans$loan_type == input$filter_loan_type, ]
    }
    
    # Apply amount range filter
    loans <- loans[loans$loan_amount >= input$filter_min_amount &
                     loans$loan_amount <= input$filter_max_amount, ]
    
    # Update the reactive data with filtered loans
    all_loans(loans)
  })
  
  # Render the filtered loan applications table
  output$all_loans_table <- renderDT({
    loans <- all_loans()
    
    if (nrow(loans) == 0) {
      return(datatable(
        data.frame(Message = "No loans found"),
        rownames = FALSE,
        options = list(dom = 't')
      ))
    }
    
    # Add Approve/Reject buttons
    loans$Action <- sprintf(
      '<button class="btn btn-success btn-sm action-btn" data-id="%d" data-action="approve">Approve</button>
     <button class="btn btn-danger btn-sm action-btn" data-id="%d" data-action="reject">Reject</button>',
      loans$loan_id,
      loans$loan_id
    )
    
    datatable(
      loans,
      escape = FALSE,
      options = list(pageLength = 10),
      rownames = FALSE
    )
  })
  
  # Use JavaScript to capture button clicks and send data to Shiny
  observe({
    runjs(
      "
      $('#all_loans_table').on('click', '.action-btn', function() {
        var loan_id = $(this).data('id');  // Get the loan ID from the button
        var action = $(this).data('action');  // Get the action (approve/reject)
        Shiny.setInputValue('loan_action', {id: loan_id, action: action}, {priority: 'event'});
      });
    "
    )
  })
  
  # Handle Approve/Reject button clicks
  observeEvent(input$loan_action, {
    loan_action <- input$loan_action
    loan_id <- as.numeric(loan_action$id)  # Extract loan ID
    action <- loan_action$action  # Extract action (approve/reject)
    refresh_trigger(refresh_trigger() + 1)
    if (!is.null(loan_id) && !is.null(action)) {
      db <- db_connect()
      if (action == "approve") {
        query <- sprintf("UPDATE user_loans SET status = 'Approved' WHERE loan_id = %d",
                         loan_id)
        dbExecute(db, query)
        showNotification(sprintf("Loan ID %d approved successfully!", loan_id),
                         type = "message")
      } else if (action == "reject") {
        query <- sprintf("UPDATE user_loans SET status = 'Rejected' WHERE loan_id = %d",
                         loan_id)
        dbExecute(db, query)
        showNotification(sprintf("Loan ID %d rejected successfully!", loan_id),
                         type = "error")
      }
      dbDisconnect(db)
      
      # Refresh the loan applications table
      all_loans(fetch_all_loans())
    }
  })
  
  refresh_trigger <- reactiveVal(0)
  
  # Loan insights
  output$loan_status_pie <- renderPlotly({
    refresh_trigger()
    data <- fetch_all_loans() %>%
      group_by(status) %>%
      summarize(count = n())
    
    plot_ly(
      data,
      labels = ~ status,
      values = ~ count,
      type = 'pie'
    ) %>%
      layout(title = "Loan Status Distribution")
  })
  
  output$loan_type_bar <- renderPlotly({
    refresh_trigger()
    data <- fetch_all_loans() %>%
      group_by(loan_type) %>%
      summarize(total_amount = sum(loan_amount))
    
    plot_ly(
      data,
      x = ~ loan_type,
      y = ~ total_amount,
      type = 'bar',
      color = ~ loan_type
    ) %>%
      layout(
        title = "Total Loan Amount by Type",
        xaxis = list(title = "Loan Type"),
        yaxis = list(title = "Total Amount")
      )
  })
  
  output$loan_trend_line <- renderPlotly({
    refresh_trigger()
    data <- fetch_all_loans() %>%
      mutate(application_month = floor_date(as.Date(application_date), "month")) %>%
      group_by(application_month) %>%
      summarize(count = n())
    
    plot_ly(
      data,
      x = ~ application_month,
      y = ~ count,
      type = 'scatter',
      mode = 'lines+markers'
    ) %>%
      layout(
        title = "Monthly Loan Applications",
        xaxis = list(title = "Month"),
        yaxis = list(title = "Number of Applications")
      )
  })
  
  # Function to fetch user list for select input
  fetch_users <- function() {
    db <- db_connect()
    query <- "SELECT user_id, fullname FROM users"
    users <- dbGetQuery(db, query)
    dbDisconnect(db)
    return(users)
  }
  
  # Function to fetch income and expense data
  fetch_income_expense_data <- function(user_id = "all") {
    db <- db_connect()
    if (user_id == "all") {
      query <- "
        SELECT u.fullname,
               COALESCE(SUM(i.income_amount), 0) AS total_income,
               COALESCE(SUM(e.amount), 0) AS total_expense
        FROM users u
        LEFT JOIN income i ON u.user_id = i.user_id
        LEFT JOIN expenses e ON u.user_id = e.user_id
        GROUP BY u.fullname
      "
    } else {
      query <- sprintf(
        "
        SELECT u.fullname,
               COALESCE(SUM(i.income_amount), 0) AS total_income,
               COALESCE(SUM(e.amount), 0) AS total_expense
        FROM users u
        LEFT JOIN income i ON u.user_id = i.user_id
        LEFT JOIN expenses e ON u.user_id = e.user_id
        WHERE u.user_id = %d
        GROUP BY u.fullname
      ",
        as.numeric(user_id)
      )
    }
    data <- dbGetQuery(db, query)
    dbDisconnect(db)
    return(data)
  }
  
  # Populate the user selection dropdown dynamically
  observe({
    users <- fetch_users()
    choices <- c("All Users" = "all", setNames(users$user_id, users$fullname))
    updateSelectInput(session,
                      "selected_users",
                      choices = choices,
                      selected = "all")
  })
  
  # Reactive function to fetch filtered data
  filtered_income_expense <- reactive({
    fetch_income_expense_data(input$selected_users)
  })
  
  # Render Income Bar Chart
  output$user_income_bar <- renderPlotly({
    data <- filtered_income_expense()
    plot_ly(
      data,
      x = ~ fullname,
      y = ~ total_income,
      type = "bar",
      name = "Income",
      color = ~ fullname
    ) %>%
      layout(
        title = "User Income Overview",
        xaxis = list(title = "Users"),
        yaxis = list(title = "Total Income ($)")
      )
  })
  
  # Render Expense Pie Chart
  output$user_expense_pie <- renderPlotly({
    data <- filtered_income_expense()
    plot_ly(
      data,
      labels = ~ fullname,
      values = ~ total_expense,
      type = "pie"
    ) %>%
      layout(title = "User Expense Distribution")
  })
  
  # Render Income and Expense Summary Table
  output$income_expense_table <- renderDT({
    data <- filtered_income_expense()
    datatable(data,
              options = list(pageLength = 5),
              rownames = FALSE)
  })
  
  # Total Loans
  total_loans <- reactive({
    db <- db_connect()
    loans <- dbGetQuery(db,
                        "SELECT COUNT(*) AS total FROM user_loans WHERE status = 'Approved'")
    dbDisconnect(db)
    loans$total
  })
  
  output$loan_status_box <- renderValueBox({
    valueBox(
      total_loans(),
      "Approved Loans",
      icon = icon("check-circle"),
      color = "blue"
    )
  })
  
  # Loan Management Table
  output$loan_table <- renderDT({
    db <- db_connect()
    loans <- dbGetQuery(
      db,
      "
      SELECT loan_id, user_id, loan_amount, loan_type, loan_duration, status
      FROM user_loans
      "
    )
    dbDisconnect(db)
    datatable(loans,
              options = list(pageLength = 5),
              rownames = FALSE)
  })
  
  # Reactive values to store budgets and alerts
  budget_data <- reactiveVal(data.frame(
    Category = character(),
    Budget = numeric(),
    Spent = numeric(),
    Remaining = numeric(),
    stringsAsFactors = FALSE
  ))
  
  # Set Budget
  observeEvent(input$set_budget, {
    req(input$budget_category, input$budget_amount)
    
    user_id <- 1  # Replace with session$userData$user_id if user login is implemented
    category <- input$budget_category
    budget_amount <- input$budget_amount
    
    db <- db_connect()
    query <- sprintf("
      INSERT INTO budgets (user_id, category, budget_amount)
      VALUES (%d, '%s', %f)
      ON DUPLICATE KEY UPDATE budget_amount = %f",
                     user_id, category, budget_amount, budget_amount)
    dbExecute(db, query)
    dbDisconnect(db)
    
    refresh_budget_data()
    showNotification("Budget set successfully!", type = "message")
  })
  
  # Clear All Budgets
  observeEvent(input$clear_budgets, {
    user_id <- 1  # Replace with session$userData$user_id if user login is implemented
    
    db <- db_connect()
    query <- sprintf("DELETE FROM budgets WHERE user_id = %d", user_id)
    dbExecute(db, query)
    dbDisconnect(db)
    
    refresh_budget_data()
    showNotification("All budgets cleared successfully!", type = "error")
  })
  
  # Fetch Budget Data
  refresh_budget_data <- function() {
    user_id <- 1  # Replace with session$userData$user_id if user login is implemented
    
    db <- db_connect()
    budget_query <- sprintf("SELECT category, budget_amount FROM budgets WHERE user_id = %d", user_id)
    expense_query <- sprintf("
      SELECT category, SUM(amount) AS spent_amount
      FROM expenses
      WHERE user_id = %d
      GROUP BY category", 
                             user_id)
    
    budgets <- dbGetQuery(db, budget_query)
    expenses <- dbGetQuery(db, expense_query)
    dbDisconnect(db)
    
    # Merge budgets with expenses and calculate remaining amounts
    merged_data <- merge(budgets, expenses, by = "category", all.x = TRUE)
    merged_data$spent_amount[is.na(merged_data$spent_amount)] <- 0
    merged_data$remaining <- merged_data$budget_amount - merged_data$spent_amount
    merged_data <- merged_data %>%
      rename(Category = category, Budget = budget_amount, Spent = spent_amount, Remaining = remaining)
    
    budget_data(merged_data)
  }
  
  # Render Budget Table
  output$budget_table <- renderDT({
    datatable(budget_data(), options = list(pageLength = 5))
  })
  
  # Generate Budget Alerts
  output$budget_alerts <- renderUI({
    data <- budget_data()
    
    if (nrow(data) == 0) {
      return(tags$div(
        class = "alert alert-info",
        "No budgets set. Please add a budget to view alerts."
      ))
    }
    
    # Use lapply to iterate through each row of the budget data
    alerts <- lapply(seq_len(nrow(data)), function(i) {
      row <- data[i, ]
      category <- row["Category"]
      spent <- as.numeric(row["Spent"])
      budget <- as.numeric(row["Budget"])
      remaining <- as.numeric(row["Remaining"])
      
      if (remaining < 0) {
        tags$div(
          class = "alert alert-danger",
          sprintf("You have exceeded the budget for '%s'. Budget: $%.2f, Spent: $%.2f.", category, budget, spent)
        )
      } else if (remaining < budget * 0.1) {
        tags$div(
          class = "alert alert-warning",
          sprintf("Nearing budget limit for '%s'. Budget: $%.2f, Spent: $%.2f.", category, budget, spent)
        )
      }
    })
    
    # Combine the list of alerts into a single UI output
    do.call(tagList, alerts)
  })
  
  # Generate Alerts for the Notification Icon
  output$alert_notifications <- renderUI({
    data <- budget_data()
    
    if (nrow(data) == 0) {
      return(tags$div(
        class = "dropdown-item",
        "No alerts to display."
      ))
    }
    
    # Create notifications dynamically
    notifications <- lapply(seq_len(nrow(data)), function(i) {
      row <- data[i, ]
      category <- row["Category"]
      spent <- as.numeric(row["Spent"])
      budget <- as.numeric(row["Budget"])
      remaining <- as.numeric(row["Remaining"])
      
      if (remaining < 0) {
        tags$li(
          class = "dropdown-item text-danger",
          sprintf("Exceeded budget for '%s'! Budget: $%.2f, Spent: $%.2f.", category, budget, spent)
        )
      } else if (remaining < budget * 0.1) {
        tags$li(
          class = "dropdown-item text-warning",
          sprintf("Nearing budget limit for '%s'. Budget: $%.2f, Spent: $%.2f.", category, budget, spent)
        )
      }
    })
    
    # Combine notifications into a single output
    do.call(tagList, notifications)
  })
  
  # Render Alert Count for the Badge
  output$alert_count_badge <- renderText({
    data <- budget_data()
    alert_count <- sum(data$Remaining < 0 | data$Remaining < data$Budget * 0.1)
    if (alert_count > 0) {
      return(as.character(alert_count))
    } else {
      return("")  # Hide badge when no alerts
    }
  })
  
  output$showAlertFlag <- reactive({
    showAlerts()
  })
  outputOptions(output, "showAlertFlag", suspendWhenHidden = FALSE)
  
  # Monthly Trends Plot
  output$monthly_trends_plot <- renderPlotly({
    user_id <- session$userData$user_id
    income_data <- dbGetQuery(db,
                              sprintf("SELECT * FROM income WHERE user_id = '%s'", user_id))
    expense_data <- dbGetQuery(db,
                              sprintf("SELECT * FROM expenses WHERE user_id = '%s'", user_id))
    trends_data <- bind_rows(
      income_data %>%
        mutate(type = "Income", 
               month = floor_date(as.Date(income_date, "%Y-%m-%d"), "month"), 
               amount = as.numeric(income_amount)),
      expense_data %>%
        mutate(type = "Expense", 
               month = floor_date(as.Date(expense_date, "%Y-%m-%d"), "month"))
    ) %>%
      group_by(month, type) %>%
      summarize(total = sum(amount, na.rm = TRUE), .groups = "drop")
    
    plot_ly(
      trends_data,
      x = ~month,
      y = ~total,
      color = ~type,
      type = "bar"
    ) %>%
      layout(
        title = "Monthly Income vs Expenses",
        xaxis = list(title = "Month"),
        yaxis = list(title = "Amount ($)")
      )
  })
  
}

shinyApp(ui = ui, server = server)