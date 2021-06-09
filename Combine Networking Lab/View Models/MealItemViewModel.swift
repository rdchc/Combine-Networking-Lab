//
//  MealItemViewModel.swift
//  Combine Networking Lab
//
//  Created by CCH on 7/6/2021.
//

import Foundation
import Combine
import Then

class MealItemViewModel {
  @Published var title: String?
  @Published var status: FetchStatus<String?>?
  @Published var cancellable: Bool = false
  
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

extension MealItemViewModel: Then { }
