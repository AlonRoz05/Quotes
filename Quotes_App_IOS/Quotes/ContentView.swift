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
    @AppStorage("_gotAccessForNotifications") var gotAccessForNotifications: Bool = true

    @State var quote: GetModelsQuote?

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
                    VStack {
                        Image("AppIconForSplash")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .font(.system(size: 80))
                            .foregroundColor(Color("TextColor"))
                    }
                    .scaleEffect(splashLogoSize)
                    .opacity(splashLogoOpacity)
                    .onAppear {
                        withAnimation(.easeIn(duration: 2)) {
                            self.splashLogoSize = 0.8
                            self.splashLogoOpacity = 0.0
                        }
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation(Animation.easeIn(duration: 0.6)) {
                            self.isSplashActive = false
                        }
                    }
                }
            }
            else {
                if networkManager.isConnected {
                    HomeView()
                        .task {
                            if shouldSend {
                                let canSend = notify.askPremmision()
                                    if canSend {
                                    do {
                                        quote = try await getQuote()
                                        notify.sendNotification(quote: quote?.quote ?? "Check out today's quotes!", hour: 9, minute: 0)
                                    } catch {}
                                    do {
                                        quote = try await getQuote()
                                        notify.sendNotification(quote: quote?.quote ?? "Check out today's quotes!", hour: 15, minute: 0)
                                    } catch {}
                                    do {
                                        quote = try await getQuote()
                                        notify.sendNotification(quote: quote?.quote ?? "Check out today's quotes!", hour: 21, minute: 0)
                                    } catch {}
                                }
                            }
                        }
                } else {
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
                }
            }
        }
        .fullScreenCover(isPresented: $shouldShowOnBoarding) {
            OnboardingView(shouldShowOnBoarding: $shouldShowOnBoarding)
        }
    }
}

struct HomeView: View {
    @ObservedObject var viewModel = TextPostViewModel()
    @State var shouldSend = UserDefaults.standard.bool(forKey: "shouldSendNotifications")

    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.quotePosts) { qoutePost in
                            Post()
                                .aspectRatio(contentMode: .fit)
                                .containerRelativeFrame(.vertical, count: 1, span: 1, spacing: 0)
                                .onAppear {
                                    if self.isLastPost(qoutePost) {
                                        self.viewModel.fetchNextPage()
                                    }
                                }
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.paging)
                .ignoresSafeArea()
                .onAppear {
                    self.viewModel.fetchNextPage()
                }

                VStack {
                    HStack{
                        Spacer()
                        NavigationLink(destination: TagsView()) {
                            Image(systemName: "crown")
                                .foregroundColor(Color("TextColor"))
                                .padding(.top, 12)
                                .padding(.bottom, 12)
                                .padding(.horizontal, 12)
                                .background(Color("ButtonColor"), in: RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding()
                    Spacer()
                    HStack {
                        Button {
                            if shouldSend {
                                shouldSend = false
                                UserDefaults.standard.set(shouldSend, forKey: "shouldSendNotifications")
                            } else {
                                shouldSend = true
                                UserDefaults.standard.set(shouldSend, forKey: "shouldSendNotifications")
                            }
                        } label: {
                            Text("Notifications")
                                .foregroundColor(Color("TextColor"))
                                .frame(width: 100, height: 25)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color("ButtonColor"))
                        .buttonBorderShape(.roundedRectangle(radius: 12))
                        .overlay(shouldSend ? RoundedRectangle(cornerRadius: 12) .stroke(.mint, lineWidth: 2) : nil)
                        .animation(Animation.default, value: UUID())

                        Spacer()

                        NavigationLink(destination: TagsView()) {
                            Image(systemName: "tag")
                                .foregroundColor(Color("TextColor"))
                                .padding(.top, 12)
                                .padding(.bottom, 12)
                                .padding(.horizontal, 12)
                                .background(Color("ButtonColor"), in: RoundedRectangle(cornerRadius: 12))
                        }

                    }
                    .padding()
                }
            }
        }
    }

    private func isLastPost(_ post: QuotePost) -> Bool {
        if let lastPost = viewModel.quotePosts.last {
            return post.id == lastPost.id
        }
        return false
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
