//
//  FontBottomSheetViewController.swift
//  Note
//
//  Created by Ян Нурков on 30.01.2023.
//

import UIKit

class FontBottomSheetViewController: UIViewController, UITextViewDelegate {
    private let uuid: UUID
    private let fontBottomSheetView = FontBottomSheetView()
    private let coreDataManager = CoreDataManager()
    private var notes = [Notes]()
    private let minimumValue = 0.0
    private let maximumValue = 50.0
    private var fontSize = Int()
    private var red: Float = 0.0
    private var blue: Float = 0.0
    private var green: Float = 0.0
    private let sketchView = SketchView()
    private var imageSizeValue: Float = 1.0
    private let imageSizeValueMinimum: Float = 100.0
    private let imageSizeValueMaximum: Float = 450.0
    private var imageSize = Float()
    
    init (uuid: UUID) {
        self.uuid = uuid
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    
    override func loadView() {
        super.loadView()
        view = fontBottomSheetView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.coreDataManager.loadNote(uuid: uuid) { notes in
            self.fontSize = Int(notes.fontSize)
            self.red = notes.red
            self.blue = notes.blue
            self.green = notes.green
            self.imageSizeValue = notes.imageSize
        }
        self.fontBottomSheetView.didLoadUI(controller: self)
        self.loadSlidersStatus()
    }
    
    // MARK: - Functions
    
    private func loadSlidersStatus() {
        self.fontBottomSheetView.slider.minimumValue = Float(minimumValue)
        self.fontBottomSheetView.slider.maximumValue = Float(maximumValue)
        self.fontBottomSheetView.slider.value = Float(fontSize)
        self.fontBottomSheetView.sliderLabel.text = "Размер шрифта: \(fontSize)"
        self.fontBottomSheetView.redSlider.value = red
        self.fontBottomSheetView.greenSlider.value = green
        self.fontBottomSheetView.blueSlider.value = blue
        self.fontBottomSheetView.redSlider.minimumTrackTintColor = UIColor(red: CGFloat(red), green: 0, blue: 0, alpha: 1)
        self.fontBottomSheetView.greenSlider.minimumTrackTintColor = UIColor(red: 0, green: CGFloat(green), blue: 0, alpha: 1)
        self.fontBottomSheetView.blueSlider.minimumTrackTintColor = UIColor(red: 0, green: 0, blue: CGFloat(blue), alpha: 1)
        self.fontBottomSheetView.sizeSlider.minimumValue = Float(imageSizeValueMinimum)
        self.fontBottomSheetView.sizeSlider.maximumValue = Float(imageSizeValueMaximum)
        self.fontBottomSheetView.sizeSlider.value = Float(imageSizeValue)
        self.fontBottomSheetView.sliderLabelRGB.text = "Цвет текста"
        self.fontBottomSheetView.sliderLabelSize.text = "Размер добавляемой картинки"
    }
    
    func fontSizeSliderValueChanged(_ sender: UISlider) {
        let step: Float = 1
        self.fontSize = Int(round((sender.value - sender.minimumValue) / step))
        self.fontBottomSheetView.sliderLabel.text = "Размер шрифта: \(Int(fontSize))"
        SketchViewController(uuid: uuid).fontText(size: Float(fontSize))
        self.coreDataManager.updateNote(uuid: uuid, type: .fontSize(Float(fontSize)))
        NotificationCenter.default.post(name: Notification.Name("updateView"), object: nil)
    }
    
    func colorSliderValueChanged(_ sender: UISlider) {
        self.red = fontBottomSheetView.redSlider.value
        self.green = fontBottomSheetView.greenSlider.value
        self.blue = fontBottomSheetView.blueSlider.value
        self.fontBottomSheetView.redSlider.minimumTrackTintColor = UIColor(red: CGFloat(red), green: 0, blue: 0, alpha: 1)
        self.fontBottomSheetView.greenSlider.minimumTrackTintColor = UIColor(red: 0, green: CGFloat(green), blue: 0, alpha: 1)
        self.fontBottomSheetView.blueSlider.minimumTrackTintColor = UIColor(red: 0, green: 0, blue: CGFloat(blue), alpha: 1)
        let color = UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1)
        self.fontBottomSheetView.sliderLabelRGB.textColor = color
        SketchViewController(uuid: uuid).fontColor(color: color)
        self.coreDataManager.updateNote(uuid: uuid, type: .green(Float(green)))
        self.coreDataManager.updateNote(uuid: uuid, type: .blue(Float(blue)))
        self.coreDataManager.updateNote(uuid: uuid, type: .red(Float(red)))
        NotificationCenter.default.post(name: Notification.Name("updateView"), object: nil)
    }
    
    func imageSizeSliderValueChanged(_ sender: UISlider) {
        self.imageSize = fontBottomSheetView.sizeSlider.value
        SketchViewController(uuid: uuid).imageSize(size: Float(imageSize))
        self.coreDataManager.updateNote(uuid: uuid, type: .imageSize(Float(imageSize)))
        self.fontBottomSheetView.sliderLabelSize.text = "Размер добавляемой картинки: \(Int(imageSize)) %"
        NotificationCenter.default.post(name: Notification.Name("updateView"), object: nil)
    }
}


