//
//  ContentModel.swift
//  MoonShot
//
//  Created by HubertMac on 08/04/2024.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth


class ContentModel: ObservableObject {
    
    //Authentication
    @Published var loggedIn = false
    
    let db = Firestore.firestore()
    
    //List of modules
    @Published var modules = [Module]()
    
    //Current module
    @Published var currentModule: Module?
    var currentModuleIndex = 0
    
    //Current lesson
    @Published  var currentLesson: Lesson?
    var currentLessonIndex = 0
    
    //Current question
    @Published var currentQuestion: Question?
    var currentQuestionIndex = 0
    
    //Current lesson explanation
    @Published var codeText = NSAttributedString()
    
    //Current selected content and test
    @Published var currentContentSelected: Int?
    @Published var currentTestSelected: Int?
    
    var styleData: Data?
    
    init() {
        
        
    }
    
    //MARK: = Authentication methods
    
    func checkLogin() {
        
        // Check if there's a current user to determine logged in status
        loggedIn = Auth.auth().currentUser != nil ? true : false
        
        // Check if user meta data has been fetched. If the user was already logged in from a previous session, we need to get their data in a separate call
        if UserService.shared.user.name == "" {
            getUserData()
        }
        
    }
    
    //MARK: - Data methods
    
    func saveData(writeToDataBase: Bool = false) {
        
        if let loggedInUser = Auth.auth().currentUser {
            
            // Save the progress data locally
            let user = UserService.shared.user
            
            user.lastModule = self.currentModuleIndex
            user.lastLesson = self.currentLessonIndex
            user.lastQuestion = self.currentQuestionIndex
            
            
            if writeToDataBase {
                //Save it to the database
                let db = Firestore.firestore()
                let ref = db.collection("users").document(loggedInUser.uid)
                ref.setData(["lastModule": user.lastModule ?? NSNull() ,
                             "lastLesson": user.lastLesson ?? NSNull(),
                             "lastQuestion": user.lastQuestion ?? NSNull()],
                            merge: true)
            }
        }
        
        
    }
    

    func getUserData() {
        
        // Check that there's a logged in user
        guard Auth.auth().currentUser != nil else {
            return
        }
        
        // Get the meta data for that user
        let db  = Firestore.firestore()
        let ref = db.collection("users").document(Auth.auth().currentUser!.uid)
        ref.getDocument { snapshot, error in
            
            guard error == nil, snapshot != nil else {
                return
            }
            
            // Pharse the data out and set the user meta data
            let data = snapshot!.data()
            let user = UserService.shared.user
            
            user.name = data?["name"] as? String ?? ""
            user.lastModule = data?["lastModule"] as? Int
            user.lastLesson = data?["lastLesson"] as? Int
            user.lastQuestion = data?["lastQuestion"] as? Int
            
        }
    }
    
    
    func getLessons(module: Module, completion: @escaping () -> Void) {
        
        
        // Specify path
        let collection = db.collection("modules").document(module.id).collection("lessons")
        
        // Get documents
        collection.getDocuments { snapshot, error in
            
            //Check for errors and if there is a data
            if error == nil && snapshot != nil {
                
                // Array to track lessons
                var lessons = [Lesson]()
                
                // Loop through the documents and build array of lessons
                for doc in snapshot!.documents {
                    
                    // Create a new lesson
                    var l = Lesson()
                    l.id = doc["id"] as? String ?? UUID().uuidString
                    l.title = doc["title"] as? String ?? ""
                    l.video = doc["video"] as? String ?? ""
                    l.duration = doc["duration"] as? String ?? ""
                    l.explanation = doc["explanation"] as? String ?? ""
                    
                    // Add the lesson into the array
                    lessons.append(l)
                    // Loop through published modules array and find the one that matches the id orf the copy that got passed in
                    for (index, m) in self.modules.enumerated() {
                        
                        // Find the module we want
                        if m.id  == module.id {
                            
                            // Set the lessons
                            self.modules[index].content.lessons = lessons
                            
                            // Call completion closure
                            completion()
                        }
                    }
                }
            }
        }
    }
    
    func getQuestions(module:Module, completion: @escaping () -> Void) {
        
        // Specify path
        let collection = db.collection("modules").document(module.id).collection("questions")
        
        // Get documents
        collection.getDocuments { snapshot, error in
            
            //Check for errors and if there is a data
            if error == nil && snapshot != nil {
                
                // Array to track questions
                var questions = [Question]()
                
                // Loop through the documents and build array of lessons
                for doc in snapshot!.documents {
                    
                    // Create a new lesson
                    var q = Question()
                    q.id = doc["id"] as? String ?? UUID().uuidString
                    q.content = doc["content"] as? String ?? ""
                    q.correctIndex = doc["correctIndex"] as? Int ?? 0
                    q.answers = doc["answers"] as? [String] ?? [String]()
                    
                    
                    // Add the question into the array
                    questions.append(q)
                    // Loop through published modules array and find the one that matches the id orf the copy that got passed in
                    for (index, m) in self.modules.enumerated() {
                        
                        // Find the module we want
                        if m.id  == module.id {
                            
                            // Set the lessons
                            self.modules[index].test.questions = questions
                            
                            // Call completion closure
                            completion()
                        }
                    }
                }
            }
        }
    }
    
    
    func getDataBaseData() {
        
        // Parse local style.html
        getLocalStyles()
        
        // Get reference to the collection
        let collection = db.collection("modules")
        
        // Get documents
        
        collection.getDocuments { snapshot, error in
            
            if error == nil && snapshot != nil {
                
                // Create an array fot the modules
                var modules = [Module]()
                
                //Loop through the documents
                for doc in snapshot!.documents {
                
                    
                    // Create a new module instance
                    var m = Module()
                    
                    // PArse out the values from the document into the module instance
                    m.id = doc["id"] as? String ?? UUID().uuidString
                    m.category = doc["category"] as? String ?? ""
                    
                    //Parse the lesson content
                    let contentMap = doc["content"] as! [String:Any]
                    
                    m.content.description = contentMap["description"] as? String ?? ""
                    m.content.id = contentMap["id"] as? String ?? ""
                    m.content.image = contentMap["image"] as? String ?? ""
                    m.content.time = contentMap["time"] as? String ?? ""
                    
                    //Parse the test content
                    let testMap = doc["test"] as! [String:Any]
                    
                    m.test.id = testMap["id"] as? String ?? ""
                    m.test.description =  testMap["description"] as? String ?? ""
                    m.test.image = testMap["image"] as? String ?? ""
                    m.test.time = testMap["time"] as? String ?? ""
                    
                    // Add it to our array
                    modules.append(m)
                }
                
                // Assign our modules to the published property
                DispatchQueue.main.async {
                    
                    self.modules = modules
                }
            }
        }
        
        
    }
    
    func getLocalStyles() {
        /*
        //get url to the json file
        let jsonUrl = Bundle.main.url(forResource: "data", withExtension: "json")
        
        do {
            // Read the file into a data object
            let jsonData = try Data(contentsOf: jsonUrl!)
            
            // Try to decode json file into an array of modules
            let jsonDecoder = JSONDecoder()
            let modules = try jsonDecoder.decode([Module].self, from: jsonData)
            
            //Assing  parsed modules to modules property
            DispatchQueue.main.async {
                self.modules = modules
            }
            
        
        }
        catch {
            print("Couldn't parse local data")
        }*/
        
        //Parse the style data
        
        let styleUrl = Bundle.main.url(forResource: "style", withExtension: "html")
        
        do {
            //Read the file into the data object
            let styleData = try Data(contentsOf: styleUrl!)
            
            self.styleData = styleData
            
        }
        catch {
            print("Couldn't parse style data")
        }
    }
    
    func getRemoteData () {
        
        //String path
        let urlString = "https://bashubb.github.io/learningapp-data/data2.json"
        
        // Create url object
        let url = URL(string: urlString)
        
        guard  url != nil else {
            //Couldn't create url
            return
        }
        
        // Create a URLRequest object
        let request = URLRequest(url: url!)
        
        // Get the session and kick of the task
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: request) { data, response, error in
            
            //Check if there's an error
            guard error == nil else {
                // There is no error
                return
            }
            
            do {
                // Create json decoder
                let decoder = JSONDecoder()
                
                // Decode
                let modules = try decoder.decode([Module].self, from: data!)
                
                DispatchQueue.main.async {
                    // Apend parsed modules into modules property
                    self.modules += modules
                }
            }
            catch {
                //Couldn't decode a json
            }
        }
        
        // Kick off data task
        dataTask.resume()
    }
    
    //MARK: Module navigation methods
    
    func beginModule(_ moduleId:String) {
        
        //Find the index for this module id
        for index in 0..<modules.count {
            if modules[index].id  == moduleId {
                
                //Found the matching module
                self.currentModuleIndex = index
                break
            }
        }
        
        //Set the current module
        self.currentModule = modules[currentModuleIndex]
    }
    
    
    func beginLesson(_ lessonIndex: Int) {
        
        //Reset the questionIndex since the user is starting lessons now
        currentQuestionIndex = 0
        
        //Check that the lesson index is within range of module lessons
        if lessonIndex < currentModule!.content.lessons.count {
            currentLessonIndex =  lessonIndex
        }
        else {
            currentLessonIndex = 0
        }
        currentLesson = currentModule!.content.lessons[currentLessonIndex]
        codeText = addStylig(currentLesson!.explanation)
    }
    
    
    
    func nextLesson() {
        
        //Advance the lesson
        currentLessonIndex += 1
        
        // Check that it is within range
        if currentLessonIndex < currentModule!.content.lessons.count {
            
            // Set the current lesson property
            currentLesson =  currentModule!.content.lessons[currentLessonIndex]
            codeText = addStylig(currentLesson!.explanation)
        }
        else {
            currentLessonIndex = 0
            currentLesson = nil
        }
      
        // Save the progress
        
        saveData()
    }
    
    
    
    func hasNextLesson() -> Bool {
        
        guard currentModule != nil else {
            return false
        }
        
        return (currentLessonIndex + 1 < currentModule!.content.lessons.count)
    }
    
    
    func beginTest(_ moduleId: String) {
        
        //Set the current module
        beginModule(moduleId)
        
        //Set the current question
        currentQuestionIndex = 0
        
        // Reset the lesson index since user starting a test now
        
        currentLessonIndex = 0
        
        //If there are questions, set the current question to the first one
        if currentModule?.test.questions.count ?? 0 > 0 {
            currentQuestion = currentModule!.test.questions[currentQuestionIndex]
            
            //Set the question content
            codeText = addStylig(currentQuestion!.content)
        }
    }
    
    
    func nextQuestion () {
        
        // Advance the question index
        currentQuestionIndex += 1
        
        // Check if that it's whitin the range of questions
        if currentQuestionIndex < currentModule!.test.questions.count {
            
            // Set the current question
            currentQuestion = currentModule!.test.questions[currentQuestionIndex]
            codeText = addStylig(currentQuestion!.content)
        }
        else {
            // If not, then reset the properties
            currentQuestionIndex = 0
            currentQuestion = nil
        }
        
        // Save the progress
        saveData()
        
    }
    
    //MARK: Code styling
    
    private func addStylig(_ htmlString: String) -> NSAttributedString {
        
        var resultString = NSAttributedString()
        var data = Data()
        
        //Add the styling data
        if styleData != nil {
            data.append(self.styleData!)
        }
        
        //Add the html data
        data.append(Data(htmlString.utf8))
        
        //Technique 1 - doesn't catch the error, just skip the execution block of code
        if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil) {
            
            resultString = attributedString
        }
        
        //Technique 2
        //Convert to attributed string - catches error
//        do {
//
//            let attributedString = try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html],
//                documentAttributes: nil)
//
//            resultString = attributedString
//        }
//        catch {
//            print("Couldn't turn html into attributed string")
//        }
        
        return resultString
    }
    
}
