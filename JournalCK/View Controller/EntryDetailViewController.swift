//
//  EntryDetailViewController.swift
//  JournalCK
//
//  Created by Cody on 9/24/18.
//  Copyright © 2018 Cody Adcock. All rights reserved.
//

import UIKit

class EntryDetailViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!
    
    var entry: Entry?{
        didSet{
            loadViewIfNeeded()
            updateView()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func updateView(){
        titleTextField.text = entry?.title
        bodyTextView.text = entry?.body
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let title = titleTextField.text,
            let body = bodyTextView.text else {return}
        
        if let entry = entry{
            EntryController.shared.updateCK(entry: entry, title: title, body: body){(success) in
                if success{
                    print("SUCCESS UPDATING")
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }else{
                    print("Failure updating Entry")
                }
            }
        }else{
            EntryController.shared.createEntry(title: title, body: body)
            self.navigationController?.popViewController(animated: true)
        }

    }

}
