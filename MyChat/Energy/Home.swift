//
//  Home.swift
//  Closio
//
//  Created by Rahul on 24/04/18.
//  Copyright © 2018 Rahul. All rights reserved.
//

import UIKit
import Speech
import CoreData
import SystemConfiguration


class Home: UIViewController, UITextViewDelegate, SFSpeechRecognizerDelegate,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var txViewMessage: UITextView!
    //    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnSpeak: UIButton!
    @IBOutlet weak var btnSend: UIButton!
    var bottomView: UIView!
    var TopViewOnTextBox: UIView!
    var scrollView: UIScrollView!
    var TextMessages: [NSManagedObject] = []
    var btnArray = [String]()
    var showFooter = Bool()
    var BtnView: UIView!
    
    // Speech methods
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private let audioEngine = AVAudioEngine()
    
    var textView : UITextView!
    
    @IBOutlet var button : UIButton!
    
    var btnsend : UIButton!
    
    var tblview: UITableView!
    var tblviewPredict: UITableView!
    
    var textArray = [String]()
    var ControlTypeArray = [String]()
    var AlingText = [Bool]()
    var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Energy"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Menu", style: .plain, target: self, action: #selector(SSASideMenu.presentLeftMenuViewController))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear All", style: .plain, target: self, action: #selector(clearDataBase))
        
        //        navigationController?.navigationBar.isTranslucent = false
        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Right", style: .plain, target: self, action: #selector(SSASideMenu.presentRightMenuViewController))
        let screenSize: CGRect = UIScreen.main.bounds
        
        IQKeyboardManager.shared.disabledToolbarClasses = [Home.self]
        IQKeyboardManager.shared.enable = false
        
        //print("Screen height: \(screenSize.height)")
        //Bottom view to hold send speak textbox
        //bottomView = UIView(frame: CGRect(x: 0, y: screenSize.height-64-44, width: screenSize.width, height: 44))
        bottomView = UIView(frame: CGRect(x: screenSize.minX + 1 , y: screenSize.height-44, width: screenSize.width-1, height: 45))
        bottomView.backgroundColor = UIColor(red: 238.0/255.0, green: 238.0/255.0, blue: 238.0/255.0, alpha: 1)
        
        
        
        //Voice button
        button = UIButton()
        button.frame = CGRect(x: 0, y: 2, width: 40, height: 40)
        button.backgroundColor = UIColor.white
        button.setTitle("Speak", for: .normal)
        button.layer.cornerRadius = button.frame.width/2
        button.layer.masksToBounds = true
        button.setImage(UIImage.init(named: "mic"), for: .normal)
        button.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
        bottomView.addSubview(button)
        button.isEnabled = false
        
        // Send message button
        btnsend = UIButton()
        btnsend.frame = CGRect(x: bottomView.bounds.size.width - 40, y: 2, width: 40, height: 40)
        //btnsend.backgroundColor = UIColor(red: 138.0/255.0, green: 58.0/255.0, blue: 199.0/255.0, alpha: 1)
        btnsend.backgroundColor = UIColor.white
        btnsend.layer.cornerRadius = 5
        btnsend.layer.masksToBounds = true
        btnsend.setTitle("send", for: .normal)
        btnsend.setImage(UIImage.init(named: "send"), for: .normal)
        btnsend.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        bottomView.addSubview(btnsend)
        
        // Type message box
        textView = UITextView()
        textView.delegate = self
        textView.layer.cornerRadius = 5
        textView.layer.masksToBounds = true
        textView.font = UIFont(name: "San Francisco", size: 18)
        textView.frame = CGRect(x:  44 , y: 2, width: bottomView.bounds.size.width - 88, height: 40)
        bottomView.addSubview(textView)
        
        //Message tableview
        tblview = UITableView(frame: CGRect.zero, style: .grouped)
        tblview.dataSource = self
        tblview.delegate = self
        tblview.estimatedRowHeight = 44.0
        tblview.rowHeight = UITableViewAutomaticDimension
        tblview.frame = CGRect(x: 0 , y: 0, width: screenSize.width, height: screenSize.maxY - 44)
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "ChatBubble", bundle: bundle)
        let nibR = UINib(nibName: "ChatBubbleRight", bundle: bundle)
        let nibImage = UINib(nibName: "ImageCell", bundle: bundle)
        tblview.register(nibR, forCellReuseIdentifier: "cellR")
        tblview.register(nib, forCellReuseIdentifier: "cell")
        tblview.register(nibImage, forCellReuseIdentifier: "cellImage")
        tblview.backgroundColor = UIColor.white
        tblview.allowsSelection = false
        tblview.separatorStyle = .none
        var frame = CGRect.zero
        frame.size.height = .leastNormalMagnitude
        tblview.tableHeaderView = UIView(frame: frame)
        
        // Buttons view
        BtnView = UIView(frame: CGRect(x: 0, y: screenSize.height + 10, width: screenSize.width, height: 280))
        BtnView.backgroundColor = UIColor(red: 238.0/255.0, green: 238.0/255.0, blue: 238.0/255.0, alpha: 1)
        //BtnView.backgroundColor = UIColor.black
        
        self.view.addSubview(tblview)
        self.view.addSubview(bottomView)
        self.view.addSubview(BtnView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(Home.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Home.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
                
                // add for tableview show content on keyboard shown
                self.tblview.contentInset = UIEdgeInsetsMake(keyboardSize.height, 0, 0, 0)
                // end here
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
                
                // add for tableview show content on keyboard shown
                self.tblview.contentInset = UIEdgeInsetsMake( 10, 0, 0, 0)
                // end here
            }
        }
    }
    
    func AnimateImages()
    {
        imageView = UIImageView(frame: CGRect(x: 0, y: self.tblview.frame.height - 47, width: 45, height: 45))
        //imageView.backgroundColor = UIColor.black
        self.view.addSubview(imageView)
        
        imageView.animationImages = [#imageLiteral(resourceName: "1"), #imageLiteral(resourceName: "2"), #imageLiteral(resourceName: "3"),#imageLiteral(resourceName: "4")]
        imageView.animationDuration = 1
    }
    
    @objc func buttonAction(sender: UIButton!) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            
            print("\(textView.text)")
            let trimmedString = textView.text.trimmingCharacters(in: .whitespaces)
            if audioEngine.isRunning {
                audioEngine.stop()
                recognitionRequest?.endAudio()
                textView.text=""
                button.isEnabled = false
                button.setTitle("Stopping", for: .disabled)
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
            if(trimmedString != "")
            {
                textArray.append(trimmedString)
                AlingText.append(false)
                
                self.saveText(text: trimmedString, alignLeft: false)
                // save to database
                
                //print("Button tapped \(textArray)")
                textView.resignFirstResponder()
                DispatchQueue.main.async {
                    //self.tblview.reloadData()
                    //self.tblview.scrollToLastCell(animated: true)
                    let indexPath = IndexPath(item: self.textArray.count-1, section: 0)
                    self.tblview.insertRows(at: [indexPath],with: UITableViewRowAnimation.bottom)
                    //self.tblview.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    //self.showFooter = true
                    //self.tblview.reloadSections(IndexSet([0]), with: UITableViewRowAnimation.none)
                    self.textView.text = ""
                }
                //"BotId": "5ae6de074056af0550de59fc",     old ID
                let percentescaping = trimmedString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                let jsonD: [String: Any] = ["BotId": "5af967704b34e66e0cba6b9d",
                                            "userID": "59fbfe2ad84a550808a65930",
                                            "message": percentescaping ?? "Hi",
                                            "isLuisCall": "0"]
                self.makeApiCall(json: jsonD)
                
            }else{
                print("Entered the text was not correct")
                self.imageView.stopAnimating()
            }
            
           
        }
        else{
            print("Internet Connection not Available!")
            let alertV = UIAlertController.init(title: "Energy", message:"Please check for the internet connectivity then try again", preferredStyle: .alert)
            self.present(alertV, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //print("Row Height: \(UITableViewAutomaticDimension)")
        return UITableViewAutomaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        
//                tblview.estimatedRowHeight = 80
//                tblview.rowHeight = UITableViewAutomaticDimension
        
        self.textView.layer.cornerRadius = button.frame.width/2
        self.textView.textContainerInset = UIEdgeInsetsMake(10, 0, 0, 0)
        self.textView.font = UIFont.systemFont(ofSize: 16)
        
        //1
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Text")
        
        //3
        do {
            TextMessages = try managedContext.fetch(fetchRequest)
            for data in TextMessages {
                //print(data.value(forKey: "message") as! String)
                //print(data.value(forKey: "alignLeft") as! Bool)
                self.textArray.append(data.value(forKey: "message") as! String)
                self.AlingText.append(data.value(forKey: "alignLeft") as! Bool)
            }
            self.tblview.reloadData()
            //self.tblview.scrollToLastCell(animated: true)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }
    
    
    @objc func clearDataBase()
    {
        self.textArray.removeAll()
        self.AlingText.removeAll()
        self.btnArray.removeAll()
        imageView.startAnimating()

        self.hidebtnView()
        //clear data
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Text")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        let managedObjectContext =
            appDelegate.persistentContainer.viewContext
        do{
            _ = try managedObjectContext.execute(request)
            if (textArray.count == 0){
                self.textArray.append("Hi! How may I help you be successful today?")
                self.AlingText.append(true)
                self.saveText(text: "Hi! How may I help you be successful today?", alignLeft: true)
            }else{
                print("ther is chat history")
                self.tblview.scrollToLastCell(animated: true)
            }
            DispatchQueue.main.async {
                self.tblview.reloadData()
                self.imageView.stopAnimating()

            }
        }catch let error2 as NSError{
            print("This is error\(error2)")
        }
    }
    
    /* Updated for Swift 4 */
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    /* Older versions of Swift */
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (textArray.count > 0){
            tblview.scrollToLastCell(animated: true)
        }
        
        
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
    }
    
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return textArray.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (AlingText[indexPath.row]){                                                  //If true Align left for black chat bubble
            let cell = tblview.dequeueReusableCell(withIdentifier: "cell", for:indexPath) as! ChatBubble
            // create a new cell if needed or reuse an old one
            cell.lblTextMessage.text = textArray[indexPath.row]
            cell.layer.cornerRadius = 20
            cell.layer.masksToBounds = true
            cell.backgroundColor = UIColor.clear
            
            
            cell.cellSafeView.backgroundColor = UIColor(red: 238.0/255.0, green: 238.0/255.0, blue: 238.0/255.0, alpha: 1)
            cell.lblTextMessage.textColor = UIColor.black
            cell.lblTextMessage.textAlignment = .left
            if indexPath.row+1<textArray.count
            {
                if AlingText[indexPath.row+1]
                {
                    cell.leftpicProfile.isHidden = true
                }else{
                    cell.leftpicProfile.isHidden = false
                }
            }else{
                cell.leftpicProfile.isHidden = false
            }
            
            
            return cell
            
        }else{
            
            let cell = tblview.dequeueReusableCell(withIdentifier: "cellR", for:indexPath) as! ChatBubbleRight
            // create a new cell if needed or reuse an old one
            cell.lblTextMessage.text = textArray[indexPath.row]
            cell.layer.cornerRadius = 20
            cell.layer.masksToBounds = true
            cell.backgroundColor = UIColor.clear
            
            
            cell.cellSafeView.backgroundColor = UIColor(red: 75.0/255.0, green: 75.0/255.0, blue: 75.0/255.0, alpha: 1)
            cell.lblTextMessage.textColor = UIColor.white
            cell.lblTextMessage.textAlignment = .left
            if indexPath.row+1<textArray.count
            {
                if !AlingText[indexPath.row+1]
                {
                    cell.rightProfilePic.isHidden = true
                }else{
                    cell.rightProfilePic.isHidden = false
                }
            }else{
                cell.rightProfilePic.isHidden = false
            }
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    //Speech
    // MARK: UIViewController
    override public func viewDidAppear(_ animated: Bool) {
        //self.loadJson(fileName: "Response")
        self.AnimateImages()
        if (textArray.count == 0){
        self.textArray.append("Hi! How may I help you be successful today?")
        self.AlingText.append(true)
        self.saveText(text: "Hi! How may I help you be successful today?", alignLeft: true)
        }else{
            print("ther is chat history")
            self.tblview.scrollToLastCell(animated: true)
        }
        DispatchQueue.main.async {
            self.tblview.reloadData()
        }
        
        speechRecognizer.delegate = self
        SFSpeechRecognizer.requestAuthorization { authStatus in
            /*
             The callback may not be called on the main thread. Add an
             operation to the main queue to update the record button's state.
             */
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.button.isEnabled = true
                    
                case .denied:
                    self.button.isEnabled = false
                    self.button.setTitle("User denied access to speech recognition", for: .disabled)
                    
                case .restricted:
                    self.button.isEnabled = false
                    self.button.setTitle("Speech recognition restricted on this device", for: .disabled)
                    
                case .notDetermined:
                    self.button.isEnabled = false
                    self.button.setTitle("Speech recognition not yet authorized", for: .disabled)
                }
            }
        }
    }
    
    private func startRecording() throws {
        
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode         //inputNode else { fatalError("Audio engine has no input node") }
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        // Configure request so that results are returned before audio recording is finished
        recognitionRequest.shouldReportPartialResults = true
        
        // A recognition task represents a speech recognition session.
        // We keep a reference to the task so that it can be cancelled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                self.textView.text = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.textView.text = ""
                
                self.button.isEnabled = true
                self.button.setTitle("Start Recording", for: [])
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        }
        catch
        {
            print("Unexpected error: \(error).")
        }
        textView.text = "(Go ahead, I'm listening)"
    }
    
    // MARK: SFSpeechRecognizerDelegate
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            button.isEnabled = true
            //button.setTitle("Start Recording", for: [])
            textView.text = "Start Recording"
        } else {
            button.isEnabled = false
            //button.setTitle("Recognition not available", for: .disabled)
            textView.text = "Recognition not available"
        }
    }
    
    // MARK: Interface Builder actions
    
    @IBAction func recordButtonTapped() {
        
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            if audioEngine.isRunning {
                audioEngine.stop()
                recognitionRequest?.endAudio()
                button.isEnabled = false
                textView.text="Stopping"
                //button.setTitle("Stopping", for: .disabled)
            } else {
                try! startRecording()
                //button.setTitle("Stop recording", for: [])
            }
            textView.text=""
        }else{
            print("Internet Connection not Available!")
            let alertV = UIAlertController.init(title: "Energy", message: "Please check for the internet connectivity then try again", preferredStyle: .alert)
            self.present(alertV, animated: true, completion: nil)
        }
        
    }
    
    
    func saveText(text: String, alignLeft: Bool) {
        DispatchQueue.main.async {
            
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            
            // 1
            let managedContext =
                appDelegate.persistentContainer.viewContext
            
            // 2
            let entity = NSEntityDescription.entity(forEntityName: "Text", in: managedContext)
            
            let EText = NSManagedObject(entity: entity!,
                                        insertInto: managedContext)
            
            // 3
            EText.setValue(text, forKeyPath: "message")
            EText.setValue(alignLeft, forKeyPath: "alignLeft")
            
            // 4
            do {
                try managedContext.save()
                //self.TextMessages.append(EText)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    /*func clearDataBase(){
     // create the delete request for the specified entity
     let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Text")
     let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
     
     // get reference to the persistent container
     let persistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
     
     // perform the delete
     do {
     try persistentContainer.viewContext.execute(deleteRequest)
     } catch let error as NSError {
     print(error)
     }
     }*/
    
    var countToinsert = 1
    
    
    func makeApiCall(json: [String: Any]){
        if !json.isEmpty {
            imageView.startAnimating()
            
            let data = try! JSONSerialization.data(withJSONObject: json)
            //var request = URLRequest(url: URL(string: "http://winjitstaging.cloudapp.net:1992/home/getMessagesForIntentV3")!)
            var request = URLRequest(url: URL(string: "http://winjitstaging.cloudapp.net:1992/home/getMessagesForIntentV4_energy")!)
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody =  data
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print("error=(error)")
                    return
                }
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    //print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    //print("response = \(String(describing: response))")
                }
                //let responseString = String(data: data, encoding: .utf8)
                //print("responseString = \(responseString ?? "Check for response issue")")
                var yesbtnPresent = false
                do {
                    let dictonary =  try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
                    
                    if let myDictionary = dictonary
                    {
                        //print(" Status is: \(myDictionary["result"]!)")
                        let resultData = try! JSONSerialization.data(withJSONObject: myDictionary["result"]!, options: JSONSerialization.WritingOptions.init(rawValue: 0))
                        //let botIntent = myDictionary["result"]["BotIntentFlow"]["name"] as String
                        do{
                            let decode = try JSONDecoder().decode(Result.self, from: resultData)
                            //print(decode)
                            if decode.BotIntentFlow!.count > 0 {
                                for botresp in decode.BotIntentFlow!{
                                    //print ("Resp Array: \(String(describing: botresp.buttonoptions))")
                                    //print ("Resp type control: \(String(describing: botresp.name))")
                                    if botresp.buttonoptions != nil
                                    {
                                        self.btnArray = botresp.buttonoptions!.components(separatedBy: "|")
                                    }
                                    self.ControlTypeArray.append(botresp.name)
                                    print("Control Type: \(self.ControlTypeArray)")
                                    if(botresp.name == "Button"){
                                        yesbtnPresent = true
                                    }
                                    self.countToinsert =   self.countToinsert + 1
                                    
                                    //                                    if(botresp.name == "Text"){
                                    //                                        self.countToinsert =   self.countToinsert + 1
                                    //                                    }
                                    
                                    if let trimmedString = botresp.strdata?.trimmingCharacters(in: .whitespaces)
                                    {
                                        self.textArray.append(trimmedString)
                                        self.AlingText.append(true)
                                        self.saveText(text: trimmedString, alignLeft: true)
                                        
                                        //self.updateTableViewWithCurrentContent()
                                        
                                    }else{
                                        self.textArray.append(decode.menutrigger.MenuMessage)
                                        //print("What is intent: \(decode.menutrigger.MenuIntent)")
                                        //self.textArray.append("BotIntentFlow is empty")
                                        self.AlingText.append(true)
                                        //self.updateTableViewWithCurrentContent()
                                        self.saveText(text: decode.menutrigger.MenuMessage, alignLeft: true)
                                        
                                    }
                                }
                                
                            }
                            else{
                                self.textArray.append(decode.menutrigger.MenuMessage)
                                //print("What is intent2: \(decode.menutrigger.MenuIntent)")
                                //self.textArray.append("BotIntentFlow is empty")
                                self.AlingText.append(true)
                                //self.updateTableViewWithCurrentContent()
                                self.saveText(text: decode.menutrigger.MenuMessage, alignLeft: true)
                                
                            }
                            
                        }
                        catch  let error1 as NSError{
                            //                            let decode = try JSONDecoder().decode(Result.self, from: resultData)
                            //                            print(decode)
                            //                            self.textArray.append(decode.menutrigger.MenuMessage)
                            //                            print("What is intent: \(decode.menutrigger.MenuIntent)")
                            self.textArray.append("Seems you are confused! How I can help you?")
                            self.AlingText.append(true)
                            self.btnArray.removeAll()
                            self.saveText(text: "Seems you are confused! How I can help you?", alignLeft: true)
                            
                            //self.showFooter = false
                            //self.tblview.reloadSections(IndexSet([0]), with: UITableViewRowAnimation.none)
                            print(error1)
                        }
                    }
                } catch let error as NSError {
                    print(error)
                }
                
                
                DispatchQueue.main.async {
                    //                    self.tblview.reloadData()
                    //                    self.tblview.scrollToLastCell(animated: false)
                    if (self.countToinsert > 1){
                        self.tblview.reloadData()
                        self.tblview.scrollToLastCell(animated: true)
                        self.imageView.stopAnimating()
                    }else{
                        let indexPath = IndexPath(item: self.textArray.count-1, section: 0)
                        self.tblview.insertRows(at: [indexPath],with: UITableViewRowAnimation.bottom)
                        self.imageView.stopAnimating()
                    }
                    //                    self.tblview.reloadData()
                    //                    self.tblview.scrollToLastCell(animated: true)
                    
                    //self.tblview.scrollToBottom(animated: false)
                    //self.tblview.reloadSections(IndexSet([0]), with: UITableViewRowAnimation.none)
                    
                    //self.tblview.scrollRectToVisible((self.tblview.tableFooterView?.frame)!, animated: true)
                    if (yesbtnPresent){
                        self.textView.isHidden = true
                        self.button.isHidden = true
                        self.btnsend.isHidden = true
                        self.addAPIButtonsToView()
                        yesbtnPresent = false
                        
                    }
                    
                    //self.tblview.scrollToBottom(animated: true)
                    /*let indexPath = IndexPath(item: self.textArray.count-1, section: 0)
                     self.tblview.insertRows(at: [indexPath],with: UITableViewRowAnimation.bottom)
                     self.tblview.scrollToRow(at: indexPath, at: .bottom, animated: true)*/
                }
                
            }
            task.resume()
        }
        else{
            print("Data is empty")
        }
    }
    
    func updateTableViewWithCurrentContent()
    {
        DispatchQueue.main.async {
            
            for _ in (1..<self.countToinsert)
            {
                let indexPath = IndexPath(item: self.textArray.count - self.countToinsert, section: 0)
                self.tblview.insertRows(at: [indexPath],with: UITableViewRowAnimation.bottom)
                self.countToinsert = self.countToinsert - 1
            }
            
            
        }
    }
    
    @objc func getToBottom()
    {
        self.tblview.scrollToLastCell(animated: true)
    }
    
    /*
     //Action Sheet
     func showAlert(sender: AnyObject) {
     let alert = UIAlertController(title: "Title", message: "Please Select an Option", preferredStyle: .actionSheet)
     
     alert.addAction(UIAlertAction(title: "Approve", style: .default , handler:{ (UIAlertAction)in
     print("User click Approve button")
     }))
     
     alert.addAction(UIAlertAction(title: "Edit", style: .default , handler:{ (UIAlertAction)in
     print("User click Edit button")
     }))
     
     alert.addAction(UIAlertAction(title: "Delete", style: .destructive , handler:{ (UIAlertAction)in
     print("User click Delete button")
     }))
     
     alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:{ (UIAlertAction)in
     print("User click Dismiss button")
     }))
     
     self.present(alert, animated: true, completion: {
     print("completion block")
     })
     }*/
    
    
    func loadJson( fileName: String)  {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let deco = try decoder.decode(Result.self, from: data)
                print("\(deco)")
            } catch {
                print("error:\(error)")
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        //print("In Layout subviews")
    }
    
    func addAPIButtonsToView()
    {
        let scrollView = UIScrollView()
        scrollView.contentSize = CGSize(width: 500, height: 50)
        print("In Footer view subviews")
        
        //        let footerView = UIView.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        let footerView = UIView()
        footerView.backgroundColor = UIColor.clear
        //var posX : CGFloat = 10
        var posY : CGFloat = 10
        for title in self.btnArray{
            //        let frame = CGRect(x: 0, y: 0, width: title.widthOfString(usingFont: UIFont.systemFont(ofSize: 9)), height: 20)
            //        let btns = UIButton(frame: CGRect(x: frame.maxX + frame.width + 10, y: 10, width: frame.width + 10, height: 20))
            //let width  : CGFloat = title.widthOfString(usingFont: UIFont.systemFont(ofSize: 16)) + 10
            let height : CGFloat = title.heightOfString(usingFont: UIFont.systemFont(ofSize: 16)) + 10
            let btns = UIButton(frame: CGRect(x: 5, y: posY, width: self.tblview.frame.width - 10, height: 34))
            posY = posY + height + 10
            btns.backgroundColor = UIColor(red: 238.0/255.0, green: 238.0/255.0, blue: 238.0/255.0, alpha: 1)
            btns.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            btns.setTitle(title, for: UIControlState.normal)
            btns.setTitleColor(UIColor.black, for: .normal)
            btns.layer.cornerRadius = 5
            btns.layer.masksToBounds = true
            btns.contentHorizontalAlignment = .left
            
            //            btns.layer.borderColor = UIColor.black.cgColor
            //            btns.layer.borderWidth = 1
            btns.addTarget(self, action: #selector(buttonTouched), for: .touchUpInside)
            footerView.addSubview(btns)
        }
        //footerView.frame = CGRect(x: 0, y: 0, width: posX, height: 40)
        footerView.frame = CGRect(x: 0, y: 0, width: self.tblview.frame.width, height: posY)
        
        scrollView.frame = CGRect(x: 0 , y: 0, width: footerView.frame.width, height: footerView.frame.height)
        scrollView.contentSize = CGSize(width: footerView.frame.width, height: footerView.frame.height)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isScrollEnabled = false
        scrollView.addSubview(footerView)
        self.BtnView.frame = CGRect(x: 0 , y: self.view.bounds.height+footerView.frame.height, width: footerView.frame.width, height: footerView.frame.height)
        
        self.BtnView.addSubview(scrollView)
        showbtnView()
        
    }
    
    
    func showbtnView()
    {
        
        UIView.animate(withDuration: 0.7, delay: 0, options: [.curveEaseOut],
                       animations: {
                        self.BtnView.frame = CGRect(x: 0, y: self.view.bounds.height-self.BtnView.frame.height, width: self.view.bounds.width, height: self.BtnView.frame.height)
                        //self.view.layoutIfNeeded()
        }, completion: { finish in
            if (finish)
            {
                self.tblview.contentInset = UIEdgeInsetsMake(0, 0, self.BtnView.frame.height, 0)
                self.tblview.scrollToLastCell(animated: true)
            }
        })
        
    }
    
    func hidebtnView()
    {
        UIView.animate(withDuration: 0.7, delay: 0, options: [.curveEaseOut],
                       animations: {
                        self.BtnView.frame = CGRect(x: 0, y: self.view.bounds.height+self.BtnView.frame.height+10, width: self.view.bounds.width, height: self.BtnView.frame.height)
                        //self.view.layoutIfNeeded()
        }, completion: { finish in
            if (finish)
            {
                self.tblview.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
                self.textView.isHidden = false
                self.button.isHidden = false
                self.btnsend.isHidden = false
            }
        })
    }
    
    
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        //        if showFooter{
        //        //        let scrollView = UIScrollView.init(frame: CGRect(x: 0 , y: 0, width: self.tblview.frame.width, height: 50))
        //        let scrollView = UIScrollView()
        //        scrollView.contentSize = CGSize(width: 500, height: 50)
        //            print("In Footer view subviews")
        //
        //        //        let footerView = UIView.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        //        let footerView = UIView()
        //        footerView.backgroundColor = UIColor.clear
        //        var posX : CGFloat = 10
        //        var posY : CGFloat = 10
        //        for title in self.btnArray{
        //            //        let frame = CGRect(x: 0, y: 0, width: title.widthOfString(usingFont: UIFont.systemFont(ofSize: 9)), height: 20)
        //            //        let btns = UIButton(frame: CGRect(x: frame.maxX + frame.width + 10, y: 10, width: frame.width + 10, height: 20))
        //            let width  : CGFloat = title.widthOfString(usingFont: UIFont.systemFont(ofSize: 16)) + 10
        //            let height : CGFloat = title.heightOfString(usingFont: UIFont.systemFont(ofSize: 16)) + 10
        //            let btns = UIButton(frame: CGRect(x: 5, y: posY, width: self.tblview.frame.width - 10, height: 34))
        //            posY = posY + height + 10
        //            btns.backgroundColor = UIColor(red: 238.0/255.0, green: 238.0/255.0, blue: 238.0/255.0, alpha: 1)
        //            btns.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        //            btns.setTitle(title, for: UIControlState.normal)
        //            btns.setTitleColor(UIColor.black, for: .normal)
        //            btns.layer.cornerRadius = btns.frame.height / 2
        //            btns.layer.masksToBounds = true
        ////            btns.layer.borderColor = UIColor.black.cgColor
        ////            btns.layer.borderWidth = 1
        //            btns.addTarget(self, action: #selector(buttonTouched), for: .touchUpInside)
        //            footerView.addSubview(btns)
        //        }
        //        //footerView.frame = CGRect(x: 0, y: 0, width: posX, height: 40)
        //        footerView.frame = CGRect(x: 0, y: 0, width: self.tblview.frame.width, height: posY)
        //
        //        scrollView.frame = CGRect(x: 0 , y: 0, width: footerView.frame.width, height: footerView.frame.height)
        //        scrollView.contentSize = CGSize(width: footerView.frame.width, height: footerView.frame.height)
        //        scrollView.showsVerticalScrollIndicator = false
        //        scrollView.isScrollEnabled = false
        //        scrollView.addSubview(footerView)
        ////        self.button.isHidden = true
        ////            self.btnSend.isHidden = true
        ////            self.textView.isHidden = true
        //        return scrollView
        //
        //        }
        //        else
        //        {
        //            print ("Do not show footer view")
        //            return nil
        //        }
        return nil
    }
    
    @objc func buttonTouched(sender:UIButton!){
        print("diklik")
        hidebtnView()
        self.textView.text = sender.titleLabel?.text
        showFooter = false
        self.btnArray.removeAll()
        self.showFooter = false
        self.buttonAction(sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        /*if showFooter{
         return CGFloat(50 * self.btnArray.count)
         }
         else {
         return 0
         }*/
        return 0
        
        
    }
    
    
    struct  Result:Codable {
        
        let botId : String?
        let IntentName :  String
        let BotIntentFlow : [entBotIntentFlow]?
        let menutrigger : menutrigger
        
        enum CodingKeysResult:  String, CodingKey {
            case botId  = "botId"
            case IntentName = "IntentName"
            case BotIntentFlow = "BotIntentFlow"
            case menutrigger = "menutrigger"
        }
        
        struct entBotIntentFlow: Codable {
            
            let name: String
            let inputType: String
            let icon: String
            let strclass: String
            let strid: String
            //let duration: Int?
            let strdata: String?
            let isSent: Int
            let entityType: String?
            let answer: String?
            let buttonoptions: String?
            
            enum CodingKeys:  String, CodingKey {
                case name  = "name"
                case inputType = "inputType"
                case icon = "icon"
                case strclass = "class"
                case strid = "id"
                //case duration = "duration"
                case strdata = "data"
                case isSent = "isSent"
                case entityType = "entityType"
                case answer = "answer"
                case buttonoptions = "buttonoptions"
            }
        }
        
        struct menutrigger: Codable {
            
            let BotId: String
            let MenuMessage: String
            let vInt: Int
            let strId: String
            
            let MenuIntent: [entMenuIntent]
            
            enum CodingKeys:  String, CodingKey {
                case BotId  = "BotId"
                case MenuIntent = "MenuIntent"
                case MenuMessage = "MenuMessage"
                case vInt = "__v"
                case strId = "_id"
            }
            
            struct entMenuIntent: Codable {
                
                let IntentName1: String
                
                enum CodingKeys:  String, CodingKey {
                    case IntentName1  = "IntentName"
                }
            }
        }
    }
    
}


extension UITableView {
    func scrollToLastCell(animated : Bool) {
        let lastSectionIndex = self.numberOfSections - 1 // last section
        let lastRowIndex = self.numberOfRows(inSection: lastSectionIndex) - 1 // last row
        self.scrollToRow(at: IndexPath(row: lastRowIndex, section: lastSectionIndex), at: .bottom, animated: animated)
    }
    
    func addRow(animated : Bool) {
        self.beginUpdates()
        let lastSectionIndex = self.numberOfSections - 1 // last section
        let lastRowIndex = self.numberOfRows(inSection: lastSectionIndex) - 1 // last row
        self.insertRows(at: [IndexPath(row: lastRowIndex, section: lastSectionIndex)], with: .automatic)
        self.endUpdates()
        
        DispatchQueue.main.async {
            self.scrollToBottom(animated: animated)
        }
    }
    
    /* func scrollToBottom(animated : Bool) {
     //        let footerBounds = self.tableFooterView?.bounds
     //        let footerRectInTable = self.convert(footerBounds!, from: self.tableFooterView!)
     //        self.scrollRectToVisible(footerRectInTable, animated: animated)
     //        let y = contentSize.height - frame.size.height
     //        self.setContentOffset(CGPoint(x: 0, y: (y<0) ? 0 : y), animated: animated)
     
     }*/
    
    func scrollToBottom(animated: Bool = true) {
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height + 64)
        setContentOffset(bottomOffset, animated: animated)
    }
    
}

extension String
{
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedStringKey.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedStringKey.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }
    
    func sizeOfString(usingFont font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedStringKey.font: font]
        return self.size(withAttributes: fontAttributes)
    }
}



public class Reachability {
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        /* Only Working for WIFI
         let isReachable = flags == .reachable
         let needsConnection = flags == .connectionRequired
         
         return isReachable && !needsConnection
         */
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
        
    }
}
