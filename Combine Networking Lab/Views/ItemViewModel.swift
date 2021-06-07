//
//  ItemViewModel.swift
//  Combine Networking Lab
//
//  Created by CCH on 1/6/2021.
//

import Foundation
import Combine
import Then

class ItemViewModel {
  enum Status: Equatable {
    case fetching
    case fetched(String?)
    case error(String?)
    case cancelled
  }
  
  @Published var title: String?
  @Published var status: Status?
  @Published var infoText: String?
  @Published var cancellable: Bool = false
  
  private var fetchSubscription: AnyCancellable?
  private var subscriptions = Set<AnyCancellable>()
  
  private let apiClient: MockApiClient
  private let queue = DispatchQueue(label: "mock-vm")
  
  private let showInfoSubject = PassthroughSubject<String?, Never>()
  var showInfoPublisher: AnyPublisher<String?, Never> {
    showInfoSubject.eraseToAnyPublisher()
  }
  
  init() {
    apiClient = MockApiClient(error: nil)
    setupBindings()
  }
  
  private func setupBindings() {
    $status
      .map { $0 == .fetching }
      .assign(to: &$cancellable)
  }
  
  
  // MARK: - External methods
  
  func showInfo() {
    showInfoSubject.send(infoText)
  }
  
  func fetch() {
    status = .fetching
    
    fetchSubscription = apiClient.fetch()
      .subscribe(on: queue)
      .receive(on: DispatchQueue.main)
      .print("fetch")
      .handleEvents(receiveCancel: { [weak self] in
        self?.status = .cancelled
      })
      .sink(receiveCompletion: { [weak self] in
        if case .failure(let err) = $0 {
          switch err {
          case .mockError:
            self?.status = .error("(Mock Error)")
          }
        }
      }, receiveValue: { [weak self] str in
        self?.status = .fetched(str)
      })
  }
  
  func cancel() {
    fetchSubscription?.cancel()
  }
  
}


// MARK: - Then

extension ItemViewModel: Then {}
