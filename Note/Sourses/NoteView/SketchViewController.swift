//
//  SketchScreenViewController.swift
//  Note
//
//  Created by Ян Нурков on 02.02.2023.
//


import UIKit
import Vision
import VisionKit

class SketchViewController: UIViewController, UINavigationControllerDelegate, UITextViewDelegate {
    
    private let uuid: UUID
    private let coreDataManager = CoreDataManager()
    private let sketchView = SketchView()
    private var notes = [Notes]()
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var tab = Bool()
    private var fontSize = Float()
    private var red = Float()
    private var green = Float()
    private var blue = Float()
    private var textColor = UIColor()
    private var imageSize = Float()
    private var scaledImage = UIImage()
    private var attributedString = NSAttributedString()
    private var imagePickerController = UIImagePickerController()
    
    lazy var workQueue = {
        return DispatchQueue(label: "workQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem) }()
    lazy var textRecognitionRequest: VNRecognizeTextRequest = {
        let req = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            var resultText = ""
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { return }
                resultText += topCandidate.string
                resultText += "\n"
            }
            DispatchQueue.main.async {
                self.sketchView.notesView.text = self.sketchView.notesView.text + "\n" + resultText
                let attributedString = NSMutableAttributedString(attributedString: self.sketchView.notesView.attributedText)
                self.saveAttributedString(attributedString: attributedString)
            }
        }
        return req
    }()
    
    init (uuid: UUID) {
        self.uuid = uuid
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: — LifeCycle
    
    override func loadView() {
        super.loadView()
        view = sketchView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sketchView.didLoadUI(controller: self)
        self.loadCoreData()
        self.flagStatus()
        self.toolBarSettings()
        self.loadFont()
        self.sketchView.notesView.delegate = self
        self.imagePickerController.delegate = self
        self.navigationItem.title = "Моя новая заметка"
        NotificationCenter.default.addObserver(self, selector: #selector(updateView), name: Notification.Name("updateView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTextView(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTextView(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadCoreData()
        self.loadFont()
        self.updateTextFont()
    }
    
    // MARK: - PrivateFunctions
    
    private func toolBarSettings() {
        let flagButton = UIBarButtonItem(customView: sketchView.flagButton)
        self.navigationItem.rightBarButtonItem = flagButton
        let toolBar = UIToolbar()
        let textFormat = UIBarButtonItem(image: UIImage(systemName: "textformat"), style: .done, target: self, action: #selector(fontSizeBottom))
        textFormat.tintColor = Colors.navigationTint
        let doneButton = UIBarButtonItem(image: UIImage(systemName: "keyboard.chevron.compact.down"), style: .done, target: self, action: #selector(doneAction))
        doneButton.tintColor = Colors.navigationTint
        let addSnapshot = UIBarButtonItem(image: UIImage(systemName: "camera.fill"), style: .done, target: self, action: #selector(openCamera))
        addSnapshot.tintColor = Colors.navigationTint
        let square = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .done, target: self, action: #selector(square))
        square.tintColor = Colors.navigationTint
        let addImage = UIBarButtonItem(image: UIImage(systemName: "photo"), style: .done, target: self, action: #selector(openGallary))
        addImage.tintColor = Colors.navigationTint
        let addScanner = UIBarButtonItem(image: UIImage(systemName: "scanner"), style: .done, target: self, action: #selector(startScan))
        addScanner.tintColor = Colors.navigationTint
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([flexibleSpace, square, flexibleSpace, textFormat, flexibleSpace, addImage, flexibleSpace, addSnapshot,  flexibleSpace, addScanner, flexibleSpace,  doneButton, flexibleSpace], animated: false)
        toolBar.sizeToFit()
        
        self.sketchView.notesView.inputAccessoryView = toolBar
    }
    
    private func presentActivityController(_ controller: UIActivityViewController?) {
        controller?.modalPresentationStyle = .popover
        if let aController = controller {
            present(aController, animated: true)
        }
        let popController: UIPopoverPresentationController? = controller?.popoverPresentationController
        popController?.permittedArrowDirections = .any
        popController?.barButtonItem = navigationItem.leftBarButtonItem
        controller?.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            if completed {
            } else {
                print("error square")
            }
        }
    }
    
    private func imageSizeUpdate(image: UIImage) {
        if imageSize.isZero {
            self.scaledImage = image.resized(toWidth: 150) ?? UIImage()
        } else {
            self.scaledImage = image.resized(toWidth: CGFloat(self.imageSize)) ?? UIImage()
        }
    }
    
    private func updateTextFont() {
        self.sketchView.notesView.font = .systemFont(ofSize: CGFloat(fontSize))
        self.sketchView.notesView.textColor = UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1)
    }
    
    private func loadCoreData() {
        self.coreDataManager.loadNote(uuid: uuid) { notes in
            self.tab = notes.flagStatus
            self.fontSize = notes.fontSize
            self.red = notes.red
            self.blue = notes.blue
            self.green = notes.green
            self.imageSize = notes.imageSize
            do {
                guard let text = notes.image else {return}
                let unarchiver = try NSKeyedUnarchiver(forReadingFrom: text)
                unarchiver.requiresSecureCoding = false
                let decodedAttributedString = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as! NSAttributedString
                self.sketchView.notesView.attributedText = decodedAttributedString
                self.attributedString = decodedAttributedString
            } catch {
                print("error decoding")
            }
        }
    }
    
    private func loadFont() {
        if fontSize.isZero {
            self.sketchView.notesView.font = .systemFont(ofSize: 17)
            self.fontSize = 17
            self.coreDataManager.updateNote(uuid: uuid, type: .fontSize(Float(fontSize)))
        } else {
            self.updateTextFont()
        }
        if red.isZero || blue.isZero || green.isZero {
            self.sketchView.notesView.textColor = .black
            self.red = 0.0
            self.green = 0.0
            self.blue = 0.0
            self.coreDataManager.updateNote(uuid: uuid, type: .red(red))
            self.coreDataManager.updateNote(uuid: uuid, type: .green(green))
            self.coreDataManager.updateNote(uuid: uuid, type: .blue(blue))
        } else {
            self.sketchView.notesView.textColor = UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1)
        }
    }
    
    private func saveAttributedString(attributedString: NSAttributedString) {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: attributedString, requiringSecureCoding: false)
            self.coreDataManager.updateNote(uuid: uuid, type: .image(data))
            print(data)
            print("Save text")
        } catch {
            print("error encoding")
        }
    }
    
    // MARK: - Functions
    
    func flagStatus() {
        if self.tab == true {
            self.tab = false
            self.sketchView.flagButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            self.coreDataManager.updateNote(uuid: uuid, type: .flagStatus(true))
        } else {
            self.tab = true
            self.sketchView.flagButton.setImage(UIImage(systemName: "heart"), for: .normal)
            self.coreDataManager.updateNote(uuid: uuid, type: .flagStatus(false))
        }
    }
    
    func fontText(size: Float) {
        self.fontSize = size
        print("Font size\(fontSize)")
    }
    
    func fontColor(color: UIColor) {
        self.textColor = color
        print("Font color\(textColor)")
    }
    
    func imageSize(size: Float) {
        self.imageSize = size
        print("Image size\(imageSize)")
    }
    
    // MARK: - Actions
    
    @objc private func square(_ sender: UIButton) {
        guard let text = sketchView.notesView.text else {return}
        let theMessage = "Хочу поделиться с тобой своей новой заметкой: \n \(text)"
        let items = [theMessage]
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        let popPresenter: UIPopoverPresentationController? = controller.popoverPresentationController
        popPresenter?.sourceView = sender
        self.presentActivityController(controller)
    }
    
    @objc private func fontSizeBottom() {
        let sheetViewController = FontBottomSheetViewController(uuid: uuid)
        if let sheet = sheetViewController.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        present(sheetViewController, animated: true)
    }
    
    @objc private func updateView() {
        viewWillAppear(true)
    }
    
    @objc private func openGallary() {
        self.imagePickerController.sourceType = .photoLibrary
        present(self.imagePickerController, animated: true, completion: nil)
    }
    
    @objc private func openCamera() {
        self.imagePickerController.sourceType = .camera
        present(self.imagePickerController, animated: true, completion: nil)
    }
    
    @objc private func startScan() {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = self
        present(scanner, animated: true)
    }
    
    @objc private func doneAction() {
        self.view.endEditing(true)
    }
}

// MARK: — ExtensionTextViewDidChange

extension SketchViewController {
    func textViewDidChange(_ textView: UITextView) {
        guard let text = sketchView.notesView.text else {return}
        self.coreDataManager.updateNote(uuid: uuid, type: .notesView(text))
        let attributedString = NSMutableAttributedString(attributedString: sketchView.notesView.attributedText)
        self.attributedString = attributedString
        self.saveAttributedString(attributedString: attributedString)
    }
}

// MARK: - ExtensionUIImagePickerControllerDelegate

extension SketchViewController:  UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else { return }
        self.imageSizeUpdate(image: image)
        guard let encodedImageString = scaledImage.pngData()?.base64EncodedString() else {return}
        guard let attributedString = NSAttributedString(base64EndodedImageString: encodedImageString) else {return}
        let attributedText = NSMutableAttributedString(attributedString: self.sketchView.notesView.attributedText)
        attributedText.append(attributedString)
        self.sketchView.notesView.attributedText = attributedText
        self.saveAttributedString(attributedString: attributedText)
        self.updateTextFont()
    }
}

// MARK: - ExtensionVNDocumentCameraViewControllerDelegate

extension SketchViewController: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        for i in 0 ..< scan.pageCount {
            let img = scan.imageOfPage(at: i)
            recognizeText(inImage: img)
        }
        controller.dismiss(animated: true)
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        print(error)
        controller.dismiss(animated: true)
    }
    
    private func recognizeText(inImage: UIImage) {
        guard let cgImage = inImage.cgImage else { return }
        workQueue.async {
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try requestHandler.perform([self.textRecognitionRequest])
            } catch {
                print(error)
            }
        }
    }
}

// MARK: - PrivateExtensionKeyboardStatus

private extension SketchViewController {
    @objc private func updateTextView(notification : Notification)
    {
        let userInfo = notification.userInfo!
        let keyboardEndFrameScreenCoordinates = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardEndFrame = self.view.convert(keyboardEndFrameScreenCoordinates, to: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification{
            self.sketchView.notesView.contentInset = UIEdgeInsets.zero
        }
        else
        {
            self.sketchView.notesView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardEndFrame.height, right: 0)
            self.sketchView.notesView.scrollIndicatorInsets = self.sketchView.notesView.contentInset
        }
        self.sketchView.notesView.scrollRangeToVisible(self.sketchView.notesView.selectedRange)
    }
}
