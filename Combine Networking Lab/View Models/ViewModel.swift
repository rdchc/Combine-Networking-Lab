//
//  ViewModel.swift
//  Combine Networking Lab
//
//  Created by CCH on 9/6/2021.
//

import Foundation
import Combine

class ViewModel {
  private(set) var mockItemViewModel = MockItemViewModel()
  private(set) var categoriesItemViewModel = MealItemViewModel()
  private(set) var pastaMealsItemViewModel = MealItemViewModel()
  private(set) var breakfastMealsItemViewModel = MealItemViewModel()
  
  @Published var showLoading: Bool = false
  var showInfoAlertSubject = PassthroughSubject<String?, Never>()
  
  private var mockFetchSubscription: AnyCancellable?
  private var sharedFetchSubscription: AnyCancellable?
  private var subscriptions = Set<AnyCancellable>()
  
  private let mealApiClient: MealAPIClientProtocol
  private let mockApiClient = MockAPIClient()
  private let mockApiQueue = DispatchQueue(label: "mock-api")
  
  
  // MARK: -
  
  init(mealApiClient: MealAPIClientProtocol) {
    self.mealApiClient = mealApiClient
    setupViewModels()
  }
  
  private func setupViewModels() {
    mockItemViewModel.do {
      $0.title = "Sample Item View"
      $0.$showError
        .map { $0 ? MockAPIClient.Error.mockError : nil }
        .assign(to: \.error, on: mockApiClient)
        .store(in: &subscriptions)
    }
    
    categoriesItemViewModel.do {
      $0.title = "Meal Categories"
    }
    
    pastaMealsItemViewModel.do {
      $0.title = "Pasta Meals"
    }
    
    breakfastMealsItemViewModel.do {
      $0.title = "Breakfast Meals"
    }
    
    Publishers.MergeMany([
      categoriesItemViewModel.statusSubject,
      pastaMealsItemViewModel.statusSubject,
      breakfastMealsItemViewModel.statusSubject
    ])
    .map { $0 == .ongoing }
    .assign(to: &$showLoading)
  }
  
  func cancel() {
    sharedFetchSubscription?.cancel()
  }
  
  
  // MARK: - Meal categories
  
  func fetchCategories() {
    sharedFetchSubscription = mealApiClient.fetchCategories()
      .observeFetchStatus(with: categoriesItemViewModel.statusSubject)
      .sink(receiveCompletion: { [weak self] in
        if case .failure(let err) = $0 {
          self?.handleError(err)
        }
      }, receiveValue: { [weak self] categories in
        self?.categoriesItemViewModel.do {
          $0.detail = "\(categories.count) categories"
        }
      })
  }
  
  
  // MARK: - Meals
  
  func fetchPastaMeals() {
    sharedFetchSubscription = mealApiClient.fetchMeals(category: "Pasta")
      .observeFetchStatus(with: pastaMealsItemViewModel.statusSubject)
      .sink(receiveCompletion: { [weak self] in
        if case .failure(let err) = $0 {
          self?.handleError(err)
        }
      }, receiveValue: { [weak self] meals in
        self?.pastaMealsItemViewModel.do {
          $0.detail = "\(meals.count) meals for pasta"
        }
      })
  }
  
  func fetchBreakfastMeals() {
    sharedFetchSubscription = mealApiClient.fetchMeals(category: "Breakfast")
      .observeFetchStatus(with: breakfastMealsItemViewModel.statusSubject)
      .sink(receiveCompletion: { [weak self] in
        if case .failure(let err) = $0 {
          self?.handleError(err)
        }
      }, receiveValue: { [weak self] meals in
        self?.breakfastMealsItemViewModel.do {
          $0.detail = "\(meals.count) meals for breakfast"
        }
      })
  }
  
  private func handleError(_ error: Error) {
    print(error.localizedDescription)
    let errorDescription: String = {
      switch error {
      case is URLError:
        return "Network error occurred."
      case is DecodingError:
        return "Unable to determine data."
      default:
        return "Error occurred, please try again."
      }
    }()
    showInfoAlertSubject.send(errorDescription)
  }
  
  
  // MARK: - Mock
  
  func mockFetch() {
    mockFetchSubscription = mockApiClient.fetch()
      .subscribe(on: mockApiQueue)
      .handleEvents(receiveSubscription: { [weak self] _ in
        self?.mockItemViewModel.do {
          $0.content = nil
          $0.status = .ongoing
        }
      }, receiveCompletion: { [weak self] in
        switch $0 {
        case .finished:
          self?.mockItemViewModel.status = .finished
        case .failure:
          self?.mockItemViewModel.status = .ready
        }
      }, receiveCancel: { [weak self] in
        self?.mockItemViewModel.status = .ready
      })
      .sink(receiveCompletion: { [weak self] in
        if case .failure(let err) = $0 {
          self?.showErrorAlert(err)
        }
      }, receiveValue: { [weak self] str in
        self?.mockItemViewModel.content = str
      })
  }
  
  private func showErrorAlert(_ error: MockAPIClient.Error) {
    switch error {
    case .mockError:
      mockItemViewModel.content = "(Mock Error)"
    }
  }
  
  func showMockError(_ showError: Bool) {
    mockItemViewModel.showError = showError
  }
  
  func cancelMockFetch() {
    mockFetchSubscription?.cancel()
  }
  
}
