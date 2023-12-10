import SwiftUI

enum ViewState: Int {
    case home = 0
    case tags
    case likes
}

struct ContentView: View {
    @ObservedObject var networkManager = NetworkManager()
    
    @State var shouldSendNotifications = UserDefaults.standard.bool(forKey: "shouldSendNotifications")
    
    @AppStorage("_shouldShowOnBoarding") var shouldShowOnBoarding: Bool = true
    
    @State private var isSplashActive = true
    @State private var splashLogoSize = 1.0
    @State private var splashLogoOpacity = 0.6
    
    @State var currentViewState: ViewState = .home
    
    @State var viewNum: Int = 0
    
    @State var havePro = true
    
    @State var colorForLikesText = Color.gray
    @State var colorForHomeText = Color("TextColor")
    
    @State private var showingSettingsSheet = false
    
    var body: some View {
        ZStack {
            Color.black
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
                    NoInternetView()
                } else {
                    ZStack {
                        ZStack {
                            switch viewNum {
                            case 0:
                                HomeView(isPro: havePro)
                            case 1:
                                if havePro {
                                    TagsHomeViewPro()
                                } else {
                                    TagsHomeViewFree()
                                }
                            case 2:
                                likedQuotesView(isPro: havePro)
                            default:
                                HomeView(isPro: havePro)
                            }
                        }
                        VStack {
                            ZStack {
                                HStack {
                                    Spacer()
                                    
                                    Button {
                                        withAnimation(.spring()) {
                                            viewNum = 2
                                            currentViewState = .likes
                                            colorForLikesText = Color("TextColor")
                                            colorForHomeText = Color.gray
                                        }
                                    } label: {
                                        Text("Likes")
                                            .font(.custom("InstagramSans-Bold", size: 20))
                                            .foregroundColor(colorForLikesText)
                                    }
                                    .padding(.horizontal, 3.5)
                                    
                                    Button {
                                        withAnimation(.spring()) {
                                            viewNum = 0
                                            currentViewState = .home
                                            colorForLikesText = Color.gray
                                            colorForHomeText = Color("TextColor")
                                        }
                                    } label: {
                                        Text("Quotes")
                                            .font(.custom("InstagramSans-Bold", size: 20))
                                            .foregroundColor(colorForHomeText)
                                            .bold()
                                    }
                                    .padding(.horizontal, 3.5)
                                    
                                    Spacer()
                                }
                                
                                HStack {
                                    Spacer()
                                    Button {
                                        showingSettingsSheet.toggle()
                                    } label: {
                                        Image(systemName: "gearshape")
                                            .font(.custom("InstagramSans-Bold", size: 20))
                                            .foregroundColor(Color.gray)
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            Spacer()
                        }
                    }
                }
            }
        }
        .confirmationDialog("seeingSettings", isPresented: $showingSettingsSheet, actions: {
            Button("Choose Tags") {
                withAnimation(.spring()) {
                    viewNum = 1
                    currentViewState = .tags
                    colorForLikesText = Color.gray
                    colorForHomeText = Color.gray
                }
            }
            Button("Cancel", role: .cancel) {}

        })
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
