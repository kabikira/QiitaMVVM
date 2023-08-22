//
//  QiitaTableViewCell.swift
//  QiitaExplorer
//
//  Created by koala panda on 2023/07/04.
//

import UIKit
import Kingfisher

final class QiitaTableViewCell: UITableViewCell {
    static var className: String { String(describing: QiitaTableViewCell.self)}


    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = nil
        self.iconImageView.image = nil
    }

    func configure(qiitaModel: QiitaModel) {
        self.titleLabel.text = qiitaModel.title
        iconImageView.kf.indicatorType = .activity  // システムインジケーターの指定
        // 角を丸くする
        iconImageView.layer.cornerRadius = 10  // 半径を指定
        iconImageView.layer.masksToBounds = true // 丸みを反映
        // ダウンサンプル
        let processor = DownsamplingImageProcessor(size: iconImageView.bounds.size)
        |> RoundCornerImageProcessor(cornerRadius: 10)
        // オプションをセット
        iconImageView.kf.setImage(
            with: qiitaModel.user.profileImageURL,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),  // フェードイン効果を1秒で
            ]
        )
    }
}
