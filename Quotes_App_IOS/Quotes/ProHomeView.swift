//
//  ProHomeView.swift
//  Quotes
//
//  Created by Alon Rozmarin on 24/10/2023.
//

import SwiftUI

struct ProHomeView: View {
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
                    Spacer()
                    HStack {
                        Button {
                            if shouldSend {
                                shouldSend.toggle()
                                UserDefaults.standard.set(shouldSend, forKey: "shouldSendNotifications")
                            } else {
                                shouldSend.toggle()
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

                        NavigationLink(destination: TagsView(isProVersion: true)) {
                            Image(systemName: "tag")
                                .foregroundColor(Color("TextColor"))
                                .padding(12)
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

#Preview {
    ProHomeView()
}
