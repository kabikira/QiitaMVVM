//
//  QiitaSearchViewController.swift
//  QiitaExplorer
//
//  Created by koala panda on 2023/07/05.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional


class QiitaSearchViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.register(UINib.init(nibName: QiitaTableViewCell.className, bundle: nil), forCellReuseIdentifier: QiitaTableViewCell.className)
            tableView.delegate = self
            tableView.dataSource = self
        }
    }

    private let viewModel = QiitaSearchViewModel()
    private lazy var input: QiitaSearchViewModelInput = viewModel
    private lazy var output: QiitaSearchViewModelOutput = viewModel

    override func viewDidLoad() {
        super.viewDidLoad()
        bindInputStream()
        bindOutputStream()
    }
    // viewModelに流すストリーム
    private func bindInputStream() {
        // 文字列のストリーム
        let searchTextObservable = searchTextField.rx.text
            .debounce(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged().filterNil().filter { $0.isNotEmpty }
            .do(onNext: { text in
                print("Text changed to: \(text)")
            })
        // 別の書き方
        //        let searchTextObservable = searchTextField.rx.controlEvent([.editingChanged])
                //            .map { self.searchTextField.text }
                //            .debounce(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
                //            .distinctUntilChanged().filterNil().filter { $0.isNotEmpty }

        // セグメントのストリーム
        let segmentedObservable = Observable.merge(
            Observable.just(segmentedControl.selectedSegmentIndex),
            segmentedControl.rx.controlEvent(.valueChanged).map { self.segmentedControl.selectedSegmentIndex }
        )
        // セルタップ時のストリーム
        let itemSelectedObservable = tableView.rx.itemSelected.asObservable()
        .map { $0.row }

        rx.disposeBag.insert([
            searchTextObservable.bind(to: input.searchTextObserver),
            segmentedObservable.bind(to: input.segumentedObserver),
            itemSelectedObservable.bind(to: input.itemSelectedObserver)
        ])
    }

    // viewModelからくるストリーム
    private func bindOutputStream() {
        output.changeModelObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] in
                guard let self else { return }
                self.tableView.reloadData()
            }, onError: { error in
                print(error.localizedDescription)
            }).disposed(by: rx.disposeBag)


        output.tappedCellModelObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] qiitaModel in
                guard let self = self else { return }
                Router.shared.showWeb(from: self, qiitaModel: qiitaModel)
            })
            .disposed(by: rx.disposeBag)

    }

}

// MARK: - TalbleView
extension QiitaSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // デリゲートつかわないでタップで画面遷移した、タップするだけならセルの高さやキャッシュを扱わないからRxCocoaでやってもいいかな
        
    }
}

extension QiitaSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //outputの中にmodelsがある
        return output.models.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: QiitaTableViewCell.className)
        print("Dequeued cell type: \(String(describing: dequeuedCell))")

        if let safeQiitaModel = output.models[safe: indexPath.item] {
            print("Retrieved model: \(safeQiitaModel)")
        } else {
            print("Failed to retrieve model at index: \(indexPath.item)")
        }

        guard
            let cell = dequeuedCell as? QiitaTableViewCell,
            let qiitaModel = output.models[safe: indexPath.item]
        else {
            return UITableViewCell()
        }

        cell.configure(qiitaModel: qiitaModel)
        return cell
    }
}
