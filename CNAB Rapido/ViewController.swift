//
//  ViewController.swift
//  CNAB Rapido
//
//  Created by Rafael Lima on 6/4/15.
//  Copyright (c) 2015 br.com.boletosimples. All rights reserved.
//

import Cocoa
//import AppKit

class ViewController: NSViewController {

    @IBOutlet weak var monitoringPath: NSTextField!
    @IBOutlet weak var apiToken: NSTextField!
    @IBOutlet weak var tokenLink: NSButton!
    @IBOutlet weak var tokenButton: NSButton!
    @IBOutlet weak var tokenMessage: NSTextField!
    var choosenDirectoryPath: String!
    var returnFiles: [NSURL]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preferencesLoaded()
        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func choosePath(sender: AnyObject) {
        let directoryPicker: NSOpenPanel = NSOpenPanel()
        directoryPicker.allowsMultipleSelection = false
        directoryPicker.canChooseDirectories = true
        directoryPicker.canChooseFiles = false
        directoryPicker.runModal()
        chooseDirectory(directoryPicker.URL!)
    }
    
    @IBAction func validateOrChangeToken(sender: AnyObject) {
        tokenMessage.hidden = true
        if(tokenButton.title == "Validar") {
            if(apiToken.stringValue == "") {
                tokenMessage.stringValue = "Preencha o Token!"
                tokenMessage.textColor = NSColor.redColor()
                tokenMessage.hidden = false
            }
            else {
                if(validateToken()) {
                    NSUserDefaults.standardUserDefaults().setObject(apiToken.stringValue, forKey: "apiToken")
                    apiToken.enabled = false
                    tokenMessage.stringValue = "Token validado com sucesso!"
                    tokenMessage.textColor = NSColor.greenColor()
                    tokenMessage.hidden = false
                    tokenButton.title = "Trocar"
                }
                else {
                    tokenMessage.stringValue = "Token inválido!"
                    tokenMessage.textColor = NSColor.redColor()
                    tokenMessage.hidden = false
                }
            }
        }
        else {
            apiToken.stringValue = ""
            apiToken.enabled = true
            apiToken.becomeFirstResponder()
            tokenButton.title = "Validar"
        }
    }
    
    func validateToken() -> Bool {
        var client = SimpleRestClient(apiUrl: "https://sandbox.boletosimples.com.br/api/v1/")
        client.call("GET", route: "userinfo") {
            (data, urlResponse, error) in
            var dataString = NSString(data: data, encoding:NSUTF8StringEncoding)
            
            println("dataString = \(dataString!)")
        }
        return true;
    }
    
    @IBAction func openTokenWebPage(sender: AnyObject) {
        let urlString = NSURL(string: "https://sandbox.boletosimples.com.br/conta/api/tokens")
        NSWorkspace.sharedWorkspace().openURL(urlString!)
    }
    
    func chooseDirectory(choosenDirectory: NSURL?) {
        if(choosenDirectory != nil) {
            NSUserDefaults.standardUserDefaults().setObject(choosenDirectory!.path!, forKey: "choosenDirectoryPath")
            println("ESCOLHIDO: " + choosenDirectory!.path! + "\n")
            preferencesLoaded()
        }
    }
    
    func preferencesLoaded() {
        monitoringPath.enabled = false
        choosenDirectoryPath = NSUserDefaults.standardUserDefaults().objectForKey("choosenDirectoryPath") as? String
        if(choosenDirectoryPath == nil) {
            // Define um valor padrão
        }
        else {
            monitoringPath.stringValue = choosenDirectoryPath
            detectFiles()
        }
        var apiTokenString = NSUserDefaults.standardUserDefaults().objectForKey("apiToken") as? String
        if(apiTokenString != nil && !apiTokenString!.isEmpty) {
            apiToken.enabled = false
            apiToken.stringValue = apiTokenString!
            tokenButton.title = "Trocar"
        }
    }
    
    func detectFiles() {
        let defaultFileManager: NSFileManager = NSFileManager()
        defaultFileManager.changeCurrentDirectoryPath(choosenDirectoryPath)
        if let filePaths = defaultFileManager.contentsOfDirectoryAtPath(choosenDirectoryPath, error: nil) {
            for filePath in filePaths {
                var file = NSURL(string: filePath as! String)
                if(file != nil) { processFile(file!); }
            }
        }
        
    }
    
    func processFile(file: NSURL) {
        if !fileIsRetorno(file) { return; }
//        returnFiles.append(file);
        println("ARQUIVO: " + file.lastPathComponent! + "\n")
    }
    
    func fileIsRetorno(file: NSURL) -> Bool {
        if(file.pathExtension != "ret") { return false; }
        
        let content = String(contentsOfFile: file.path!, encoding: NSUTF8StringEncoding, error: nil)
        
        if(content == nil) { return false; }
        if(content!.hasPrefix("02RETORNO") != true) { return false; }
        return true;
    }

    
}

