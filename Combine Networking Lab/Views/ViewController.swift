//
//  ViewController.swift
//  Combine Networking Lab
//
//  Created by CCH on 31/5/2021.
//

import UIKit
import Combine
import Then
import TinyConstraints

class ViewController: UIViewController {
  
  private let scrollView = UIScrollView()
  private let scrollContentView = UIView()
  private let stackView = UIStackView()
  
  let sampleItemView = ItemView()
  let mealCategoriesItemView = ItemView()
  
  let viewModel = ViewModel()
  private let showInfoSubject = PassthroughSubject<String, Never>()
  private var subscriptions = Set<AnyCancellable>()
  
  
  // MARK: - Methods

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    setupViews()
    setupBindings()
  }
  
  private func setupViews() {
    scrollView.do {
      view.addSubview($0)
      $0.edgesToSuperview(usingSafeArea: true)
    }
    scrollContentView.do {
      scrollView.addSubview($0)
      $0.edgesToSuperview()
      $0.widthToSuperview()
      $0.heightToSuperview(priority: .defaultLow)
    }
    
    stackView.do {
      $0.axis = .vertical
      scrollContentView.addSubview($0)
      $0.edgesToSuperview()
    }
    
    sampleItemView.do { v in
      stackView.addArrangedSubview(v)
      
      let errorSwitch = UISwitch().then {
        $0.addTarget(self, action: #selector(toggleShowMockError(_:)), for: .valueChanged)
      }
      let errorLabel = UILabel().then {
        $0.text = "Toggle error"
      }
      [errorSwitch, errorLabel].forEach { subview in
        v.customStackView.addArrangedSubview(subview)
      }
    }
    
    mealCategoriesItemView.do { v in
      stackView.addArrangedSubview(v)
      
      let infoBtn = UIButton(type: .system, primaryAction: .init(handler: { [weak self] _ in
        guard let self = self else { return }
        self.showInfoSubject.send("This item fetches all meal categories available.")
      })).then { btn in
        btn.setImage(UIImage(systemName: "info.circle"), for: .normal)
      }
      v.customStackView.addArrangedSubview(infoBtn)
    }
  }
  
  private func setupBindings() {
    sampleItemView.do { v in
      v.bindViewModel(viewModel.mockItemViewModel)
      v.fetchPublisher
        .sink { [weak self] in
          guard let self = self else { return }
          self.viewModel.mockFetch()
        }
        .store(in: &subscriptions)
      v.cancelPublisher
        .sink { [weak self] in
          guard let self = self else { return }
          self.viewModel.cancelMockFetch()
        }
        .store(in: &subscriptions)
    }
    
    mealCategoriesItemView.do { v in
      v.bindViewModel(viewModel.categoriesItemViewModel)
      v.fetchPublisher
        .sink { [weak self] in
          guard let self = self else { return }
          self.viewModel.fetchCategories()
        }
        .store(in: &subscriptions)
      v.cancelPublisher
        .sink { [weak self] in
          guard let self = self else { return }
          self.viewModel.cancelFetchingCategories()
        }
        .store(in: &subscriptions)
    }
    
    showInfoSubject
      .sink { [weak self] info in
        let alert = UIAlertController(title: "Info", message: info, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self?.present(alert, animated: true, completion: nil)
      }
      .store(in: &subscriptions)
  }
  
  
  // MARK: -
  
  @objc private func toggleShowMockError(_ sender: UISwitch) {
    viewModel.showMockError(sender.isOn)
  }

}
