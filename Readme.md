# Combine Networking Lab

A lab project to try out using reactive programming with `Combine` framework for network tasks.

For more background information, please check out my separate [Medium article](https://medium.com/@rdchc/my-combine-networking-lab-project-86c63404ca7c).

## Tasks

This section enumerates some actual tasks for the project.

- [X] Design and implement user interfaces

- [X] Create mock requests using asynchronous tasks

- [X] Decide a source for free-of-charge APIs

- [X] Create network requests using `Combine` framework

- [X] Create handy operators

- [X] Make unit tests for self-created functions

## Target Operations

Some use cases that can be implemented hopefully.

- [X] Fetch and show contents from external APIs

- [X] Show error, with or without fallback contents, in case the API returns an error

- [X] Cancel anytime by tapping buttons

- [X] Disable re-fetching while in progress

## API Source

This project uses the Free Meal API from [TheMealDB.com](https://www.themealdb.com/api.php). This website provides a variety of free-of-charge APIs related to meals and recipes, including meal search by name, meal list in a specified category and random meals.

For API key issue, since this project is experimental and will never go production, the test API key provided from the website is used according to the website's instructions.

## Findings

Please refer to the [Medium article](https://medium.com/@rdchc/making-network-requests-using-combine-framework-ff34151611db) about my findings on making network requests as well as handling loading states and cancellations.

## Useful Resources

Some websites, books or tutorials for references for network tasks.

- *Combine: Asynchronous Programming with Swift* (2nd edition, 2020) by Florent Pillet, Shai Mishali, Scott Gardner and Marin Todorov. Accessible in [raywenderlich.com](http://raywenderlich.com/books/combine-asynchronous-programming-with-swift/). Free of charge for limited version.
