//
//  ItemViewModel.swift
//  Combine Networking Lab
//
//  Created by CCH on 1/6/2021.
//

import Foundation
import Combine
import Then

class MockItemViewModel {
  @Published var title: String?
  @Published var status: FetchStatus<String?>?
  @Published var showError: Bool = false
  @Published private(set) var cancellable: Bool = false
  
  init() {
    setupBindings()
  }
  
  private func setupBindings() {
    $status
      .map { $0 == .fetching }
      .assign(to: &$cancellable)
  }
}


// MARK: - Then

extension MockItemViewModel: Then { }
