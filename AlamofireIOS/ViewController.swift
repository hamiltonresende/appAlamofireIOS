//
//  ViewController.swift
//  AlamofireIOS
//
//  Created by Hamilton Ferreira on 14/01/20.
//  Copyright © 2020 Hamilton Ferreira. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    @IBOutlet weak var imgView: UIImageView!
    
    @IBAction func btnSelecionar(_ sender: UIButton) {
        takePicture(sender)
    }
    
    @IBAction func btnEnviar(_ sender: UIButton) {
        send(sender)
    }
    
    
    override func viewDidLoad() {
      super.viewDidLoad()

    }

    @objc func send(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "",
                                      message: "Digite o título",
                                      preferredStyle: .alert)

        let submit = UIAlertAction(title: "Submit", style: .default) { (action) in
          if (alert.textFields?.count ?? 0 > 0) {
            if let image = self.imgView.image, let textField = alert.textFields?.first {
              self.upload(image: image, text: textField.text ?? "") //. upload aqui!
            }
          }
        }

        alert.addAction(submit)
        alert.addTextField { (textField) in
          textField.placeholder = "Titulo"
        }

        present(alert, animated: true)

        print("send")
    }

    @objc func takePicture(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
          picker.sourceType = .camera
        } else {
          picker.sourceType = .photoLibrary
          picker.modalPresentationStyle = .fullScreen
        }

        present(picker, animated: true)
    }
    
    fileprivate func upload(image: UIImage, text: String) {
      // 1
      guard let imageData = image.jpegData(compressionQuality: 0.5) else {
        print("Could not get JPEG representation of UIImage")
        return
      }
      // 2
      Alamofire.upload(multipartFormData: { (formData) in
        formData.append(imageData,
                        withName: "image",
                        fileName: "image.jpg",
                        mimeType: "image/jpeg")
        formData.append(text.data(using: String.Encoding.utf8)!, withName: "title")
        }, to: "https://api.imgur.com/3/image",
           headers: ["Authorization": "Client-ID 831c0b7493d0c4d"],
           encodingCompletion: { encodingResult in
               switch encodingResult {
               case .success(let upload, _, _):
                   upload.responseJSON { (response) in
                         // 3
                         guard response.result.isSuccess, let value = response.result.value as? [String: Any] else {
                           print("Error \(String(describing: response.result.error))")
                           // completion error
                           return
                         }

                         // 4
                         guard let rows = value["data"] as? [String: Any] else {
                             print("Malformed data received from service")
                             // completion error
                             return
                         }

                         // 5
                         print("Link da imagem \(String(describing: rows["link"]))")
                         print("Titulo da imagem \(String(describing: rows["title"]))")
                   }
               case .failure(let encodingError):
                   print(encodingError)
               }
           }
      )
    }
    
    
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { // 1
      print("failure to handle info")
      dismiss(animated: true)
      return
    }

    imgView.image = image // 2
    dismiss(animated: true)
  }

}
