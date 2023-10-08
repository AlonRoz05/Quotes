//
//  Post.swift
//  Quotes
//
//  Created by Alon Rozmarin on 28/09/2023.
//

import SwiftUI

struct Post: View {
    @State var quote: GetModelsQuote?
    @State var showErrorMassege: Bool = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .frame(width: 355, height: 350)
                .foregroundColor(Color("QuotesBackgroundColor"))

            Text(quote?.quote ?? "Unable to load quote")
                .foregroundColor(Color("TextColor"))
                .font(.system(size: 22, weight: .bold))
                .multilineTextAlignment(.center)
                .frame(width: 345, height: 340)
        }
        .task {
            do {
                quote = try await getQuote()
            } catch {
                showErrorMassege = true
            }
        }
    }
}

func getQuote() async throws -> GetModelsQuote {
    var usedTag = UserDefaults.standard.string(forKey: "usedTag")?.lowercased() ?? "default"
    usedTag.removeLast()
    usedTag.removeLast()

    let endpoint = "http://192.168.51.109:8000/?tag=\(String(describing: usedTag))"

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
        return try decoder.decode(GetModelsQuote.self, from: data)
    } catch {
        throw QuoteError.invailidData
    }
}


struct GetModelsQuote: Codable {
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
