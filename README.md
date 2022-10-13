# MovieFeed - Test Driven Development Example App

# BDD Specs

Story: User request to see the feed

NARRATIVE #1

As an online user I want the app to load upcoming movies

Scenarios ( Accaptance criteria )

![image](https://user-images.githubusercontent.com/85555736/191008585-a9f4fc99-8b80-497d-a236-5fc7b0cd2b35.png)

NARRATIVE #2

As an offline user i want the app to show the latest saced version of my feed.

Scenarios ( Accaptance criteria )

![image](https://user-images.githubusercontent.com/85555736/191011747-7d27ae4f-7975-4b53-be99-0d0f4120ab0d.png)


## USE CASES

###Load Feed From Remote Use Case

1) Data:
•	URL

2) Primary course (happy path):
•	Execute “Load” command with above data
•	System downloads data from URL
•	System validates downloaded data
•	System creates feed items from valid data
•	System delivers feed items

3) Invalid Data – error course (sad path):
•	System delivers invalid error

4) No connectivity – error course (sad path):
•	System delivers connectivity error


# Architecture
![image](https://user-images.githubusercontent.com/85555736/191011147-8ce46a75-394c-4b8a-a282-72f5b59b7cb6.png)
