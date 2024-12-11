# ReadMe

 <img width="2560" alt="Shiny_app" src="https://github.com/user-attachments/assets/fc1dd04d-15ab-4f9e-b230-72d6033f42da">

This is a very basic 'shiny' app designed to work locally with the users having RStudio and R installed.


## Background
The use case is reviewing of abstracts for a conference (see 'abstracts.xlsx' for the required format). Rather than hosting a giant spreadsheet in which all reviewers provide their scores, each reviewer scores the abstract and then sends their .xlsx to the chair who can then easily combine them.

Further extensions are possible (e.g., hosting online, etc.)

Disclosure, I am a novice and have heavily relied on AI to help me build this Shiny app. I don't intend to waste more time on it :)

## Steps

* Ensure you have a folder with the app and abstracts.xlsx file included. (You can easily modify the code if you'd prefer to). Ensure you have the relevant R packages installed.
* In RStudio, click [run app](https://mastering-shiny.org/basic-app.html)
* in the viewer, you'll see the abstract to score. Scores are stored in 'scores_R1.xlsx', etc. The app should keep track of where you left off - but only tested the functionality in Rstudio not when loading in browser. (In case you forgot where you were, you can find where you were in current_abstract_index_Rx.txt. (x referring to your reviewer number). 'randomized_order_Rx.txt' stores the randomisation

## Limitations
* Currently set to four reviewers.
* Currently only set to two review criteria to be scored on a 0-10 scale.
* Limited functionality when loading in browser as compared to inside RStudio.

## Acknowledgments
I would like to express my gratitude to the developers and communities behind the following tools and packages, which used in this app:

- **[R](https://www.r-project.org/)**: A powerful language and environment for statistical computing and graphics.
- **[RStudio](https://www.rstudio.com/)**: An integrated development environment (IDE) for R that makes data analysis and visualization more accessible.
- **[Shiny](https://shiny.rstudio.com/)**: A web application framework for R that allows for the creation of interactive web applications.
- **[Tidyverse](https://www.tidyverse.org/)**: A collection of R packages designed for data science, including tools for data manipulation, visualization, and programming.
- **[Readxl](https://readxl.tidyverse.org/)**: An R package for reading Excel files.
- **[Writexl](https://cran.r-project.org/web/packages/writexl/index.html)**: An R package for writing Excel xlsx and xls files.
- **[ShinyJs](https://deanattali.com/shinyjs/)**: A package that extends Shiny with JavaScript functionality, making it easier to create dynamic and interactive web applications.

And Mistral.ai which has helped me a bunch with the coding.


