//
//  ViewController.swift
//  FlowerApp
//
//  Created by MahmoudAlaa on 04/02/2024.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON
import SDWebImage

class ViewController: UIViewController ,UIImagePickerControllerDelegate ,UINavigationControllerDelegate {
    
    let wikipediaUrl = "https://en.wikipedia.org/w/api.php"
    var imageView = UIImageView()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let smallImage: UIImageView = {
        let smallImage = UIImageView()
        smallImage.image = UIImage(named: "image6")
        smallImage.contentMode = .scaleToFill
        smallImage.layer.masksToBounds = true
        return smallImage
    }()
    
    private let typeFlower : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Type of flower"
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 30)
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()
    
    private let descriptionOfFlower: UILabel = {
        let descriptionOfFlower = UILabel()
        descriptionOfFlower.textAlignment = .center
        descriptionOfFlower.numberOfLines = 0
        descriptionOfFlower.text = "Description of the flower"
        descriptionOfFlower.adjustsFontSizeToFitWidth = true
        return descriptionOfFlower
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitle("Take Photo", for: .normal)
        button.backgroundColor = UIColor(named: "colorOfButton")
        button.layer.cornerRadius = 11
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    let imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        setImage(image: "background")
        
        // add sub View
        
        view.addSubview(scrollView)
        scrollView.addSubview(smallImage)
        scrollView.addSubview(typeFlower)
        scrollView.addSubview(button)
        scrollView.addSubview(descriptionOfFlower)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.frame
        
        smallImage.frame = CGRect(x: 30,
                                  y: scrollView.frame.size.height/2,
                                  width: scrollView.frame.size.width-60,
                                  height: scrollView.frame.size.height/2-(30))
        button.frame = CGRect(x: 60,
                              y: smallImage.bottom-50 ,
                              width:smallImage.width-60 ,
                              height: 40)
        typeFlower.frame = CGRect(x: 90,
                                  y: smallImage.top+30,
                                  width: smallImage.width-100,
                                  height: 40)
        descriptionOfFlower.frame = CGRect(x: 90,
                                           y: typeFlower.bottom,
                                           width: smallImage.width-100,
                                           height: smallImage.height-130)
    }
    

    func setImage(image : String){
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "background")
        backgroundImage.contentMode = .scaleAspectFill
        view.addSubview(backgroundImage)
        view.sendSubviewToBack(backgroundImage)
    }
    
    func sdSetImage (image: UIImageView){
        var backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage = image
        backgroundImage.contentMode = .scaleAspectFill
        
        scrollView.addSubview(backgroundImage)
        scrollView.sendSubviewToBack(backgroundImage)
      
        backgroundImage.frame = CGRect(x: 30,
                                  y: scrollView.top,
                                  width: scrollView.frame.size.width,
                                  height: scrollView.frame.size.height)
    }
    @objc func buttonTapped(){
        showImagePickerOption()
    }
    
    func imagePicker(sourceType: UIImagePickerController.SourceType) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = true

        return imagePicker
    }
    
    func showImagePickerOption(){
        let alertVC = UIAlertController(title: "Pick a Photo", message: "choose a picture from liberary or camera", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { [weak self] (action) in
            guard let self = self else{
                return
            }
            
            let cameraImagePicker = self.imagePicker(sourceType: .camera)
            cameraImagePicker.delegate = self
            self.present(cameraImagePicker,animated: true)
        }
        
        let liberaryAction = UIAlertAction(title: "Liberary", style: .default) { [weak self] (action) in
            
            guard let self = self else{
                return
            }
            let liberaryPicker = self.imagePicker(sourceType: .photoLibrary)
            liberaryPicker.delegate = self
            self.present(liberaryPicker,animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertVC.addAction(cameraAction)
        alertVC.addAction(liberaryAction)
        alertVC.addAction(cancelAction)
        self.present(alertVC,animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            guard let ciImage = CIImage(image: selectedImage) else{
                fatalError("Error when covert to ciimage")
            }
            detect(image: ciImage)
        }
        self.dismiss(animated: true)
    }
    
    func detect (image: CIImage){
        
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else {
            fatalError("Cannot import model")
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            
            print(request)
            
            guard let result = request.results?.first as? VNClassificationObservation else {
                fatalError("Error when classify image. ")
            }
            self.typeFlower.text = result.identifier.capitalized
           
            
            self.requestInfo(flowerName: result.identifier)
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do{
            try? handler.perform([request])
        }catch{
            print(error)
        }
    }
    
    func requestInfo (flowerName: String){
        
        var parameters = ParameterOfUrl().parameters
        parameters["titles"] = flowerName
        
        AF.request(wikipediaUrl ,method: .get, parameters: parameters).responseJSON { response in
            switch response.result {
            case .success(let data):
                let jsonData = JSON(data)
                let idPage = jsonData["query"]["pageids"][0].stringValue
                let txt = jsonData["query"]["pages"]["\(idPage)"]["extract"].stringValue
                self.descriptionOfFlower.text = txt
                let imageLinkWeb = jsonData["query"]["pages"]["\(idPage)"]["thumbnail"]["source"].stringValue
                self.imageView.sd_setImage(with: URL(string: imageLinkWeb))
                self.sdSetImage(image:self.imageView)
            case .failure(let error):
                print(error)
            }
        }
    }
    
}
