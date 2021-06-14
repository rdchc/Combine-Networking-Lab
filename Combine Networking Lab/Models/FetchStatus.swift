//
//  FetchStatus.swift
//  Combine Networking Lab
//
//  Created by CCH on 8/6/2021.
//

import Foundation

enum FetchStatus<T>: Equatable {
  case ready
  case ongoing
  case finished(T)
  
  static func == (lhs: FetchStatus<T>, rhs: FetchStatus<T>) -> Bool {
    switch (lhs, rhs) {
    case (.ready, .ready):
      return true
    case (.ongoing, .ongoing):
      return true
    case (.finished, .finished):
      return true
    default:
      return false
    }
  }
}

extension FetchStatus where T: Equatable {
  static func == (lhs: FetchStatus<T>, rhs: FetchStatus<T>) -> Bool {
    switch (lhs, rhs) {
    case (.ready, .ready):
      return true
    case (.ongoing, .ongoing):
      return true
    case let (.finished(lValue), .finished(rValue)):
      return lValue == rValue
    default:
      return false
    }
  }
}
