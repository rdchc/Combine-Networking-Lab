//
//  ItemViewModel.swift
//  Combine Networking Lab
//
//  Created by CCH on 1/6/2021.
//

import Foundation
import Combine
import Then

class ItemViewModel: ObservableObject {
  @Published var title: String?
  @Published var status: String?
  @Published var infoText: String?
  @Published var isFetching: Bool = false
  @Published var cancellable: Bool = false
  
  private let showInfoSubject = PassthroughSubject<String?, Never>()
  var showInfoPublisher: AnyPublisher<String?, Never> {
    showInfoSubject.eraseToAnyPublisher()
  }
  
  private var subscriptions = Set<AnyCancellable>()
  
  
  // MARK: - External methods
  
  func showInfo() {
    showInfoSubject.send(infoText)
  }
  
}


// MARK: - Then

extension ItemViewModel: Then {}
