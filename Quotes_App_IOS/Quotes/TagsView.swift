//
//  TagsView.swift
//  Quotes
//
//  Created by Alon Rozmarin on 28/09/2023.
//

import SwiftUI

struct TagData: Codable {
    var tags: [String]
}

class TagsFunctionsViewModel: ObservableObject {
    @Published var selectedTag: String?

    func selectTag(tagToSelect: String) {
        if selectedTag == tagToSelect {
            selectedTag = nil
            UserDefaults.standard.set(selectedTag, forKey: "usedTag")
        } else {
            selectedTag = tagToSelect
            UserDefaults.standard.set(selectedTag, forKey: "usedTag")
        }
    }
}

struct TagsView: View {
    @State private var showError = false
    @StateObject private var viewModel = TagsFunctionsViewModel()
    private let gridItems = [GridItem(.flexible()), GridItem(.flexible())]

    @State private var tagData: TagData? = {
            if let url = Bundle.main.url(forResource: "tags", withExtension: "json"),
               let data = try? Data(contentsOf: url),
               let decodedData = try? JSONDecoder().decode(TagData.self, from: data) {
                return decodedData
            }
            return nil
        }()

    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    ZStack {
                        Color("BackgroundColor")
                            .ignoresSafeArea()

                        ScrollView {
                            VStack {
                                Spacer()
                                HStack {
                                    Text("Tags")
                                        .foregroundColor(Color("TextColor"))
                                        .font(.system(size: 40, weight: .bold))
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                        .padding(.top)
                                    Spacer()
                                }
                                HStack {
                                    Text("Using the \(UserDefaults.standard.string(forKey: "usedTag") ?? "default") tag")
                                        .foregroundColor(Color("TextColor"))
                                        .font(.system(size: 17.5, weight: .bold))
                                        .padding(.horizontal)
                                        .padding(.top, 0.5)
                                        .padding(.bottom)
                                    Spacer()
                                }
                            }

                            LazyVGrid(columns: gridItems, spacing: 20) {
                                if let tags = tagData?.tags {
                                    ForEach(tags, id: \.self) { tag in
                                        Tag(TagName: tag, viewModel: viewModel, isSelected: tag == viewModel.selectedTag)
                                            .onTapGesture {
                                                viewModel.selectTag(tagToSelect: tag)
                                            }
                                    }
                                } else {
                                    Text("")
                                        .task {
                                            showError = true
                                        }
                                }
                            }
                        }
                    }
                }
            }
        }
        .alert(isPresented: $showError, content: {
            Alert(title: Text("An error appeared"), message: Text("Oops something went wrong, please try again later."), dismissButton: .default(Text("Ok")))
        })
    }
}

struct Tag: View {
    @State private var currentUsedTagName = UserDefaults.standard.string(forKey: "usedTag") ?? "default"
    @State var TagName = ""

    @ObservedObject private var viewModel: TagsFunctionsViewModel

    var isSelected: Bool

    init(TagName: String, viewModel: TagsFunctionsViewModel, isSelected: Bool) {
        self.TagName = TagName
        self.viewModel = viewModel
        self.isSelected = isSelected
    }

    var body: some View {
        ZStack {
            VStack {
                Button {
                    viewModel.selectTag(tagToSelect: TagName)
                } label: {
                    Text(TagName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("TextColor"))
                        .multilineTextAlignment(.center)
                        .frame(width: 155, height: 85)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color("ButtonColor"))
                .buttonBorderShape(.roundedRectangle(radius: 12))
                .overlay(isSelected ? RoundedRectangle(cornerRadius: 12).stroke(Color.mint, lineWidth: 2) : nil)
                .animation(.easeInOut, value: isSelected)
                .overlay(currentUsedTagName == TagName ? RoundedRectangle(cornerRadius: 12).stroke(Color.gray, lineWidth: 2) : nil)
                .animation(.easeInOut, value: currentUsedTagName == TagName)
            }
        }
    }
}

#Preview {
    TagsView()
}
