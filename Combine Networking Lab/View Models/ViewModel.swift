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
  private(set) var categoriesItemViewModel = MealCategoriesItemViewModel()
  
  var showInfoAlertSubject = PassthroughSubject<String?, Never>()
  
  private var mockFetchSubscription: AnyCancellable?
  private var fetchMealCategoriesSubscription: AnyCancellable?
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
  }
  
  func cancel() {
    sharedFetchSubscription?.cancel()
  }
  
  
  // MARK: - Meal categories
  
  func fetchCategories() {
    categoriesItemViewModel.status = .fetching
    
    fetchMealCategoriesSubscription = mealApiClient.fetchCategories()
      .receive(on: DispatchQueue.main)
      .handleEvents(receiveCancel: { [weak self] in
        self?.categoriesItemViewModel.status = .cancelled
      })
      .sink(receiveCompletion: { [weak self] in
        if case .failure(let err) = $0 {
          let message: String = {
            switch err {
            case .network: return "Network error occurred."
            case .parsing: return "Unable to determine categories"
            case .other: return "Error occurred, please try again."
            }
          }()
          self?.categoriesItemViewModel.status = .error(message)
        }
      }, receiveValue: { [weak self] categories in
        self?.categoriesItemViewModel.status = .fetched("\(categories.count) results")
      })
  }
  
  func cancelFetchingCategories() {
    fetchMealCategoriesSubscription?.cancel()
  }
  
  
  // MARK: - Mock
  
  func mockFetch() {
    mockItemViewModel.status = .fetching
    
    mockFetchSubscription = mockApiClient.fetch()
      .subscribe(on: mockApiQueue)
      .receive(on: DispatchQueue.main)
      .handleEvents(receiveCancel: { [weak self] in
        self?.mockItemViewModel.status = .cancelled
      })
      .sink(receiveCompletion: { [weak self] in
        if case .failure(let err) = $0 {
          switch err {
          case .mockError:
            self?.mockItemViewModel.status = .error("(Mock Error)")
          }
        }
      }, receiveValue: { [weak self] str in
        self?.mockItemViewModel.status = .fetched(str)
      })
  }
  
  func showMockError(_ showError: Bool) {
    mockItemViewModel.showError = showError
  }
  
  func cancelMockFetch() {
    mockFetchSubscription?.cancel()
  }
  
}
