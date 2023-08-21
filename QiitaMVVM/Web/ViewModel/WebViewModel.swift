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
    // 今の機能だとインプットはない
}

protocol WebViewModelOutput {
    var requestObservable: Observable<URLRequest> { get }
}

final class WebViewModel: WebViewModelInput, WebViewModelOutput, HasDisposeBag {
    private var qiitaModel: QiitaModel

    init(qiitaModel: QiitaModel) {
        self.qiitaModel = qiitaModel
        let request = URLRequest(url: qiitaModel.url)
        _requestRelay.accept(request)
    }

    // 出力側
    private let _requestRelay = BehaviorRelay<URLRequest?>(value: nil)
    var requestObservable: Observable<URLRequest> {
        // .compactMapでnilでない値のみを通過
        return _requestRelay.asObservable().compactMap { $0 }
    }

}
