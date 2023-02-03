//
//  NoteView.swift
//  Note
//
//  Created by Ян Нурков on 29.01.2023.
//

import Foundation
import UIKit
import SnapKit

class NoteView: UIView {
    private weak var noteViewController: NoteViewController?
    
    // MARK: - Elements
    
    lazy var searchBar: UISearchController = {
        let obj = UISearchController()
        return obj
    }()
    
    lazy var tableView: UITableView = {
        let obj = UITableView()
        obj.register(NoteTableViewCell.self, forCellReuseIdentifier: "cell")
        obj.dataSource = noteViewController
        obj.rowHeight = 55
        obj.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
        obj.separatorInset = .zero
        obj.separatorStyle = UITableViewCell.SeparatorStyle.none
        obj.showsVerticalScrollIndicator = false
        obj.backgroundColor = Colors.backgroundView
        return obj
    }()
}

// MARK: - PrivateExtension

private extension NoteView {
    private func configView() {
        addSubview(self.tableView)
        backgroundColor = Colors.backgroundView
    }
    
    private func makeConstraints() {
        self.tableView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
    }
}

// MARK: - Extension

extension NoteView {
    func didLoadUI(controller: NoteViewController) {
        self.noteViewController = controller
        configView()
        makeConstraints()
        super.updateConstraints()
    }
}
