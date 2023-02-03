//
//  FontBottomSheetView.swift
//  Note
//
//  Created by Ян Нурков on 30.01.2023.
//

import UIKit

class FontBottomSheetView: UIView {
    private weak var fontBottomSheetController: FontBottomSheetViewController?
    
    // MARK: - Elements
    
    lazy var slider: UISlider = {
        let obj = UISlider(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        obj.addTarget(self, action: #selector(fontSizeSliderValueChanged), for: .valueChanged)
        return obj
    }()
    
    lazy var sliderLabel: UILabel = {
        let obj = UILabel()
        obj.textAlignment = .center
        return obj
    }()
    
    lazy var redSlider: UISlider = {
        let obj = UISlider(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        obj.addTarget(self, action: #selector(colorSliderValueChanged), for: .valueChanged)
        return obj
    }()
    
    lazy var greenSlider: UISlider = {
        let obj = UISlider(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        obj.addTarget(self, action: #selector(colorSliderValueChanged), for: .valueChanged)
        return obj
    }()
    
    lazy var blueSlider: UISlider = {
        let obj = UISlider(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        obj.addTarget(self, action: #selector(colorSliderValueChanged), for: .valueChanged)
        return obj
    }()
    
    lazy var sliderLabelRGB: UILabel = {
        let obj = UILabel()
        obj.textAlignment = .center
        return obj
    }()
    
    lazy var sizeSlider: UISlider = {
        let obj = UISlider(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        obj.addTarget(self, action: #selector(imageSizeSliderValueChanged), for: .valueChanged)
        return obj
    }()
    
    lazy var sliderLabelSize: UILabel = {
        let obj = UILabel()
        obj.textAlignment = .center
        return obj
    }()
    
    // MARK: - Actions
    
    @objc private func fontSizeSliderValueChanged(sender: UISlider) {
        fontBottomSheetController?.fontSizeSliderValueChanged(sender)
    }
    
    @objc private func colorSliderValueChanged(sender: UISlider) {
        fontBottomSheetController?.colorSliderValueChanged(sender)
    }
    
    @objc private func imageSizeSliderValueChanged(sender: UISlider) {
        fontBottomSheetController?.imageSizeSliderValueChanged(sender)
    }
}

// MARK: - PrivateExtension

private extension FontBottomSheetView {
    private func configView() {
        self.backgroundColor = .white
        self.addSubview(self.slider)
        self.addSubview(self.sliderLabel)
        self.addSubview(self.redSlider)
        self.addSubview(self.greenSlider)
        self.addSubview(self.blueSlider)
        self.addSubview(self.sizeSlider)
        self.addSubview(self.sliderLabelRGB)
        self.addSubview(self.sliderLabelSize)
    }
    
    private func makeConstraints() {
        self.slider.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Metric.left)
            make.right.equalToSuperview().offset(Metric.right)
            make.top.equalToSuperview().offset(30)
            make.height.equalTo(30)
        }
        
        self.sliderLabel.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.left.equalToSuperview().offset(Metric.left)
            make.right.equalToSuperview().offset(Metric.right)
            make.centerX.equalToSuperview()
            make.top.equalTo(slider.snp.bottom)
        }
        
        self.redSlider.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Metric.left)
            make.right.equalToSuperview().offset(Metric.right)
            make.top.equalTo(sliderLabel.snp.bottom)
            make.height.equalTo(50)
        }
        
        self.greenSlider.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Metric.left)
            make.right.equalToSuperview().offset(Metric.right)
            make.top.equalTo(redSlider.snp.bottom)
            make.height.equalTo(50)
        }
        
        self.blueSlider.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Metric.left)
            make.right.equalToSuperview().offset(Metric.right)
            make.top.equalTo(greenSlider.snp.bottom)
            make.height.equalTo(50)
        }
        
        self.sliderLabelRGB.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.left.equalToSuperview().offset(Metric.left)
            make.right.equalToSuperview().offset(Metric.right)
            make.centerX.equalToSuperview()
            make.top.equalTo(blueSlider.snp.bottom)
        }
        
        self.sizeSlider.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Metric.left)
            make.right.equalToSuperview().offset(Metric.right)
            make.top.equalTo(sliderLabelRGB.snp.bottom).offset(Metric.top)
            make.height.equalTo(50)
        }
        
        self.sliderLabelSize.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.left.equalToSuperview().offset(Metric.left)
            make.right.equalToSuperview().offset(Metric.right)
            make.centerX.equalToSuperview()
            make.top.equalTo(sizeSlider.snp.bottom)
        }
    }
}

// MARK: - Extension

extension FontBottomSheetView {
    func didLoadUI(controller: FontBottomSheetViewController) {
        self.fontBottomSheetController = controller
        self.configView()
        self.makeConstraints()
        super.updateConstraints()
    }
}
