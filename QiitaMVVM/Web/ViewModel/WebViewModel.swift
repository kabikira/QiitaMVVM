//
//  WebViewModel.swift
//  QiitaMVVM
//
//  Created by koala panda on 2023/08/21.
//

import Foundation
import RxSwift
import RxCocoa
import NSObject_Rx

protocol WebViewModelInput {
    // Routeから値を受け取ることがInputなのかはよくわからない
    func configure(with model: QiitaModel)
}

protocol WebViewModelOutput {
    var requestObservable: Observable<URLRequest> { get }
}

final class WebViewModel: WebViewModelInput, WebViewModelOutput, HasDisposeBag {
    // 出力側
    private let _requestRelay = BehaviorRelay<URLRequest?>(value: nil)
    var requestObservable: Observable<URLRequest> {
        // .compactMapでnilでない値のみを通過
        return _requestRelay.asObservable().compactMap { $0 }
    }

    func configure(with model: QiitaModel) {
        // QiitaModelからURLを取得し、それをURLRequestとして流す。
        let request = URLRequest(url: model.url)
        _requestRelay.accept(request)
    }
}
