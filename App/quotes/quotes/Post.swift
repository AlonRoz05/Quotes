import SwiftUI

struct Post: View {
    @State var quote: ModelsQuote?
    var usedTagForPro = UserDefaults.standard.array(forKey: "usedTagForPro") as? [String] ?? []
    var usedTagForFree = UserDefaults.standard.string(forKey: "usedTagForFree")?.lowercased() ?? "default  "

    @State var likedQuote = false
    @State var textToShow = ""

    @State var quoteAlradyGenerated = false
    
    @State var showingProAd = false
    
    var pro: Bool
    
    @State var seedToUse = 0

    var body: some View {
        let quoteToShow = String(quote?.quote ?? String(repeating: "*", count: 124))

        ZStack {
            Text(textToShow == "" ? quoteToShow : textToShow)
                .font(.custom("InstagramSans-Bold", size: 20))
                .lineSpacing(4)
                .foregroundColor(Color("TextColor"))
                .multilineTextAlignment(.center)
                .frame(width: 330, height: 340)
                .redacted(reason: quoteToShow == String(repeating: "*", count: 124) && textToShow == "" ? .placeholder : [])
            
            VStack {
                Spacer()
                HStack {
                    if pro {
                        Button {
                            if quoteToShow != String(repeating: "*", count: 124) {
                                likedQuote.toggle()
                                
                                if likedQuote {
                                    likeQuote(quote: String(quote?.quote ?? "Dont Add"))
                                } else {
                                    deleteQuote(quote: String(quote?.quote ?? "Dont Do"))
                                }
                            }
                        } label: {
                            if likedQuote {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                            } else {
                                Image(systemName: "heart")
                                    .foregroundColor(Color("TextColor"))
                            }
                        }
                        .font(.system(size: 22))
                    }
                    
                    if textToShow.isEmpty {
                        if pro {
                            if getEmoji(isPro: pro, seed: seedToUse) != " " {
                                Text(String(getEmoji(isPro: pro, seed: seedToUse)))
                                    .font(.system(size: 25, weight: .bold))
                            }
                        } else {
                            if usedTagForFree.last! != " " {
                                Text(String(usedTagForFree.last!))
                                    .font(.system(size: 25, weight: .bold))
                            }
                        }
                    } else {
                        Text("👑")
                            .font(.system(size: 25, weight: .bold))
                    }
                }
                .padding(50)
            }
        }
        .frame(width: 335, height: 340)
        .task {
            let usedTagsForProToCheckSeed = UserDefaults.standard.array(forKey: "usedTagForPro") as? [String] ?? []
            let lenTagsForPro = usedTagsForProToCheckSeed.count
            if lenTagsForPro > 0 {
                seedToUse = Int.random(in: 0..<lenTagsForPro)
            }
            if !pro {
                if Int.random(in: 0..<5) == 0 {
                    switch Int.random(in: 0..<3) {
                    case 0:
                        textToShow = "Unlock exclusive perks and advanced capabilities by switching to our pro plan!"

                    case 1:
                        textToShow = "Experience motivation at its finest with our Pro version!"

                    case 2:
                        textToShow = "Ready to elevate your motivation journey? Go Pro and take it to the next level!"

                    default:
                        textToShow = "Ready to elevate your motivation journey? Go Pro and take it to the next level!"
                    }
                }
            }
            if !quoteAlradyGenerated {
                do {
                    quote = try await getQuote(isPro: pro, seed: seedToUse)
                    quoteAlradyGenerated.toggle()
                } catch {}
            }

            let likedQuotesList = UserDefaults.standard.array(forKey: "likedQuoteList") as? [String] ?? []
            if likedQuote && likedQuotesList.contains(quoteToShow) {
                likedQuote.toggle()
            }
        }
    }

    func likeQuote(quote: String) {
        if quote != "Dont Add" {
            var likedQuotesList = UserDefaults.standard.array(forKey: "likedQuoteList") as? [String] ?? []
            likedQuotesList.append(quote)
            UserDefaults.standard.set(likedQuotesList, forKey: "likedQuoteList")
        }
    }
    
    func deleteQuote(quote: String) {
        if quote != "Dont Do" {
            var likedQuotesList = UserDefaults.standard.array(forKey: "likedQuoteList") as? [String] ?? []
            if let index = likedQuotesList.lastIndex(of: quote) {
                likedQuotesList.remove(at: index)
            }
            UserDefaults.standard.set(likedQuotesList, forKey: "likedQuoteList")
        }
    }
    
    func getEmoji(isPro: Bool, seed: Int) -> String {
        let usedTagForFree = UserDefaults.standard.string(forKey: "usedTagForFree") ?? "default  "
        
        if isPro {
            let usedTagsForPro = UserDefaults.standard.array(forKey: "usedTagForPro") as? [String] ?? []
            if usedTagsForPro != [] {
                let usedTag = usedTagsForPro[seed]
                return String(usedTag.last!)
            } else {
                return " "
            }
        }
        return String(usedTagForFree.last!)
    }
}

func getTag(isPro: Bool, seed: Int) -> String {
    var usedTag = "default  "

    if isPro {
        let usedTagsForPro = UserDefaults.standard.array(forKey: "usedTagForPro") as? [String] ?? []
        if usedTagsForPro != [] {
            usedTag = usedTagsForPro[seed]
        }
    } else {
        usedTag = UserDefaults.standard.string(forKey: "usedTagForFree") ?? "default  "
    }
    
    return usedTag
}

func getQuote(isPro: Bool, seed: Int) async throws -> ModelsQuote {
    var usedTag = getTag(isPro: isPro, seed: seed)
    
    usedTag.removeLast()
    usedTag.removeLast()

    let endpoint = "https://l6j8614hxj.execute-api.us-east-1.amazonaws.com/q-api/quotes-generation?input_tag=\(String(usedTag.lowercased()))"
    
    guard let url = URL(string: endpoint) else {
        throw QuoteError.invalidURL
    }

    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
        throw QuoteError.invailidResponse
    }
    
    do {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(ModelsQuote.self, from: data)
    } catch {
        throw QuoteError.invailidData
    }
}


struct ModelsQuote: Codable {
    let quote: String
}

enum QuoteError: Error {
    case invalidURL
    case invailidResponse
    case invailidData
}

#Preview {
    Post(pro: true)
}
