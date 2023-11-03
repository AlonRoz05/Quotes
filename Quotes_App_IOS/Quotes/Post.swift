//
//  Post.swift
//  Quotes
//
//  Created by Alon Rozmarin on 28/09/2023.
//

import SwiftUI

struct Post: View {
    @State var quote: ModelsQuote?
    var usedTag = UserDefaults.standard.string(forKey: "usedTag")?.lowercased() ?? "default  "

    var body: some View {
        ZStack {
            let quoteToShow = quote?.quote ?? String(repeating: "*", count: 113)

            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .frame(width: 355, height: 330)
                .foregroundColor(Color("QuotesBackgroundColor"))

            Text(quoteToShow)
                .foregroundColor(Color("TextColor"))
                .font(.system(size: 22, weight: .bold))
                .multilineTextAlignment(.center)
                .frame(width: 345, height: 340)
                .redacted(reason: quoteToShow == String(repeating: "*", count: 113) ? .placeholder : [])

            VStack {
                HStack {
                    Spacer()
                    Text(String(usedTag.last!))
                        .font(.system(size: 28, weight: .bold))
                }
                Spacer()
            }
            .frame(width: 335, height: 315)
        }
        .task {
            do {
                quote = try await getQuote()
            } catch {}
        }
    }
}

func getQuote() async throws -> ModelsQuote {
    var usedTag = UserDefaults.standard.string(forKey: "usedTag") ?? "default  "
    usedTag.removeLast()
    usedTag.removeLast()

    let endpoint = "https://khui4zeq435ucddfdehdm5sgvy0hfmxq.lambda-url.eu-north-1.on.aws/quotes?input_tag=\(String(usedTag.lowercased()))"

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
    Post()
}
