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
  @Published var detail: String?
  @Published var cancellable: Bool = false
  var statusSubject: CurrentValueSubject<FetchStatus, Never> = .init(.ready)
  
  init() {
    setupBindings()
  }
  
  private func setupBindings() {
    statusSubject
      .map { $0 == .ongoing }
      .assign(to: &$cancellable)
  }
}


// MARK: - Then

extension MealItemViewModel: Then { }
