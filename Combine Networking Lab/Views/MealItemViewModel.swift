//
//  MealItemViewModel.swift
//  Combine Networking Lab
//
//  Created by CCH on 7/6/2021.
//

import Foundation
import Combine
import Then

class MealItemViewModel: ItemViewModelProtocol {
  @Published var title: String?
  @Published var status: ItemViewModel.Status?
  @Published var cancellable: Bool = false
  
  var titlePublisher: Published<String?>.Publisher { $title }
  var statusPublisher: Published<ItemViewModel.Status?>.Publisher { $status }
  var cancellablePublisher: Published<Bool>.Publisher { $cancellable }
  
  private var fetchSubscription: AnyCancellable?
  private let apiClient = MealApiClient()
  
  init() {
    setupBindings()
  }
  
  private func setupBindings() {
    $status
      .map { $0 == .fetching }
      .assign(to: &$cancellable)
  }
  
  
  // MARK: - External methods
  
  func fetch() {
    status = .fetching
    
    fetchSubscription = apiClient.fetchCategories()
      .receive(on: DispatchQueue.main)
      .handleEvents(receiveCancel: { [weak self] in
        self?.status = .cancelled
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
          self?.status = .error(message)
        }
      }, receiveValue: { [weak self] categories in
          self?.status = .fetched("\(categories.count) results")
      })
  }
  
  func cancel() {
    fetchSubscription?.cancel()
  }
}

extension MealItemViewModel: Then { }
