//
//  SettingsView.swift
//  SideStoreUI
//
//  Created by Fabian Thies on 18.11.22.
//  Copyright © 2022 Fabian Thies. All rights reserved.
//

import SwiftUI
import AsyncImage
import SFSafeSymbols
import LocalConsole
import AltStoreCore
import Intents

struct SettingsView: View {
    
    var connectedAppleID: Team? {
        DatabaseManager.shared.activeTeam()
    }
    
    @SwiftUI.FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "%K == YES", #keyPath(Team.isActiveTeam)))
    var connectedTeams: FetchedResults<Team>
    
    
    @AppStorage("isBackgroundRefreshEnabled")
    var isBackgroundRefreshEnabled: Bool = true
    
    @State var isShowingConnectAppleIDView = false
    @State var isShowingAddShortcutView = false
    @State var isShowingFeedbackMailView = false
    @State var isShowingResetPairingFileConfirmation = false

    @State var externalURLToShow: URL?
    
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    
    var body: some View {
        List {
            Section {
                if let connectedAppleID = connectedTeams.first {
                    HStack {
                        Text(L10n.SettingsView.ConnectedAppleID.name)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(connectedAppleID.name)
                    }
                    
                    HStack {
                        Text(L10n.SettingsView.ConnectedAppleID.eMail)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(connectedAppleID.account.appleID)
                    }
                    
                    HStack {
                        Text(L10n.SettingsView.ConnectedAppleID.type)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(connectedAppleID.type.localizedDescription)
                    }
                } else {
                    SwiftUI.Button {
                        self.connectAppleID()
                    } label: {
                        Text(L10n.SettingsView.connectAppleID)
                    }
                }
            } header: {
                if !connectedTeams.isEmpty {
                    HStack {
                        Text(L10n.SettingsView.ConnectedAppleID.text)
                        Spacer()
                        SwiftUI.Button {
                            self.disconnectAppleID()
                        } label: {
                            Text(L10n.SettingsView.ConnectedAppleID.signOut)
                                .font(.callout)
                                .bold()
                        }
                    }
                }
            } footer: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.SettingsView.ConnectedAppleID.Footer.p1)
                    
                    Text(L10n.SettingsView.ConnectedAppleID.Footer.p2)
                }
            }
            
            Section {
                NavigationLink(L10n.AppIconsView.title) {
                    AppIconsView()
                }
            }
            
            Section {
                Toggle(isOn: self.$isBackgroundRefreshEnabled, label: {
                    Text(L10n.SettingsView.backgroundRefresh)
                })
                
                SwiftUI.Button {
                    self.isShowingAddShortcutView = true
                } label: {
                    Text(L10n.SettingsView.addToSiri)
                }
                .sheet(isPresented: self.$isShowingAddShortcutView) {
                    if let shortcut = INShortcut(intent: INInteraction.refreshAllApps().intent) {
                        SiriShortcutSetupView(shortcut: shortcut)
                    }
                }
            } header: {
                Text(L10n.SettingsView.refreshingApps)
            } footer: {
                Text(L10n.SettingsView.refreshingAppsFooter)
            }

            Section {
                SwiftUI.Button {
                    self.externalURLToShow = URL(string: "https://sidestore.io")!
                } label: {
                    HStack {
                        Text("Developers")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("SideStore Team")
                        Image(systemSymbol: .chevronRight)
                            .foregroundColor(.secondary)
                    }
                }
                .foregroundColor(.primary)

                SwiftUI.Button {
                    self.externalURLToShow = URL(string: "https://fabian-thies.de")!
                } label: {
                    HStack {
                        Text(L10n.SettingsView.swiftUIRedesign)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("fabianthdev")
                        Image(systemSymbol: .chevronRight)
                            .foregroundColor(.secondary)
                    }
                }
                .foregroundColor(.primary)

                NavigationLink {
                    LicensesView()
                } label: {
                    Text("Licenses")
                }

            } header: {
                Text(L10n.SettingsView.credits)
            }
            
            Section {
                NavigationLink("Show Error Log") {
                    ErrorLogView()
                }

                NavigationLink("Show Refresh Attempts") {
                    RefreshAttemptsView()
                }

                SwiftUI.Button("Toggle Console") {
                    LCManager.shared.isVisible.toggle()
                }

                if MailComposeView.canSendMail {
                    SwiftUI.Button("Send Feedback") {
                        self.isShowingFeedbackMailView = true
                    }
                    .sheet(isPresented: self.$isShowingFeedbackMailView) {
                        MailComposeView(recipients: ["support@sidestore.io"],
                                        subject: "SideStore Beta \(appVersion) Feedback") {
                            NotificationManager.shared.showNotification(title: "Thank you for your feedback!")
                        } onError: { error in
                            NotificationManager.shared.reportError(error: error)
                        }
                        .ignoresSafeArea()
                    }
                }

                SwiftUI.Button(L10n.SettingsView.switchToUIKit, action: self.switchToUIKit)

                SwiftUI.Button("Advanced Settings", action: self.showAdvancedSettings)

                SwiftUI.Button(L10n.SettingsView.resetImageCache, action: self.resetImageCache)
                    .foregroundColor(.red)

                SwiftUI.Button("Reset Pairing File") {
                    self.isShowingResetPairingFileConfirmation = true
                }
                .foregroundColor(.red)
                .actionSheet(isPresented: self.$isShowingResetPairingFileConfirmation) {
                    ActionSheet(title: Text("Are you sure to reset the pairing file?"), message: Text("You can reset the pairing file when you cannot sideload apps or enable JIT. SideStore will close when the file has been deleted."), buttons: [
                        .destructive(Text("Delete and Reset"), action: self.resetPairingFile),
                        .cancel()
                    ])
                }
            } header: {
                Text(L10n.SettingsView.debug)
            }

            
            Section {
                
            } footer: {
                Text("SideStore \(appVersion)")
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(L10n.SettingsView.title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                SwiftUI.Button {
                    
                } label: {
                    Image(systemSymbol: .personCropCircle)
                        .imageScale(.large)
                }

            }
        }
        .sheet(item: $externalURLToShow) { url in
            SafariView(url: url)
        }
    }
    
    
//    var appleIDSection: some View {
//
//    }
    
    
    
    func connectAppleID() {
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
            return
        }

        AppManager.shared.authenticate(presentingViewController: rootViewController) { (result) in
            DispatchQueue.main.async {
                switch result
                {
                case .failure(OperationError.cancelled):
                    // Ignore
                    break
                    
                case .failure(let error):
                    NotificationManager.shared.reportError(error: error)
                    
                case .success: break
                }
            }
        }
    }
    
    func disconnectAppleID() {
        DatabaseManager.shared.signOut { (error) in
            DispatchQueue.main.async {
                if let error = error
                {
                    NotificationManager.shared.reportError(error: error)
                }
            }
        }
    }
    
    func switchToUIKit() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let rootVC = storyboard.instantiateViewController(withIdentifier: "tabBarController") as! TabBarController
        
        UIApplication.shared.keyWindow?.rootViewController = rootVC
    }
    
    func resetImageCache() {
        do {
            let url = try FileManager.default.url(
                for: .cachesDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true)
            try FileManager.default.removeItem(at: url.appendingPathComponent("com.zeu.cache", isDirectory: true))
        } catch let error {
            fatalError("\(error)")
        }
    }

    func resetPairingFile() {
        let filename = "ALTPairingFile.mobiledevicepairing"
        let fileURL = FileManager.default.documentsDirectory.appendingPathComponent(filename)

        // Delete the pairing file if it exists
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(at: fileURL)
                print("Pairing file deleted successfully.")
            } catch {
                print("Failed to delete pairing file:", error)
            }
        }

        // Close and exit SideStore
        UIApplication.shared.perform(#selector(URLSessionTask.suspend))
        DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .milliseconds(500))) {
            exit(0)
        }
    }

    func showAdvancedSettings() {
        // Create the URL that deep links to our app's custom settings.
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        // Ask the system to open that URL.
        UIApplication.shared.open(url)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
    }
}

