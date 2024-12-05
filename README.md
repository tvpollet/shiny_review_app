# ReadMe

<img width="1512" alt="Shiny_app" src="https://github.com/user-attachments/assets/581c7965-1f0d-491c-b8f6-14b062a6f8a2">

This is a very basic app designed to work locally with the users having RStudio and R installed.



## Background
The use case is reviewing of abstracts for a conference. Rather than hosting a giant spreadsheet in which all reviewers provide their scores. Each reviewer scores the abstract and then sends their .xlsx to the chair who can then easily combine them.

Further extensions are possible (e.g., hosting online, etc.)

Disclosure, I am a novice and have heavily relied on AI to help me build this Shiny app. I don't intend to waste more time on it :)

## Steps

* Ensure you have a folder with the app and abstracts.xlsx file included. (You can easily modify the code if you'd prefer to). Ensure you have the relevant R packages installed.
* In RStudio, click [run app](https://mastering-shiny.org/basic-app.html)
* in the viewer, you'll see the abstract to score. Scores are stored in 'scores.xlsx'. The app should keep track of where you left off. (In case you forgot where you were, you can find where you were in current_abstract_index_Rx.txt. (x referring to your reviewer number). 'randomized_order_Rx.txt' stores the randomisation

## Limitations
* There is only one randomisation for _all_ reviewers.
* Currently set to four reviewers.
* Currently only set to two review criteria to be scored on a 0-10 scale.



