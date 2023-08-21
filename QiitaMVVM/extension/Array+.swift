//
//  Array+.swift
//  QiitaMVVM
//
//  Created by koala panda on 2023/08/20.
//

import Foundation
import UIKit

extension Array {
  subscript (safe index: Int) -> Element? {
    return index >= 0 && index < self.count ? self[index] : nil
  }
}
