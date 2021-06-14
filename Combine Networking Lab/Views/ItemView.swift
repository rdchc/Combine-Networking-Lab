//
//  ItemView.swift
//  Combine Networking Lab
//
//  Created by CCH on 31/5/2021.
//

import UIKit
import Combine
import Then
import TinyConstraints

class ItemView: UIView {
  private let titleLabel = UILabel()
  private let statusLabel = UILabel()
  private let fetchButton = UIButton(type: .system)
  private let cancelButton = UIButton(type: .system)
  private let separator = UIView()
  
  private lazy var hStackView1 = UIStackView(arrangedSubviews: [titleLabel, customStackView])
  private lazy var hStackView2 = UIStackView(arrangedSubviews: [statusLabel, fetchButton, cancelButton])
  private lazy var vStackView = UIStackView(arrangedSubviews: [hStackView1, hStackView2])
  
  let customStackView = UIStackView()
  let insets: UIEdgeInsets = .uniform(12)
  
  private var fetchTappedSubject = PassthroughSubject<Void, Never>()
  var fetchPublisher: AnyPublisher<Void, Never> {
    fetchTappedSubject.eraseToAnyPublisher()
  }
  private var cancelTappedSubject = PassthroughSubject<Void, Never>()
  var cancelPublisher: AnyPublisher<Void, Never> {
    cancelTappedSubject.eraseToAnyPublisher()
  }
  private var subscriptions = Set<AnyCancellable>()
  
  
  // MARK: - Methods
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupViews() {
    vStackView.do {
      $0.axis = .vertical
      $0.spacing = UIStackView.spacingUseSystem
      addSubview($0)
      $0.edgesToSuperview(excluding: .bottom, insets: insets)
    }
    
    hStackView1.do {
      $0.axis = .horizontal
      $0.spacing = UIStackView.spacingUseSystem
    }
    
    titleLabel.do {
      $0.font = UIFont.boldSystemFont(ofSize: 20)
      $0.textColor = .label
    }
    
    customStackView.do {
      $0.axis = .horizontal
      $0.spacing = UIStackView.spacingUseSystem
    }
    
    hStackView2.do {
      $0.axis = .horizontal
      $0.spacing = UIStackView.spacingUseSystem
    }
    
    statusLabel.do {
      $0.font = UIFont.systemFont(ofSize: 16)
      $0.textColor = .systemGray
      $0.setHugging(.defaultLow - 1, for: .horizontal)
    }
    
    fetchButton.do {
      $0.setTitle("Fetch", for: .normal)
      $0.addAction(.init(handler: { [weak self] _ in
        self?.fetchTappedSubject.send()
      }), for: .touchUpInside)
    }
    
    cancelButton.do {
      $0.setTitle("Cancel", for: .normal)
      $0.addAction(.init(handler: { [weak self] _ in
        self?.cancelTappedSubject.send()
      }), for: .touchUpInside)
    }
    
    separator.do {
      $0.backgroundColor = .systemGray
      addSubview($0)
      $0.edgesToSuperview(excluding: .top, insets: insets)
      $0.topToBottom(of: vStackView, offset: insets.top)
      $0.height(1)
    }
  }
  
  func bindViewModel(_ vm: MockItemViewModel) {
    vm.$title
      .assign(to: \.text, on: titleLabel)
      .store(in: &subscriptions)
    
    vm.$status
      .map {
        switch $0 {
        case .ready: return "Tap to fetch"
        case .ongoing: return "Fetching..."
        case .finished(let res): return res
        }
      }
      .assign(to: \.text, on: statusLabel)
      .store(in: &subscriptions)
    
    vm.$status
      .map { $0 != .ongoing }
      .assign(to: \.isEnabled, on: fetchButton)
      .store(in: &subscriptions)
    
    vm.$cancellable
      .assign(to: \.isEnabled, on: cancelButton)
      .store(in: &subscriptions)
  }
  
  func bindViewModel(_ vm: MealItemViewModel) {
    vm.$title
      .assign(to: \.text, on: titleLabel)
      .store(in: &subscriptions)
    
    vm.$detail
      .assign(to: \.text, on: statusLabel)
      .store(in: &subscriptions)
    
    vm.$status
      .map { $0 != .ongoing }
      .assign(to: \.isEnabled, on: fetchButton)
      .store(in: &subscriptions)
    
    vm.$cancellable
      .assign(to: \.isEnabled, on: cancelButton)
      .store(in: &subscriptions)
  }
}
