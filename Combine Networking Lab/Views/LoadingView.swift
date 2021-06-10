//
//  LoadingView.swift
//  Combine Networking Lab
//
//  Created by CCH on 10/6/2021.
//

import UIKit
import Combine
import Then
import TinyConstraints

class LoadingOverlayView: UIView {
  let loadingButton = LoadingButton()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupViews() {
    backgroundColor = UIColor.black.withAlphaComponent(0.2)
    
    loadingButton.do {
      addSubview($0)
      $0.centerInSuperview()
    }
  }
}

class LoadingButton: UIButton {
  private let activityIndicator = UIActivityIndicatorView()
  private var subscriptions = Set<AnyCancellable>()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
    setupBindings()
    activityIndicator.startAnimating()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    layer.cornerRadius = frame.width / 8
  }
  
  private func setupViews() {
    activityIndicator.do {
      addSubview($0)
      $0.centerInSuperview()
      $0.edgesToSuperview(insets: .uniform(24))
    }
  }
  
  private func setupBindings() {
    publisher(for: \.isHighlighted)
      .map { UIColor.black.withAlphaComponent($0 ? 0.1 : 0.2) }
      .sink(receiveValue: { [weak self] in
        self?.backgroundColor = $0
      })
      .store(in: &subscriptions)
  }
}
