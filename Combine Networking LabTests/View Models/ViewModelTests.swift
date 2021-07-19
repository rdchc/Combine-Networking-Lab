//
//  ViewModelTests.swift
//  Combine Networking LabTests
//
//  Created by CCH on 15/6/2021.
//

import XCTest
import Combine
@testable import Combine_Networking_Lab

class ViewModelTests: XCTestCase {
  var sut: ViewModel!
  fileprivate var mockMealAPIClient: MockMealAPIClient!
  var subscriptions = Set<AnyCancellable>()
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    // Put setup code here. This method is called before the invocation of each test method in the class.
    mockMealAPIClient = MockMealAPIClient()
    sut = ViewModel(mealApiClient: mockMealAPIClient)
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    sut = nil
    mockMealAPIClient = nil
    subscriptions.removeAll()
    
    try super.tearDownWithError()
  }
  
  
  // MARK: - Fetching
  
  func testUpdateFetchCategoriesStatusWhenFetch() {
    // Given
    let expected: FetchStatus = .ongoing
    var result: FetchStatus = .ready
    sut.categoriesItemViewModel.statusSubject
      .dropFirst()
      .sink(receiveValue: { result = $0 })
      .store(in: &subscriptions)
    
    // When
    sut.fetchCategories()
    
    // Then
    XCTAssertEqual(expected, result, "Status expected to be \(expected) but was \(result)")
  }
  
  func testUpdatePastaMealStatusWhenFetch() {
    // Given
    let expected: FetchStatus = .ongoing
    var result: FetchStatus = .ready
    sut.pastaMealsItemViewModel.statusSubject
      .dropFirst()
      .sink(receiveValue: { result = $0 })
      .store(in: &subscriptions)
    
    // When
    sut.fetchPastaMeals()
    
    // Then
    XCTAssertEqual(expected, result, "Status expected to be \(expected) but was \(result)")
  }
  
  func testUpdateBreakfastMealStatusWhenFetch() {
    // Given
    let expected: FetchStatus = .ongoing
    var result: FetchStatus = .ready
    sut.breakfastMealsItemViewModel.statusSubject
      .dropFirst()
      .sink(receiveValue: { result = $0 })
      .store(in: &subscriptions)
    
    // When
    sut.fetchBreakfastMeals()
    
    // Then
    XCTAssertEqual(expected, result, "Status expected to be \(expected) but was \(result)")
  }
  
  
  // MARK: - Fetch success
  
  func testFetchCategoriesSuccess() {
    // Given
    let expectation = self.expectation(description: #function)
    DispatchQueue.main.asyncAfter(deadline: .now() + mockMealAPIClient.delay) {
      expectation.fulfill()
    }
    
    let expectedStatus: FetchStatus = .finished
    var resultStatus: FetchStatus = .ready
    sut.categoriesItemViewModel.statusSubject
      .dropFirst()
      .sink(receiveValue: { resultStatus = $0 })
      .store(in: &subscriptions)
    
    let expectedDetail = "\(mockMealAPIClient.categories.count) categories"
    var resultDetail: String?
    sut.categoriesItemViewModel.$detail
      .dropFirst()
      .sink(receiveValue: { resultDetail = $0 })
      .store(in: &subscriptions)
    
    // When
    sut.fetchCategories()
    waitForExpectations(timeout: mockMealAPIClient.delay + 1, handler: nil)
    
    // Then
    XCTAssertEqual(expectedStatus, resultStatus, "Status expected to be \(expectedStatus) but was \(resultStatus)")
    XCTAssertEqual(expectedDetail, resultDetail, "Detail text expected to be \(expectedDetail) but was \(resultDetail ?? "(none)")")
  }
  
  func testFetchPastaMealsSuccess() {
    // Given
    let expectation = self.expectation(description: #function)
    DispatchQueue.main.asyncAfter(deadline: .now() + mockMealAPIClient.delay) {
      expectation.fulfill()
    }
    
    let expectedStatus: FetchStatus = .finished
    var resultStatus: FetchStatus = .ready
    sut.pastaMealsItemViewModel.statusSubject
      .dropFirst()
      .sink(receiveValue: { resultStatus = $0 })
      .store(in: &subscriptions)
    
    let expectedDetail = "\(mockMealAPIClient.meals.count) meals for pasta"
    var resultDetail: String?
    sut.pastaMealsItemViewModel.$detail
      .dropFirst()
      .sink(receiveValue: { resultDetail = $0 })
      .store(in: &subscriptions)
    
    // When
    sut.fetchPastaMeals()
    waitForExpectations(timeout: mockMealAPIClient.delay + 1, handler: nil)
    
    // Then
    XCTAssertEqual(expectedStatus, resultStatus, "Status expected to be \(expectedStatus) but was \(resultStatus)")
    XCTAssertEqual(expectedDetail, resultDetail, "Detail text expected to be \(expectedDetail) but was \(resultDetail ?? "(none)")")
  }
  
  func testFetchBreakfastMealsSuccess() {
    // Given
    let expectation = self.expectation(description: #function)
    DispatchQueue.main.asyncAfter(deadline: .now() + mockMealAPIClient.delay) {
      expectation.fulfill()
    }
    
    let expectedStatus: FetchStatus = .finished
    var resultStatus: FetchStatus = .ready
    sut.breakfastMealsItemViewModel.statusSubject
      .dropFirst()
      .sink(receiveValue: { resultStatus = $0 })
      .store(in: &subscriptions)
    
    let expectedDetail = "\(mockMealAPIClient.meals.count) meals for breakfast"
    var resultDetail: String?
    sut.breakfastMealsItemViewModel.$detail
      .dropFirst()
      .sink(receiveValue: { resultDetail = $0 })
      .store(in: &subscriptions)
    
    // When
    sut.fetchBreakfastMeals()
    waitForExpectations(timeout: mockMealAPIClient.delay + 1, handler: nil)
    
    // Then
    XCTAssertEqual(expectedStatus, resultStatus, "Status expected to be \(expectedStatus) but was \(resultStatus)")
    XCTAssertEqual(expectedDetail, resultDetail, "Detail text expected to be \(expectedDetail) but was \(resultDetail ?? "(none)")")
  }
  
  
  // MARK: - Fetch failed
  
  func testFetchCategoriesFailed() {
    // Given
    mockMealAPIClient.error = .mockError
    
    let expectation = self.expectation(description: #function)
    DispatchQueue.main.asyncAfter(deadline: .now() + mockMealAPIClient.delay) {
      expectation.fulfill()
    }
    
    let expectedStatus: FetchStatus = .ready
    var resultStatus: FetchStatus = .ready
    sut.categoriesItemViewModel.statusSubject
      .dropFirst()
      .sink(receiveValue: { resultStatus = $0 })
      .store(in: &subscriptions)

    let expectedAlertMessage = "Error occurred, please try again."
    var resultAlertMessage: String?
    sut.showInfoAlertSubject
      .sink(receiveValue: { resultAlertMessage = $0 })
      .store(in: &subscriptions)

    // When
    sut.fetchCategories()
    waitForExpectations(timeout: mockMealAPIClient.delay + 1, handler: nil)

    // Then
    XCTAssertEqual(expectedStatus, resultStatus, "Status expected to be \(expectedStatus) but was \(resultStatus)")
    XCTAssertEqual(expectedAlertMessage, resultAlertMessage, "Alert message expected to be \(expectedAlertMessage) but was \(resultAlertMessage ?? "(none)")")
  }

  func testFetchPastaMealsFailed() {
    // Given
    mockMealAPIClient.error = .mockError
    
    let expectation = self.expectation(description: #function)
    DispatchQueue.main.asyncAfter(deadline: .now() + mockMealAPIClient.delay) {
      expectation.fulfill()
    }
    
    let expectedStatus: FetchStatus = .ready
    var resultStatus: FetchStatus = .ready
    sut.pastaMealsItemViewModel.statusSubject
      .dropFirst()
      .sink(receiveValue: { resultStatus = $0 })
      .store(in: &subscriptions)

    let expectedAlertMessage = "Error occurred, please try again."
    var resultAlertMessage: String?
    sut.showInfoAlertSubject
      .sink(receiveValue: { resultAlertMessage = $0 })
      .store(in: &subscriptions)

    // When
    sut.fetchPastaMeals()
    waitForExpectations(timeout: mockMealAPIClient.delay + 1, handler: nil)

    // Then
    XCTAssertEqual(expectedStatus, resultStatus, "Status expected to be \(expectedStatus) but was \(resultStatus)")
    XCTAssertEqual(expectedAlertMessage, resultAlertMessage, "Alert message expected to be \(expectedAlertMessage) but was \(resultAlertMessage ?? "(none)")")
  }

  func testFetchBreakfastMealsFailed() {
    // Given
    mockMealAPIClient.error = .mockError
    
    let expectation = self.expectation(description: #function)
    DispatchQueue.main.asyncAfter(deadline: .now() + mockMealAPIClient.delay) {
      expectation.fulfill()
    }
    
    let expectedStatus: FetchStatus = .ready
    var resultStatus: FetchStatus = .ready
    sut.breakfastMealsItemViewModel.statusSubject
      .dropFirst()
      .sink(receiveValue: { resultStatus = $0 })
      .store(in: &subscriptions)

    let expectedAlertMessage = "Error occurred, please try again."
    var resultAlertMessage: String?
    sut.showInfoAlertSubject
      .sink(receiveValue: { resultAlertMessage = $0 })
      .store(in: &subscriptions)

    // When
    sut.fetchBreakfastMeals()
    waitForExpectations(timeout: mockMealAPIClient.delay + 1, handler: nil)

    // Then
    XCTAssertEqual(expectedStatus, resultStatus, "Status expected to be \(expectedStatus) but was \(resultStatus)")
    XCTAssertEqual(expectedAlertMessage, resultAlertMessage, "Alert message expected to be \(expectedAlertMessage) but was \(resultAlertMessage ?? "(none)")")
  }
  
  
  // MARK: - Fetch cancel
  
  func testFetchCategoriesCancelled() {
    // Given
    mockMealAPIClient.error = .mockError
    
    let expectation = self.expectation(description: #function)
    DispatchQueue.main.asyncAfter(deadline: .now() + mockMealAPIClient.delay) {
      expectation.fulfill()
    }
    
    let expectedStatus: FetchStatus = .ready
    var resultStatus: FetchStatus = .ongoing
    sut.categoriesItemViewModel.statusSubject
      .sink(receiveValue: { resultStatus = $0 })
      .store(in: &subscriptions)
    
    let expectedDetail: String? = sut.categoriesItemViewModel.detail
    var resultDetail: String?
    sut.categoriesItemViewModel.$detail
      .sink(receiveValue: { resultDetail = $0 })
      .store(in: &subscriptions)
    
    // When
    sut.fetchCategories()
    DispatchQueue.main.asyncAfter(deadline: .now() + mockMealAPIClient.delay/2) { [weak sut] in
      sut?.cancel()
    }
    waitForExpectations(timeout: mockMealAPIClient.delay + 1, handler: nil)

    // Then
    XCTAssertEqual(expectedStatus, resultStatus, "Status expected to be \(expectedStatus) but was \(resultStatus)")
    XCTAssertEqual(expectedDetail, resultDetail, "Detail text expected to be \(expectedDetail ?? "(none)") but was \(resultDetail ?? "(none)")")
  }
  
  func testFetchPastaMealsCancelled() {
    // Given
    mockMealAPIClient.error = .mockError
    
    let expectation = self.expectation(description: #function)
    DispatchQueue.main.asyncAfter(deadline: .now() + mockMealAPIClient.delay) {
      expectation.fulfill()
    }
    
    let expectedStatus: FetchStatus = .ready
    var resultStatus: FetchStatus = .ongoing
    sut.pastaMealsItemViewModel.statusSubject
      .sink(receiveValue: { resultStatus = $0 })
      .store(in: &subscriptions)
    
    let expectedDetail: String? = sut.pastaMealsItemViewModel.detail
    var resultDetail: String?
    sut.pastaMealsItemViewModel.$detail
      .sink(receiveValue: { resultDetail = $0 })
      .store(in: &subscriptions)
    
    // When
    sut.fetchPastaMeals()
    DispatchQueue.main.asyncAfter(deadline: .now() + mockMealAPIClient.delay/2) { [weak sut] in
      sut?.cancel()
    }
    waitForExpectations(timeout: mockMealAPIClient.delay + 1, handler: nil)

    // Then
    XCTAssertEqual(expectedStatus, resultStatus, "Status expected to be \(expectedStatus) but was \(resultStatus)")
    XCTAssertEqual(expectedDetail, resultDetail, "Detail text expected to be \(expectedDetail ?? "(none)") but was \(resultDetail ?? "(none)")")
  }
  
  func testFetchBreakfastMealsCancelled() {
    // Given
    mockMealAPIClient.error = .mockError
    
    let expectation = self.expectation(description: #function)
    DispatchQueue.main.asyncAfter(deadline: .now() + mockMealAPIClient.delay) {
      expectation.fulfill()
    }
    
    let expectedStatus: FetchStatus = .ready
    var resultStatus: FetchStatus = .ongoing
    sut.breakfastMealsItemViewModel.statusSubject
      .sink(receiveValue: { resultStatus = $0 })
      .store(in: &subscriptions)
    
    let expectedDetail: String? = sut.breakfastMealsItemViewModel.detail
    var resultDetail: String?
    sut.breakfastMealsItemViewModel.$detail
      .sink(receiveValue: { resultDetail = $0 })
      .store(in: &subscriptions)
    
    // When
    sut.fetchBreakfastMeals()
    DispatchQueue.main.asyncAfter(deadline: .now() + mockMealAPIClient.delay/2) { [weak sut] in
      sut?.cancel()
    }
    waitForExpectations(timeout: mockMealAPIClient.delay + 1, handler: nil)

    // Then
    XCTAssertEqual(expectedStatus, resultStatus, "Status expected to be \(expectedStatus) but was \(resultStatus)")
    XCTAssertEqual(expectedDetail, resultDetail, "Detail text expected to be \(expectedDetail ?? "(none)") but was \(resultDetail ?? "(none)")")
  }
  
}


// MARK: - Mocks

private class MockMealAPIClient: MealAPIClientProtocol {
  enum Error: Swift.Error {
    case mockError
  }
  
  let categories = [
    MealCategory(id: "0", name: "Category 0", imageUrlString: "", longDescription: ""),
    MealCategory(id: "1", name: "Category 1", imageUrlString: "", longDescription: "")
  ]
  let meals = [
    Meal(id: "0", name: "Meal 0", imageUrlString: nil),
    Meal(id: "1", name: "Meal 1", imageUrlString: nil)
  ]
  
  var error: Error?
  let delay: TimeInterval = 1
  
  func fetchCategories() -> AnyPublisher<[MealCategory], Swift.Error> {
    Future<[MealCategory], Swift.Error> { [weak self] resolve in
      guard let self = self else { return }
      if let error = self.error {
        resolve(.failure(error))
      } else {
        resolve(.success(self.categories))
      }
    }
    .delay(for: .seconds(delay), scheduler: RunLoop.current)
    .eraseToAnyPublisher()
  }
  
  func fetchMeals(category: String) -> AnyPublisher<[Meal], Swift.Error> {
    Future<[Meal], Swift.Error> { [weak self] resolve in
      guard let self = self else { return }
      if let error = self.error {
        resolve(.failure(error))
      } else {
        resolve(.success(self.meals))
      }
    }
    .delay(for: .seconds(delay), scheduler: RunLoop.current)
    .eraseToAnyPublisher()
  }
}
