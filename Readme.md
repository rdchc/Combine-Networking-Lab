# Combine Networking Lab

A lab project to try out using reactive programming with `Combine` framework for network tasks.

## Objectives

This section lists out the main objectives of this lab project.

- Simulate network requests by asynchronous tasks as the first step

- Explore how common network-related tasks (in later section) can be performed using `Combine` framework

- Improve codes in the process for efficiency

- Create handy operators for network tasks

- Find out and recommend useful resources

## Tasks

This section enumerates some actual tasks for the project.

- [X] Design and implement user interfaces

- [X] Create mock requests using asynchronous tasks

- [X] Decide a source for free-of-charge APIs

- [X] Create network requests using `Combine` framework

- [ ] Create handy operators

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

Here are some findings during the exploration.

### Cancellation

In normal practice, we often create a bag of cancellables as `Set<AnyCancellable>` so that all subscriptions can be kept by strongly referencing them, except when you manually call `cancel()` to each instance inside, or when the class holding the set is deinitialized.

If you want to cancel the previous subscription when subscribing a new one, assign all the related subscriptions into the same `AnyCancellable` instance.

An example in the project is to keep fetching meal categories and meal list subscriptions into the same variable. In this way, a new meal API request will cancel the previous one since the previous subscription no longer has any strong reference.

## Useful Resources

Some websites, books or tutorials for reference for creating network requests.

- *Combine: Asynchronous Programming with Swift* (2nd edition, 2020) by Florent Pillet, Shai Mishali, Scott Gardner and Marin Todorov. Accessible in [raywenderlich.com](http://raywenderlich.com/books/combine-asynchronous-programming-with-swift/). Free of charge for limited version.
