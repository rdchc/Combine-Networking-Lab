//
//  MockAPIClient.swift
//  Combine Networking Lab
//
//  Created by CCH on 1/6/2021.
//

import Foundation
import Combine

class MockAPIClient {
  enum Error: Swift.Error {
    case mockError
  }
  
  var error: Error?
  private let delay: TimeInterval = 2
  
  func fetch() -> AnyPublisher<String?, MockAPIClient.Error> {
    Future<String?, MockAPIClient.Error> { [weak self] resolve in
      if let error = self?.error {
        resolve(.failure(error))
      } else {
        resolve(.success("Success Result"))
      }
    }
    .delay(for: .seconds(delay), scheduler: RunLoop.current)
    .eraseToAnyPublisher()
  }
}
