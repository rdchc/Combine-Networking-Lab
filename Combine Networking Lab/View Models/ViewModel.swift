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
  
  private let mealApiClient = MealApiClient()
  private let mockApiClient = MockApiClient()
  private let mockApiQueue = DispatchQueue(label: "mock-api")
  
  
  // MARK: -
  
  init() {
    setupViewModels()
  }
  
  private func setupViewModels() {
    mockItemViewModel.do {
      $0.title = "Sample Item View"
      $0.$showError
        .map { $0 ? MockApiClient.Error.mockError : nil }
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
      categoriesItemViewModel.$status,
      pastaMealsItemViewModel.$status,
      breakfastMealsItemViewModel.$status
    ])
    .map { $0 == .ongoing }
    .assign(to: &$showLoading)
  }
  
  func cancel() {
    sharedFetchSubscription?.cancel()
  }
  
  
  // MARK: - Meal categories
  
  func fetchCategories() {
    categoriesItemViewModel.status = .ongoing
    
    sharedFetchSubscription = mealApiClient.fetchCategories()
      .receive(on: DispatchQueue.main)
      .handleEvents(receiveCancel: { [weak self] in
        self?.categoriesItemViewModel.status = .ready
      })
      .sink(receiveCompletion: { [weak self] in
        if case .failure(let err) = $0 {
          self?.showErrorAlert(err)
        }
      }, receiveValue: { [weak self] categories in
        self?.categoriesItemViewModel.do {
          $0.detail = "\(categories.count) categories"
        }
        self?.categoriesItemViewModel.status = .finished(())
      })
  }
  
  
  // MARK: - Meals
  
  func fetchPastaMeals() {
    pastaMealsItemViewModel.status = .ongoing
    
    sharedFetchSubscription = mealApiClient.fetchMeals(category: "Pasta")
      .receive(on: DispatchQueue.main)
      .handleEvents(receiveCancel: { [weak self] in
        self?.pastaMealsItemViewModel.status = .ready
      })
      .sink(receiveCompletion: { [weak self] in
        if case .failure(let err) = $0 {
          self?.showErrorAlert(err)
        }
      }, receiveValue: { [weak self] meals in
        self?.pastaMealsItemViewModel.do {
          $0.detail = "\(meals.count) meals for pasta"
          $0.status = .finished(())
        }
      })
  }
  
  func fetchBreakfastMeals() {
    breakfastMealsItemViewModel.status = .ongoing
    
    sharedFetchSubscription = mealApiClient.fetchMeals(category: "Breakfast")
      .receive(on: DispatchQueue.main)
      .handleEvents(receiveCancel: { [weak self] in
        self?.breakfastMealsItemViewModel.status = .ready
      })
      .sink(receiveCompletion: { [weak self] in
        if case .failure(let err) = $0 {
          self?.showErrorAlert(err)
        }
      }, receiveValue: { [weak self] meals in
        self?.breakfastMealsItemViewModel.do {
          $0.detail = "\(meals.count) meals for breakfast"
          $0.status = .finished(())
        }
      })
  }
  
  private func showErrorAlert(_ error: MealApiClient.Error) {
    let message: String = {
      switch error {
      case .network: return "Network error occurred."
      case .parsing: return "Unable to determine meals"
      case .other: return "Error occurred, please try again."
      }
    }()
    showInfoAlertSubject.send(message)
  }
  
  
  // MARK: - Mock
  
  func mockFetch() {
    mockItemViewModel.status = .ongoing
    
    mockFetchSubscription = mockApiClient.fetch()
      .subscribe(on: mockApiQueue)
      .receive(on: DispatchQueue.main)
      .handleEvents(receiveCancel: { [weak self] in
        self?.mockItemViewModel.status = .ready
      })
      .sink(receiveCompletion: { [weak self] in
        if case .failure(let err) = $0 {
          self?.showErrorAlert(err)
        }
      }, receiveValue: { [weak self] str in
        self?.mockItemViewModel.status = .finished(str)
      })
  }
  
  private func showErrorAlert(_ error: MockApiClient.Error) {
    switch error {
    case .mockError:
      mockItemViewModel.status = .finished("(Mock Error)")
    }
  }
  
  func showMockError(_ showError: Bool) {
    mockItemViewModel.showError = showError
  }
  
  func cancelMockFetch() {
    mockFetchSubscription?.cancel()
  }
  
}
