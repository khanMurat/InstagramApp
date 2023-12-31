//
//  UploadPostController.swift
//  InstagramTutorial
//
//  Created by Murat on 8.06.2023.
//

import UIKit

protocol UploadPostControllerDelegate : AnyObject {
    func controllerDidFinishUploadingPost(_ controller: UploadPostController)
}

class UploadPostController : UIViewController {
    
    //MARK: - Properties
    
    var currentUser : User?
    
    weak var delegate : UploadPostControllerDelegate?
    
    var selectedImage : UIImage? {
        didSet{photoImageView.image = selectedImage}
    }
    
    private let photoImageView : UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = #imageLiteral(resourceName: "venom-7")
        iv.clipsToBounds = true
        return iv
    }()
    
    private lazy var captionTextView : InputTextView = {
       let tv = InputTextView()
        tv.placeholderText = "Enter caption..."
        tv.font = .systemFont(ofSize:16)
        tv.delegate = self
        return tv
    }()
    
    private let characterCountLabel : UILabel = {
      let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 14)
        label.text = "0/100"
        return label
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
    }
    
    //MARK: - Actions
    
    @objc func didTapCancel(){
        
        self.dismiss(animated: true)
    }
    
    @objc func didTapDone(){
        
        guard let image = selectedImage else {return}
        guard let caption = captionTextView.text else {return}
        guard let user = currentUser else {return}
        
        showLoader(true)
        
        PostService.uploadPost(caption: caption, image: image,user: user) { error in
            
            self.showLoader(false)
            if let error = error {
                self.showMessage(withTitle: error.localizedDescription, message: error.localizedDescription)
                return
            }
            self.showLoader(false)
            self.delegate?.controllerDidFinishUploadingPost(self)
            
        }
    }
    
    //MARK: - Helpers
    
    func configureUI(){
        
        view.backgroundColor = .white
        
        navigationItem.title = "Upload Post"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self,
                                                           action: #selector(didTapCancel))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .done, target: self, action: #selector(didTapDone))
        
        view.addSubview(photoImageView)
        photoImageView.setDimensions(height: 180, width: 180)
        photoImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor,paddingTop: 8)
        photoImageView.centerX(inView: view)
        photoImageView.layer.cornerRadius = 10
        
        view.addSubview(captionTextView)
        captionTextView.anchor(top: photoImageView.bottomAnchor,left: view.leftAnchor,right: view.rightAnchor,paddingTop: 16,paddingLeft: 12,paddingRight: 12,height: 64)
        
        view.addSubview(characterCountLabel)
        characterCountLabel.anchor(bottom: captionTextView.bottomAnchor,right: view.rightAnchor,paddingBottom: -8,paddingRight: 12)
    }
    
    func checkMaxLength(_ textView:UITextView,maxLength:Int){
        if textView.text.count > maxLength {
            textView.deleteBackward()
        }
    }
}

//MARK: - UITextViewDelegate

extension UploadPostController : UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        checkMaxLength(textView, maxLength: 100)
        let count = textView.text.count
        characterCountLabel.text = "\(count)/100"
    }
}
