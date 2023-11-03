//
//  ContentView.swift
//  Quotes
//
//  Created by Alon Rozmarin on 28/09/2023.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var networkManager = NetworkManager()

    @State var shouldSend = UserDefaults.standard.bool(forKey: "shouldSendNotifications")
    @AppStorage("_shouldShowOnBoarding") var shouldShowOnBoarding: Bool = true

    @State var isPro = true

    let notify = NotificationHandler()

    @State private var isSplashActive = true
    @State private var splashLogoSize = 1.0
    @State private var splashLogoOpacity = 0.6

    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .edgesIgnoringSafeArea(.all)

            if isSplashActive {
                VStack {
                    Image("AppIconForSplash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 170, height: 170)
                }
                .scaleEffect(splashLogoSize)
                .opacity(splashLogoOpacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.3)) {
                        self.splashLogoSize = 0.8
                        self.splashLogoOpacity = 0.0
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.45) {
                        withAnimation(Animation.easeIn(duration: 0.6)) {
                            self.isSplashActive = false
                        }
                    }
                }
            }
            else {
                if !networkManager.isConnected {
                    ZStack {
                        Color("BackgroundColor")
                            .edgesIgnoringSafeArea(.all)
                        
                        VStack {
                            Image(systemName: "wifi.slash")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                                .padding()
                            Text("It looks like you're not connected to the internet").bold()
                            if !networkManager.isConnected {
                                Button {
                                    print("Hi")
                                } label: {
                                    Text("Retry")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color("TextColor"))
                                        .multilineTextAlignment(.center)
                                        .frame(width: 80, height: 35)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(Color("ButtonColor"))
                                .buttonBorderShape(.roundedRectangle(radius: 12))
                                .padding()
                            }
                        }
                    }
                } else {
                    if isPro {
                        ProHomeView()
                        // fix notifications
                    } else {
                        FreeHomeView()
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $shouldShowOnBoarding) {
            OnboardingView(shouldShowOnBoarding: $shouldShowOnBoarding)
        }
    }
}

class TextPostViewModel: ObservableObject {
    @Published var quotePosts: [QuotePost] = []
    private var currentPage = 0
    private let postsPerPage = 10

    func fetchNextPage() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            let newQuotePost = (1...self.postsPerPage).map { _ in
                QuotePost()
            }

            DispatchQueue.main.async {
                self.quotePosts.append(contentsOf: newQuotePost)
                self.currentPage += 1
            }
        }
    }
}

struct QuotePost: Identifiable {
    let id = UUID()
}

#Preview {
    ContentView()
}
