//
//  ContentView.swift
//  Quotes
//
//  Created by Alon Rozmarin on 28/09/2023.
//

import SwiftUI

struct ContentView: View {
    @State var quote: GetModelsQuote?

    let notify = NotificationHandler()
    var shouldSend = UserDefaults.standard.bool(forKey: "shouldSendNotifications")

    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .edgesIgnoringSafeArea(.all)

            HomeView()
        }
        .onAppear {
            notify.askPremmision()
        }
        .task {
            if shouldSend {
                do {
                    quote = try await getQuote()
                    notify.sendNotification(quote: quote?.quote ?? "Check out today's quotes!", hour: 19, minute: 55)
                } catch {}
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
                    LazyVStack() {
                        ForEach(viewModel.quotePosts) { qoutePost in
                            Post()
                                .aspectRatio(contentMode: .fit)
                                .containerRelativeFrame(.vertical, count: 1, span: 1, spacing: 0)
                                .scrollTransition { content, phase in content .opacity(phase.isIdentity ? 1.0 : 0)}
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
