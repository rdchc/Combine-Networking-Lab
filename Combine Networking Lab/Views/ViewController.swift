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
  private var loadingOverlayView: LoadingOverlayView?
  
  let sampleItemView = ItemView()
  let mealCategoriesItemView = ItemView()
  let pastaItemView = ItemView()
  let breakfastItemView = ItemView()
  
  let viewModel = ViewModel()
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
        self.viewModel.showInfoAlertSubject.send("This item fetches all meal categories available.")
      })).then { btn in
        btn.setImage(UIImage(systemName: "info.circle"), for: .normal)
      }
      v.customStackView.addArrangedSubview(infoBtn)
    }
    
    pastaItemView.do { v in
      stackView.addArrangedSubview(v)
    }
    
    breakfastItemView.do { v in
      stackView.addArrangedSubview(v)
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
          self.viewModel.cancel()
        }
        .store(in: &subscriptions)
    }
    
    pastaItemView.do { v in
      v.bindViewModel(viewModel.pastaMealsItemViewModel)
      v.fetchPublisher
        .sink { [weak self] in
          guard let self = self else { return }
          self.viewModel.fetchPastaMeals()
        }
        .store(in: &subscriptions)
      v.cancelPublisher
        .sink { [weak self] in
          guard let self = self else { return }
          self.viewModel.cancel()
        }
        .store(in: &subscriptions)
    }
    
    breakfastItemView.do { v in
      v.bindViewModel(viewModel.breakfastMealsItemViewModel)
      v.fetchPublisher
        .sink { [weak self] in
          guard let self = self else { return }
          self.viewModel.fetchBreakfastMeals()
        }
        .store(in: &subscriptions)
      v.cancelPublisher
        .sink { [weak self] in
          guard let self = self else { return }
          self.viewModel.cancel()
        }
        .store(in: &subscriptions)
    }
    
    viewModel.$showLoading
      .sink { [weak self] showLoading in
        guard let self = self else { return }
        showLoading ? self.addLoadingOverlayView() : self.removeLoadingOverlayView()
      }
      .store(in: &subscriptions)
    
    viewModel.showInfoAlertSubject
      .sink { [weak self] info in
        let alert = UIAlertController(title: "Info", message: info, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self?.present(alert, animated: true, completion: nil)
      }
      .store(in: &subscriptions)
  }
  
  private func addLoadingOverlayView() {
    LoadingOverlayView().do {
      view.addSubview($0)
      $0.widthToSuperview()
      $0.heightToSuperview()
      loadingOverlayView = $0
      
      $0.loadingButton.addAction(.init(handler: { [weak self] _ in
        self?.viewModel.cancel()
      }), for: .touchUpInside)
    }
  }
  
  private func removeLoadingOverlayView() {
    loadingOverlayView?.removeFromSuperview()
  }
  
  
  // MARK: -
  
  @objc private func toggleShowMockError(_ sender: UISwitch) {
    viewModel.showMockError(sender.isOn)
  }

}
