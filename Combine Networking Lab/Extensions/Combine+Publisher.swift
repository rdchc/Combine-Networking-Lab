//
//  Combine+Publisher.swift
//  Combine Networking Lab
//
//  Created by CCH on 21/6/2021.
//

import Foundation
import Combine

extension Publisher {
  func observeFetchStatus<S: Subject>(with fetchStatusSubject: S) -> Publishers.HandleEvents<Self> where S.Output == FetchStatus, S.Failure == Never {
    return handleEvents(receiveSubscription: { _ in
      fetchStatusSubject.send(.ongoing)
    }, receiveCompletion: {
      switch $0 {
      case .finished:
        fetchStatusSubject.send(.finished)
      case .failure:
        fetchStatusSubject.send(.ready)
      }
    }, receiveCancel: {
      fetchStatusSubject.send(.ready)
    })
  }
}
