//
//  SettingsView.swift
//  weisswein
//
//  Created by Phuc on 6/4/25.
//

import SwiftUI
import UIKit
import Foundation

struct SettingsView: View {
    @State private var soundEnabled = true
    @State private var darkModeEnabled = false
    @State private var showingFeedbackAlert = false
    
    @State private var showingFileImporter = false
    @State private var showingTypeSelection = false
    @State private var selectedFileType = ""
    
    @State private var importMessage: String? = nil
    @State private var showingImportSuccessAlert = false

    // Assuming the ViewModel tracks the number of correct answers and items
    @ObservedObject var senViewModel: SenViewModel
    @ObservedObject var nounViewModel: NounViewModel
    @ObservedObject var verbViewModel: VerbViewModel
    
    @State private var iOSVersion = ""
    @State private var deviceModel = ""
    
    @State private var lastUpdatedDate: Date? = nil
    
    var body: some View {
//        NavigationView {
            Form {
                Section(header: Text("System Info")) {
                    HStack {
                        Text("App Version")
                        Spacer()
                        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
                        Text(appVersion) // Replace with actual version if needed
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("Device Info")
                        Spacer()
                        let iOSVersion = UIDevice.current.systemVersion
                        let deviceModel = UIDevice.current.model
                        Text(deviceModel + " - " + iOSVersion) // Update with real device info
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("Last Updated")
                        Spacer()
                        Text(formattedDate(lastUpdatedDate))
                            .foregroundColor(.gray)
                    }
                }
                
                Section(header: Text("User Stats")) {
                    HStack {
                        Text("Correct Answers")
                        Spacer()
//                        Text("\(SentencePuzzleView().correct)") // Bind with the actual correct answers count from ViewModel
                    }
                    HStack {
                        Text("Sentences")
                        Spacer()
                        Text("\(senViewModel.correctCnt)") // Bind with actual sentences count from ViewModel
                    }
                    HStack {
                        Text("Verbs")
                        Spacer()
                        Text("\(verbViewModel.correctCnt)") // Bind with actual verbs count from ViewModel
                    }
                    HStack {
                        Text("Nouns")
                        Spacer()
                        Text("\(nounViewModel.correctCnt)") // Bind with actual nouns count from ViewModel
                    }
                }
                
                Section {
                    Button(action: {
                        showingTypeSelection = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down.on.square")
                            Text("Import CSV")
                        }
                    }
                }
                .confirmationDialog("Select File Type", isPresented: $showingTypeSelection, titleVisibility: .visible) {
                    Button("Verb") {
                        selectedFileType = "verbs"
                        showingFileImporter = true
                    }
                    Button("Sentence") {
                        selectedFileType = "GerSentences"
                        showingFileImporter = true
                    }
                    Button("Noun") {
                        selectedFileType = "nouns"
                        showingFileImporter = true
                    }
                    Button("Note") {
                        selectedFileType = "note"
                        showingFileImporter = true
                    }
                    Button("Cancel", role: .cancel) {}
                }
                .fileImporter(isPresented: $showingFileImporter, allowedContentTypes: [.commaSeparatedText]) { result in
                    do {
                        let selectedFile = try result.get()
                        let fileName = "\(selectedFileType).csv"  // Use the selected file type for the name

                        // Check if the Resource folder exists or create it if necessary
                        if let resourceFolderURL = Bundle.main.url(forResource: selectedFileType, withExtension: "csv") {
                            // Check if the file exists at the given path
                            if !FileManager.default.fileExists(atPath: resourceFolderURL.path) {
                                print("File does not exist at path: \(resourceFolderURL.path)")
                                return
                            }

                            // Overwrite the existing file at resourceFolderURL if it exists
                            if FileManager.default.fileExists(atPath: resourceFolderURL.path) {
                                do {
                                    try FileManager.default.removeItem(at: resourceFolderURL)
                                    // Proceed with copying the new file
                                } catch {
                                    print("Failed to remove the existing file: \(error)")
                                }
                            }

                            // Copy the new file to the Resource folder
                            try FileManager.default.copyItem(at: selectedFile, to: resourceFolderURL)
                            switch selectedFileType {
                            case "verbs":
                                verbViewModel.loadCSV()
                            case "GerSentences":
                                senViewModel.loadCSV()
                            case "nouns":
                                nounViewModel.loadCSV()
                            default:
                                print("No ViewModel found for selected file type.")
                            }
                            print("\(fileName) imported successfully to Resource/ and overwritten!")
                            importMessage = "\(fileName) imported successfully!"
                            showingImportSuccessAlert = true
                            lastUpdatedDate = Date()
                        } else {
                            print("Resource folder URL is invalid.")
                        }
                    } catch {
                        print("Failed to import file: \(error)")
                    }
                }
                .alert(isPresented: $showingImportSuccessAlert) {
                    Alert(title: Text("Import Complete"), message: Text(importMessage ?? "Success"), dismissButton: .default(Text("OK")))
                }
                
                Section {
                    Button(action: {
                        showingFeedbackAlert = true
                    }) {
                        HStack {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                            Text("Send Feedback")
                        }
                    }
                    .alert(isPresented: $showingFeedbackAlert) {
                        Alert(title: Text("Feedback"),
                              message: Text("Thank you for using our app!"),
                              dismissButton: .default(Text("OK")))
                    }
                    
                    Button(action: {
                        // Add logic to reset stats or settings
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise.circle.fill")
                            Text("Reset Progress")
                        }
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationBarTitle("Settings", displayMode: .inline)
            .onAppear {
                if UserDefaults.standard.object(forKey: "lastUpdatedDate") == nil {
                    let now = Date()
                    UserDefaults.standard.set(now, forKey: "lastUpdatedDate")
                    lastUpdatedDate = now
                } else {
                    lastUpdatedDate = UserDefaults.standard.object(forKey: "lastUpdatedDate") as? Date
                }
            }
        }
//    }
    
    func getDeviceModel() {
        iOSVersion = UIDevice.current.systemVersion
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0) ?? "Unknown"
            }
        }
        deviceModel = modelCode
    }
    
    func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "Not available" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(senViewModel: SenViewModel(), nounViewModel: NounViewModel(), verbViewModel: VerbViewModel())
    }
}
