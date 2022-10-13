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

#### Error course (sad path):

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


# Architecture
![image](https://user-images.githubusercontent.com/85555736/195566920-de0776c3-a0ad-4785-8ed5-dc0ce3d84f64.png)
