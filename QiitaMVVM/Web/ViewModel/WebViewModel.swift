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
        /*
         RouterでViewModelが初期化されたときにURLRequestを送信してViewの更新を行うがこのときまだViewControllerのViewは生成されていないためViewの更新はされない、遅れてViewコントローラーが生成されたときバッファとして残っているイベントを利用してViewを更新させている
         */
        self.qiitaModel = qiitaModel
        let request = URLRequest(url: qiitaModel.url)
        _requestSubject.onNext(request)
        //        let request = URLRequest(url: qiitaModel.url)
        //        _requestRelay.accept(request)
    }

    // 出力側
    // BehaviorRelayはonNextだけ
    //    private let _requestRelay = BehaviorRelay<URLRequest?>(value: nil)
    //    var requestObservable: Observable<URLRequest> {
    //        // .compactMapでnilでない値のみを通過
    //        return _requestRelay.asObservable().compactMap { $0 }
    //    }

    // BehaviorSubjectならエラー処理をできる
    private let _requestSubject = BehaviorSubject<URLRequest?>(value: nil)
    var requestObservable: Observable<URLRequest> {
        return _requestSubject
            .compactMap { $0 }  // nil を除外
            .catch { error in
                // エラー処理
                print(error.localizedDescription)
                return Observable.error(error)
                // もしくは、特定のデフォルトの動作を実行したい場合。
                // return Observable.just(URLRequest(url: URL(string: "https://default.url/")!))
            }
    }

}
