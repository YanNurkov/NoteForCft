//
//  SketchView.swift
//  Note
//
//  Created by Ян Нурков on 29.01.2023.
//

import UIKit
import SnapKit

class SketchView: UIView {
    private weak var sketchViewController: SketchViewController?
    
    // MARK: - Elements
    
    lazy var notesView: UITextView = {
        let obj = UITextView()
        obj.backgroundColor = .white
        obj.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return obj
    }()
    
    lazy var flagButton: UIButton = {
        let obj = UIButton(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        obj.imageView?.contentMode = .scaleAspectFill
        obj.addTarget(self, action: #selector(flagStatus), for: .touchDown)
        return obj
    }()
    
    // MARK: — Actions
    
    @objc private func flagStatus() {
        sketchViewController?.flagStatus()
    }
}

   // MARK: - PrivateExtension

private extension SketchView {
    private func configView() {
        addSubview(self.notesView)
    }
    
    private func makeConstraints() {
        self.notesView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
    }
}

   // MARK: - Extension

extension SketchView {
    func didLoadUI(controller: SketchViewController) {
        self.sketchViewController = controller
        self.configView()
        self.makeConstraints()
        super.updateConstraints()
    }
}
