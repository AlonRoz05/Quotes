import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel = TextPostViewModel()
    @State var shouldSendNotifications = UserDefaults.standard.bool(forKey: "shouldSendNotifications")
    let isPro: Bool

    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        Post(pro: isPro)
                            .aspectRatio(contentMode: .fit)
                            .containerRelativeFrame(.vertical, count: 1, span: 1, spacing: 0)

                        ForEach(viewModel.quotePosts) { qoutePost in
                            Post(pro: isPro)
                                .aspectRatio(contentMode: .fit)
                                .containerRelativeFrame(.vertical, count: 1, span: 1, spacing: 0)
                                .onAppear {
                                    if self.isLastPost(qoutePost) {
                                        self.viewModel.fetchNextPage()
                                    }
                                }
                        }
                    }
                    
                    VStack {
                        Button {
                            self.viewModel.fetchNextPage()
                        } label: {
                            Text("Load More")
                                .foregroundColor(Color("TextColor"))
                        }
                        .aspectRatio(contentMode: .fit)
                        .containerRelativeFrame(.vertical, count: 1, span: 1, spacing: 0)
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.roundedRectangle(radius: 8))
                        .tint(.gray)
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.paging)
                .ignoresSafeArea()
                .onAppear {
                    self.viewModel.fetchNextPage()
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
    HomeView(isPro: true)
}
