//
//  QiitaSearchViewModel.swift
//  QiitaMVVM
//
//  Created by koala panda on 2023/08/18.
//

import Foundation
import RxSwift
import RxCocoa
import NSObject_Rx



protocol QiitaSearchViewModelInput {
    // textFieldから検索 外から受け取るだけのことしたいのでAnyObserver
    var searchTextObserver: AnyObserver<String> { get }
    // セグメントでAPIを叩くパスを切り替え
    var segumentedObserver: AnyObserver<Int> { get }
    // tableViewデリゲートセルタップの通知
    var itemSelectedObserver: AnyObserver<Int> { get }


}

protocol QiitaSearchViewModelOutput {
    // 受け取った入力が揃ったらAPIを叩いて出力
    var changeModelObservable: Observable<Void> { get }
    // セルをタップされたら画面遷移する
    var tappedCellShowObeservable: Observable<Void> { get }
    // TableViewのデリゲートの使用するため状態をもつ
    var models: [ QiitaModel ] { get }
    // タップしたセルのindex.rowによってモデルを選択
    var tappedCellModelObservable: Observable<QiitaModel> { get }


}
// TODO: イニシャライザーを作成して拡張でインプット､アウトプットに分ける
final class QiitaSearchViewModel: QiitaSearchViewModelInput, QiitaSearchViewModelOutput, HasDisposeBag {
    // 入力側
    // PublishRelay受け取って流す
    private let _searchText = PublishRelay<String>()
    // searchTextObserverは初期化時_serchTextに依存しているためlazyで初期化を遅延
    lazy var searchTextObserver: AnyObserver<String> = .init(eventHandler: { (event) in
        guard let e = event.element else { return }
        self._searchText.accept(e)
    })

    private let _segumentedType = PublishRelay<Int>()
    lazy var segumentedObserver: AnyObserver<Int> = .init(eventHandler: { (event) in
        guard let e = event.element else { return }
        self._segumentedType.accept(e)
    })

    private let _itemSelectedCellIndex = PublishRelay<Int>()
    lazy var itemSelectedObserver: AnyObserver<Int> = .init(eventHandler: { (event) in
        guard let e = event.element else { return }
        self._itemSelectedCellIndex.accept(e)
    })

    // 出力側
    private let _changeModelObservable = PublishRelay<Void>()
    lazy var changeModelObservable: Observable<Void> = _changeModelObservable.asObservable()

    private let _tappedCellShowObeservable = PublishRelay<Void>()
    lazy var tappedCellShowObeservable: Observable<Void> = _tappedCellShowObeservable.asObservable()

    private let _tappedCellModelRelay = PublishRelay<QiitaModel>()
    lazy var tappedCellModelObservable: Observable<QiitaModel> = _tappedCellModelRelay.asObservable()


    private(set)var models: [QiitaModel] = []
    // QiitaClientを持つ
    private let qiitaClient: QiitaClient

    init(client: QiitaClient = QiitaClient(httpClient: URLSession.shared)) {
        self.qiitaClient = client

        // Search textの変更を監視し、APIを叩く
        Observable.combineLatest(
            _searchText,
            _segumentedType
        )
        .flatMapLatest { (searchText, _segumentedType) -> Observable<[QiitaModel]> in
            switch _segumentedType {
            case 0:
                print("Article")
                let request = QiitaAPI.GetArticles(keyword: searchText)
                return client.rx_send(request: request)
            case 1:
                print("Tag")
                let request = QiitaAPI.GetTags(keyword: searchText)
                return client.rx_send(request: request)
            default:
                let request = QiitaAPI.GetArticles(keyword: searchText)
                return client.rx_send(request: request)

            }

        // doはストリームに影響を与えない処理を追加する
        }.do(onNext: { models in
            print("Received models: \(models)")
        }, onError: { error in
            print("Error fetching models: \(error)")
        })
        .map { [weak self] (models) -> Void in
            self?.models = models
            return
        }
        .bind(to: _changeModelObservable)
        .disposed(by: disposeBag)

        _itemSelectedCellIndex
            .subscribe(onNext: { [weak self] index in
                guard let self = self, let model = self.models[safe: index] else { return }
                self._tappedCellModelRelay.accept(model)
            })
            .disposed(by: disposeBag)


    }
}


