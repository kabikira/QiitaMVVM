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
        iconImageView.kf.indicatorType = .activity
        iconImageView.kf.setImage(with: qiitaModel.user.profileImageURL)

    }
}
