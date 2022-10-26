# MovieFeed - Test Driven Development Example App

# Architecture 
#### Updated according to project progression *
![image](https://user-images.githubusercontent.com/85555736/198049989-dcd27d30-da5c-4489-ae94-a91c50a8c549.png)

## Resources and concepts:

- Architecture concept: https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html
- App architecture: https://www.raywenderlich.com/books/advanced-ios-app-architecture/v4.0
- Core Data Book1: https://www.objc.io/books/core-data/
- Core Data Book2: https://www.raywenderlich.com/books/core-data-by-tutorials/v8.0
- TDD Book1: https://www.raywenderlich.com/books/ios-test-driven-development-by-tutorials/v2.0
- TDD Book2: https://www.oreilly.com/library/view/ios-unit-testing/9781680507966/
- Design pattern concepts: “Design Patterns: Elements of Reusable Object-Oriented Software” by Gang of Four
- Design pattern book: https://www.raywenderlich.com/books/design-patterns-by-tutorials/v3.0
- Design pattern website: https://refactoring.guru/design-patterns

## CI Builds:
https://github.com/shotikoKlibadze/MovieFeed/actions

# BDD Specs

Story: User request to see the feed

NARRATIVE #1

As an online user I want the app to load upcoming movies

Scenarios ( Accaptance criteria )

![image](https://user-images.githubusercontent.com/85555736/191008585-a9f4fc99-8b80-497d-a236-5fc7b0cd2b35.png)

NARRATIVE #2

As an offline user i want the app to show the latest saced version of my feed.

Scenarios ( Accaptance criteria )

![image](https://user-images.githubusercontent.com/85555736/195566398-4460b680-cbc7-4f04-8609-6f5fdaee61c8.png)


## USE CASES



## 1. Load Feed From Remote Use Case

#### Data:

•	URL

#### Primary course (happy path):
•	Execute “Load” command with above data

•	System downloads data from URL

•	System validates downloaded data

•	System creates feed items from valid data

•	System delivers feed items

#### Invalid Data – error course (sad path):

•	System delivers invalid error

#### No connectivity – error course (sad path):

•	System delivers connectivity error



## 2. Load Feed From Cache Use Case

#### Data:

•	Max Age (7 days old)

#### Primary course (happy path):

•	Execute “Load Feed Items” command with above data

•	System fetches feed data from cache

•	System validates cache is less than seven days old

•	System creates feed items from cached data

•	System delivers feed items

#### Retrieval error course (sad path):

•	System deletes cache

•	System delivers error

#### Expired cache course (sad path):

•	System deletes cache

•	System delivers error

#### Epmty cache course (sad path):

•	System delivers no feed items



## 3. Cache Feed Use Case

#### Data:

•	Feed Items

#### Primary course (happy path):

•	Execute “Save Feed Items” command with above data

•	System deletes old cache data

•	System encodes feed items

•	System timestamos the new cache

•	System saves new data

•	System delivers success message

#### Deleting error course (sad path):

•	System delivers error

#### Saving cache error course (sad path):

•	System delivers error


