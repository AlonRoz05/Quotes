import SwiftUI

struct likedQuotesView: View {
    @State private var likedQuotesList: [String] = []
    let isPro: Bool

    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                if isPro {
                    List {
                        Section {
                            if !likedQuotesList.isEmpty {
                                ForEach(likedQuotesList, id: \.self) {quote in
                                    Text(quote)
                                        .foregroundColor(Color("TextColor"))
                                        .font(.system(size: 18))
                                        .lineSpacing(3.6)
                                    
                                        .swipeActions {
                                            Button(role: .destructive) {
                                                if let indexToRemove = likedQuotesList.firstIndex(of: quote) {
                                                    likedQuotesList.remove(at: indexToRemove)
                                                }
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                }
                                .onDelete(perform: deleteQuote)
                            } else {
                                Text("Oops, nothing to see here yet!")
                                    .foregroundColor(Color("TextColor"))
                                    .listRowSeparator(.hidden)
                            }
                        } header: {
                            Text("Liked quotes")
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .padding(.vertical, 35)
                } else {
                    Text("Locked 🔒,\nLikes is for Pro users only!")
                        .font(.custom("InstagramSans-Bold", size: 20))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("TextColor"))
                }
            }
        }
        .onAppear {
            loadQuoteListData()
        }
        .onDisappear {
            saveQuoteListData()
        }
    }

    func deleteQuote(at offsets: IndexSet) {
        likedQuotesList.remove(atOffsets: offsets)
    }

    func saveQuoteListData() {
        UserDefaults.standard.set(likedQuotesList, forKey: "likedQuoteList")
    }

    func loadQuoteListData() {
        if let savedItems = UserDefaults.standard.array(forKey: "likedQuoteList") as? [String] {
            likedQuotesList = savedItems
        }
    }
}

#Preview {
    likedQuotesView(isPro: true)
}
