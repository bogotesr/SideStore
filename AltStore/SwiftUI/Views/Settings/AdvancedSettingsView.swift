//
//  AdvancedSettingsView.swift
//  SideStore
//
//  Created by naturecodevoid on 2/19/23.
//  Copyright © 2023 SideStore. All rights reserved.
//

import SwiftUI
import minimuxer

private struct Server: Identifiable {
    var id: String { value }
    var display: String
    var value: String
}

struct AdvancedSettingsView: View {
    @ObservedObject private var iO = Inject.observer
    
    private let anisetteServers = [
        Server(display: "SideStore", value: "http://ani.sidestore.io:6969"),
        Server(display: "Macley (US)", value: "http://us1.sternserv.tech"),
        Server(display: "Macley (DE)", value: "http://de1.sternserv.tech"),
        Server(display: "DrPudding", value: "https://sign.rheaa.xyz"),
        Server(display: "Sideloadly", value: "https://sideloadly.io/anisette/irGb3Quww8zrhgqnzmrx"),
        Server(display: "Nick", value: "http://45.33.29.114"),
        Server(display: "Jawshoeadan", value: "https://anisette.jawshoeadan.me"),
        Server(display: "crystall1nedev", value: "https://anisette.crystall1ne.software/"),
    ]
    
    @AppStorage("textServer")
    var usePreferred: Bool = true
    
    @AppStorage("textInputAnisetteURL")
    var anisetteURL: String = ""
    
    @AppStorage("customAnisetteURL")
    var selectedAnisetteServer: String = ""
    
    @AppStorage("isDebugLoggingEnabled")
    var isDebugLoggingEnabled: Bool = false
    
    var body: some View {
        List {
            Section {
                Picker(L10n.AdvancedSettingsView.AnisetteSettings.server, selection: $selectedAnisetteServer) {
                    ForEach(anisetteServers) { server in
                        Text(server.display)
                    }
                }
                
                Toggle(L10n.AdvancedSettingsView.AnisetteSettings.usePreferred, isOn: $usePreferred)
                
                HStack {
                    Text(L10n.AdvancedSettingsView.AnisetteSettings.anisetteURL)
                    TextField("", text: $anisetteURL)
                        .autocapitalization(.none)
                        .autocorrectionDisabled(true)
                }
            } header: {
                Text(L10n.AdvancedSettingsView.anisetteSettings)
            } footer: {
                Text(L10n.AdvancedSettingsView.AnisetteSettings.footer)
            }
            
            Section {
                Toggle(L10n.AdvancedSettingsView.DangerZone.debugLogging, isOn: self.$isDebugLoggingEnabled)
                    .onChange(of: self.isDebugLoggingEnabled) { value in
                        UserDefaults.shared.isDebugLoggingEnabled = value
                        set_debug(value)
                    }
                
                #if UNSTABLE
                NavigationLink(L10n.UnstableFeaturesView.title) {
                    UnstableFeaturesView(inDevMode: false)
                }
                .foregroundColor(.red)
                #endif
            } header: {
                Text(L10n.AdvancedSettingsView.dangerZone)
            }
        }
        .navigationTitle(L10n.AdvancedSettingsView.title)
        .enableInjection()
    }
}

struct AdvancedSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedSettingsView()
    }
}
