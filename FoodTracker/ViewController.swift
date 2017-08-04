//
//  ViewController.swift
//  FoodTracker
//
//  Created by Bharath Kumar K on 03/08/17.
//  Copyright © 2017 Bharath Kumar K. All rights reserved.
//

import UIKit
import Speech
import AVFoundation

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UITextFieldDelegate {
    //MARK: Properties
    @IBOutlet weak var mealLabelName: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var responseTextView: UITextView!
    @IBOutlet var mealsTableView: UITableView!
    var dishesList = [] as [String]
    //MARK: Actions
    @IBAction func setDefaultLabelText(_ sender: Any) {
        mealLabelName.text="Default Text"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mealsTableView.isHidden=true
        nameTextField.delegate=self
        mealsTableView.delegate=self
        mealsTableView.dataSource=self
        mealsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "customcell")
    }
    
    
    //MARK: UI TExt Field Delegates
    func textFieldShouldReturn(_ textField:UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField:UITextField) {
        var queryUrl="https://westus.api.cognitive.microsoft.com/luis/v2.0/apps/9a6ce124-0f83-40f7-859e-3361b7c55e85?subscription-key=08526f28831a4bc3af718a870ae650f3&verbose=true&timezoneOffset=0&q="
        
        let originalString:String = textField.text!
        let escapedString = originalString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        queryUrl+=escapedString!
        let url = URL(string: queryUrl)
        URLSession.shared.dataTask(with:url!, completionHandler: {(data, response, error) in
            guard let data = data, error == nil else { return }
                let json = try? JSONSerialization.jsonObject(with: data) as? [String:Any]
                let entites = json??["entities"] as? [[String:Any]]
                let name = entites?[0]["entity"] as? String
                DispatchQueue.main.sync() {
                self.handleResponseFromLUIS(name!);
            }
        }).resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dishesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customcell", for: indexPath)
        cell.textLabel?.text = dishesList[indexPath.item] 
        return cell
    }
    
    func handleResponseFromLUIS(_ text:String) {
        let UItext = (text + " cuisines are:").capitalized
        getDishes(text)
        self.responseTextView.text=UItext;
    }
    
    func getDishes(_ cuisine:String) {
        switch cuisine {
        case "indian":
            self.dishesList=["Roti Curry", "Briyani", "Curd Rice", "Masala Dosa", "Idili", "Paluav"]
            break
        case "chinese":
            self.dishesList=["Stir Fried Tofu with Rice", "Fried Rice", "Schezwan Noodels", "Chicken Manchurian"]
            break
        default:
            self.dishesList=["Nothing Here"]
        }
        mealsTableView.reloadData()
        mealsTableView.isHidden=false
    }
    
    func textToSpeech(_ text:String){
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        let synth = AVSpeechSynthesizer()
        synth.speak(utterance)
    }
}
