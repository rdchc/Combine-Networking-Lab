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
  private let infoButton = UIButton(type: .system)
  private let statusLabel = UILabel()
  private let fetchButton = UIButton(type: .system)
  private let cancelButton = UIButton(type: .system)
  private let separator = UIView()
  
  private lazy var hStackView1 = UIStackView(arrangedSubviews: [titleLabel, infoButton])
  private lazy var hStackView2 = UIStackView(arrangedSubviews: [statusLabel, fetchButton, cancelButton])
  private lazy var vStackView = UIStackView(arrangedSubviews: [hStackView1, hStackView2])
  let insets: UIEdgeInsets = .uniform(12)
  
  var viewModel: ItemViewModel
  private var subscriptions = Set<AnyCancellable>()
  
  
  // MARK: - Methods
  
  override init(frame: CGRect) {
    viewModel = ItemViewModel()
    super.init(frame: frame)
    setupViews()
    setupBindings()
  }
  
  init(frame: CGRect = .zero, viewModel: ItemViewModel) {
    self.viewModel = viewModel
    super.init(frame: frame)
    setupViews()
    setupBindings()
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
    
    infoButton.do {
      $0.setImage(UIImage(systemName: "info.circle"), for: .normal)
      $0.addAction(.init(handler: { [weak self] _ in
        guard let self = self else { return }
        self.viewModel.showInfo()
      }), for: .touchUpInside)
    }
    
    hStackView2.do {
      $0.axis = .horizontal
      $0.spacing = UIStackView.spacingUseSystem
    }
    
    statusLabel.do {
      $0.font = UIFont.systemFont(ofSize: 16)
      $0.textColor = .systemGray
    }
    
    fetchButton.do {
      $0.setTitle("Fetch", for: .normal)
    }
    
    cancelButton.do {
      $0.setTitle("Cancel", for: .normal)
    }
    
    separator.do {
      $0.backgroundColor = .systemGray
      addSubview($0)
      $0.edgesToSuperview(excluding: .top, insets: insets)
      $0.topToBottom(of: vStackView, offset: insets.top)
      $0.height(1)
    }
  }
  
  private func setupBindings() {
    viewModel.$title
      .assign(to: \.text, on: titleLabel)
      .store(in: &subscriptions)
    
    viewModel.$infoText
      .map {
        guard let info = $0 else { return false }
        return !info.isEmpty
      }
      .assign(to: \.isEnabled, on: infoButton)
      .store(in: &subscriptions)
    
    viewModel.$status
      .assign(to: \.text, on: statusLabel)
      .store(in: &subscriptions)
    
    viewModel.$isFetching
      .map { !$0 }
      .assign(to: \.isEnabled, on: fetchButton)
      .store(in: &subscriptions)
    
    viewModel.$cancellable
      .assign(to: \.isEnabled, on: cancelButton)
      .store(in: &subscriptions)
  }
  
}
