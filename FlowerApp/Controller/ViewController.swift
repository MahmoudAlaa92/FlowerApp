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
        smallImage.contentMode = .scaleAspectFit
        return smallImage
    }()
    
    private let label : UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let button: UIButton = {
       let button = UIButton()
        button.setTitle("Take Photo", for: .normal)
        button.backgroundColor = .systemPink
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.addTarget(ViewController.self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    let imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        setImage(image: "background")
        
        view.addSubview(scrollView)
        scrollView.addSubview(smallImage)
        scrollView.addSubview(label)
        scrollView.addSubview(button)
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
       
    }

    func setImage(image : String){
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "background")
        backgroundImage.contentMode = .scaleAspectFill
        view.addSubview(backgroundImage)
        view.sendSubviewToBack(backgroundImage)
    }
    
    @objc func buttonTapped(){
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
//          imageView.image = selectedImage
            
            guard let ciImage = CIImage(image: selectedImage) else{
                fatalError("Error when covert to ciimage")
            }
            detect(image: ciImage)
        }
        imagePicker.dismiss(animated: true)
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
            self.navigationItem.title = result.identifier.capitalized
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

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
        
        AF.request(wikipediaUrl, method: .get, parameters: parameters).responseJSON { response in
            switch response.result {
            case .success(let data):
                let jsonData = JSON(data)
                let idPage = jsonData["query"]["pageids"][0].stringValue
                let txt = jsonData["query"]["pages"]["\(idPage)"]["extract"].stringValue
                    self.label.text = txt
                print(txt)
                let imageLinkWeb = jsonData["query"]["pages"]["\(idPage)"]["thumbnail"]["source"].stringValue
                self.imageView.sd_setImage(with: URL(string: imageLinkWeb))
            case .failure(let error):
                print(error)
            }
        }
    }
    
}
