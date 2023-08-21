//
//  WebViewController.swift
//  QiitaExplorer
//
//  Created by koala panda on 2023/07/06.
//

import UIKit
import WebKit
import RxCocoa
import RxSwift

final class WebViewController: UIViewController {
    @IBOutlet private weak var webView: WKWebView!
    private let viewModel: WebViewModel = WebViewModel()
    private lazy var input: WebViewModelInput = viewModel
    private lazy var output: WebViewModelOutput = viewModel

    func configure(with model: QiitaModel) {
            input.configure(with: model)
        }


    override func viewDidLoad() {
        super.viewDidLoad()
        bindOutputStream()

    }
    private func bindOutputStream() {
        output.requestObservable
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] request in
                    self?.webView.load(request)
                })
                .disposed(by: rx.disposeBag)
        }
}

