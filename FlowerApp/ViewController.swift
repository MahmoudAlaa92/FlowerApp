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
    @IBOutlet weak var imageView: UIImageView!
 
    @IBOutlet weak var descriptionLabel: UILabel!
    
    let wikipediaUrl = "https://en.wikipedia.org/w/api.php"
    
    let imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
    }

    @IBAction func tappedCamera(_ sender: UIBarButtonItem) {
        present(imagePicker ,animated: true)
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
    
        let parameters: [String:String] = [
            "action" : "query",
            "prop" : "extracts|pageimages",
            "titles" : flowerName,
            "explaintext" : "" ,
            "exsectionformat" : "plain",
            "format" : "json",
            "exintro" : "",
            "redirects" : "1",
            "indexpageids" : "",
            "pithumbsize" : "500"
        ]
        AF.request(wikipediaUrl, method: .get, parameters: parameters).responseJSON { response in
            switch response.result {
            case .success(let data):
                let jsonData = JSON(data)
                let idPage = jsonData["query"]["pageids"][0].stringValue
                let txt = jsonData["query"]["pages"]["\(idPage)"]["extract"].stringValue
                    self.descriptionLabel.text = txt
                
                let imageLinkWeb = jsonData["query"]["pages"]["\(idPage)"]["thumbnail"]["source"].stringValue
                self.imageView.sd_setImage(with: URL(string: imageLinkWeb))
            case .failure(let error):
                print(error)
            }
        }
    }
    
}
