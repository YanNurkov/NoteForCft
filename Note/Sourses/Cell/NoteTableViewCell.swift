//
//  NoteTableViewCell.swift
//  Note
//
//  Created by Ян Нурков on 29.01.2023.
//

import Foundation
import UIKit
import SnapKit

class NoteTableViewCell: UITableViewCell {
    static let cellName = "cell"
    private weak var controller: NoteViewController?
    
    // MARK: - Element
    
    lazy var nameNoteLabel: UILabel = {
        let obj = UILabel()
        obj.textColor = .black
        obj.textAlignment = .left
        return obj
    }()
}

// MARK: - PrivateExtensions

private extension NoteTableViewCell {
    func makeConstraints() {
        self.nameNoteLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Metric.left)
            make.bottom.equalToSuperview()
            make.top.equalToSuperview()
            make.right.equalToSuperview().offset(Metric.right)
        }
    }
}

private extension NoteTableViewCell {
    var tableView: UITableView? {
        self.superview as? UITableView
    }
    
    var indexPath: IndexPath? {
        self.tableView?.indexPath(for: self)
    }
}

// MARK: - Extension

extension NoteTableViewCell {
    func configView(controller: NoteViewController) {
        self.controller = controller
        self.backgroundColor = .clear
        self.layer.cornerRadius = 27.5
        self.contentView.layer.borderWidth = 0.5
        self.contentView.layer.borderColor = Colors.boarderCell
        self.contentView.layer.cornerRadius = 27.5
        self.contentView.backgroundColor = .white
        let selectedView = UIView()
        selectedView.backgroundColor = Colors.selectCell
        selectedView.layer.cornerRadius = 27.5
        self.selectedBackgroundView = selectedView
        self.layer.masksToBounds = true
        self.clipsToBounds = true
        self.contentView.addSubview(self.nameNoteLabel)
        makeConstraints()
    }
}
