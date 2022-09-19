//
//  ServerURLsSettingsView.swift
//  Amperfy
//
//  Created by Maximilian Bauer on 15.09.22.
//  Copyright (c) 2022 Maximilian Bauer. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//


import SwiftUI
import AmperfyKit

struct ServerURLsSettingsView: View {
    
    @State var serverURLs = [String]()
    @State var activeServerURL: String =  ""
    @State var isAddDialogVisible: Bool = false
    
    func reload() {
        serverURLs = appDelegate.storage.alternativeServerURLs
        activeServerURL = appDelegate.storage.loginCredentials?.serverUrl ?? ""
        serverURLs.append(activeServerURL)
    }
    
    func setAsActiveURL(url: String) {
        guard url != activeServerURL else { return }
        if let altIndex = self.appDelegate.storage.alternativeServerURLs.firstIndex(of: url),
           let currentCredentials = self.appDelegate.storage.loginCredentials {
            var altURLs = self.appDelegate.storage.alternativeServerURLs
            altURLs.remove(at: altIndex)
            altURLs.append(currentCredentials.serverUrl)
            self.appDelegate.storage.alternativeServerURLs = altURLs
            
            let newCredentials = LoginCredentials(serverUrl: url, username: currentCredentials.username, password: currentCredentials.password, backendApi: currentCredentials.backendApi)
            self.appDelegate.storage.loginCredentials = newCredentials
            self.appDelegate.backendApi.provideCredentials(credentials: newCredentials)
        }
        reload()
    }
    
    func deleteURL(url: String) {
        guard url != activeServerURL else { return }
        if let altIndex = self.appDelegate.storage.alternativeServerURLs.firstIndex(of: url) {
            var altURLs = self.appDelegate.storage.alternativeServerURLs
            altURLs.remove(at: altIndex)
            self.appDelegate.storage.alternativeServerURLs = altURLs
        }
    }
    
    var body: some View {
        ZStack{
            List {
                ForEach(serverURLs, id: \.self) { url in
                    HStack {
                        Text(url)
                        Spacer()
                        if url == activeServerURL {
                            Image.checkmark
                        }
                    }
                    .deleteDisabled(url == activeServerURL)
                    .onTapGesture {
                        setAsActiveURL(url: url)
                    }
                }
                .onDelete { indexSet in
                    guard let index = indexSet.first else { return }
                    deleteURL(url: serverURLs[index])
                    serverURLs.remove(atOffsets: indexSet)
                }
            }
        }
        .navigationTitle("Sever URLs")
        .sheet(isPresented: $isAddDialogVisible) {
            AlternativeURLAddDialogView(isVisible: $isAddDialogVisible, activeServerURL: $activeServerURL, serverURLs: $serverURLs)
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                EditButton()
                Button(action: {
                    withPopupAnimation { isAddDialogVisible = true }
                }) {
                    Image.plus
                }
            }
        }
        .onAppear {
            reload()
        }
    }
}

struct ServerURLsSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ServerURLsSettingsView()
    }
}
