//
//  FreeHomeView.swift
//  Quotes
//
//  Created by Alon Rozmarin on 24/10/2023.
//

import SwiftUI

struct FreeHomeView: View {
    @State var showProAlert = false
    @ObservedObject var viewModel = TextPostViewModel()

    @State var showProAlertForNotifications = false

    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        Post()
                            .aspectRatio(contentMode: .fit)
                            .containerRelativeFrame(.vertical, count: 1, span: 1, spacing: 0)
                        Post()
                            .aspectRatio(contentMode: .fit)
                            .containerRelativeFrame(.vertical, count: 1, span: 1, spacing: 0)
                        Post()
                            .aspectRatio(contentMode: .fit)
                            .containerRelativeFrame(.vertical, count: 1, span: 1, spacing: 0)
                        Post()
                            .aspectRatio(contentMode: .fit)
                            .containerRelativeFrame(.vertical, count: 1, span: 1, spacing: 0)
                        Post()
                            .aspectRatio(contentMode: .fit)
                            .containerRelativeFrame(.vertical, count: 1, span: 1, spacing: 0)

                        VStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 15, style: .continuous)
                                    .frame(width: 355, height: 330)
                                    .foregroundColor(Color("QuotesBackgroundColor"))
                                
                                Text("You have reached your daily limit!")
                                    .foregroundColor(Color("TextColor"))
                                    .font(.system(size: 22, weight: .bold))
                                    .multilineTextAlignment(.center)
                                    .frame(width: 345, height: 340)
                                
                                VStack {
                                    HStack {
                                        Spacer()
                                        Text("👑")
                                            .font(.system(size: 28, weight: .bold))
                                    }
                                    Spacer()
                                }
                                .frame(width: 335, height: 315)
                            }
                            .aspectRatio(contentMode: .fit)
                            .containerRelativeFrame(.vertical, count: 1, span: 1, spacing: 0)
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
                    HStack {
                        Spacer()
                        NavigationLink(destination: Text("Hi")) {
                            Image(systemName: "crown")
                                .foregroundColor(Color("TextColor"))
                                .padding(12)
                                .background(Color("ButtonColor"), in: RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding()

                    Spacer()
                    HStack {
                        Button {
                            showProAlertForNotifications.toggle()
                        } label: {
                            Text("Notifications")
                                .foregroundColor(Color("TextColor"))
                                .frame(width: 100, height: 25)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color("ButtonColor"))
                        .buttonBorderShape(.roundedRectangle(radius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12) .stroke(.thinMaterial, lineWidth: 2))

                        Spacer()

                        NavigationLink(destination: TagsView(isProVersion: false)) {
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
        .alert(isPresented: $showProAlertForNotifications, content: {
            Alert(title: Text("Oops this is a pro exclusive feature."), message: Text("Get pro and you get it"), dismissButton: .default(Text("Ok")))
        })
    }

    private func isLastPost(_ post: QuotePost) -> Bool {
        if let lastPost = viewModel.quotePosts.last {
            return post.id == lastPost.id
        }
        return false
    }
}

#Preview {
    FreeHomeView()
}
