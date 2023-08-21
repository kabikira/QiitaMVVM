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
    private var viewModel: WebViewModel!
    private lazy var output: WebViewModelOutput = viewModel

    // RouterからViewModelを注入
    func inject(viewModel: WebViewModel) {
            self.viewModel = viewModel
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

