//
//  CreateCategoryView.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 11/26/24.
//

import SwiftUI

struct CreateCategoryView: View {
    @ObservedObject private var viewModel = CreateCategoryViewModel()
    @Binding var isPresented: Bool
    @FocusState private var isTextFieldFocused: Bool
    @State private var showBottomSheet: Bool = false
    var initialCategoryId: Int
    var initialCategoryName: String
    var initialSelectedEmoji: EmojiModel
    var isCategoryEditMode: Bool
    
    var body: some View {
        ZStack {
            Color.gray100.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer().frame(height: 24)
                
                CreateCategoryTopBar(
                    isPresented: $isPresented,
                    createCategory: {
                        if !viewModel.categoryInput.isEmpty && viewModel.selectedEmoji != nil {
                            Task {
                                await viewModel.createCategory(name: viewModel.categoryInput, emojiId: viewModel.selectedEmoji!.emojiId)
                                isPresented = false
                            }
                        }
                    },
                    editCategory: {
                        if !viewModel.categoryInput.isEmpty && viewModel.selectedEmoji != nil {
                            Task {
                                await viewModel.editCategory(name: viewModel.categoryInput, emojiId: viewModel.selectedEmoji!.emojiId)
                                isPresented = false
                            }
                        }
                    },
                    isCategoryEditMode: isCategoryEditMode
                )
                
                Spacer().frame(height: 27)
                
                CreateCategoryTextField(
                    isFocused: $isTextFieldFocused,
                    input: $viewModel.categoryInput,
                    showEmojiBottomSheet: $showBottomSheet,
                    selectedEmoji: $viewModel.selectedEmoji
                )
                
                Spacer()
            }
            .padding(.horizontal, 16)
            
            if showBottomSheet {
                Color.black.opacity(0.6)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                    .animation(nil, value: showBottomSheet)
                    .onTapGesture {
                        withAnimation {
                            showBottomSheet = false
                        }
                    }
            }
            
            if showBottomSheet {
                EmojiBottomSheet(
                    isPresented: $showBottomSheet,
                    selectedEmoji: $viewModel.selectedEmoji,
                    emojiList: viewModel.emojiList
                )
                .transition(.move(edge: .bottom))
                .zIndex(1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            Task {
                await viewModel.getEmojiList()
            }
            if isCategoryEditMode {
                viewModel.categoryId = initialCategoryId
                viewModel.categoryInput = initialCategoryName
                viewModel.selectedEmoji = initialSelectedEmoji
            }
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
    }
}

struct CreateCategoryTopBar: View {
    @Binding var isPresented: Bool
    var createCategory: () -> Void
    var editCategory: () -> Void
    var isCategoryEditMode: Bool
    
    var body: some View {
        ZStack(alignment: .center) {
            Text(isCategoryEditMode ? "카테고리 수정" : "카테고리 추가")
                .font(PoptatoTypo.mdSemiBold)
                .foregroundColor(.gray00)
            
            HStack {
                Image("ic_arrow_left")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .onTapGesture {
                        isPresented = false
                    }
                
                Spacer()
                
                Button(
                    action: {
                        if isCategoryEditMode {
                            editCategory()
                        } else {
                            createCategory()
                        }
                    }
                ) {
                    Text("완료")
                        .font(PoptatoTypo.smMedium)
                        .foregroundColor(.gray00)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(Color.gray95)
                .cornerRadius(8)
            }
            .frame(maxWidth: .infinity)
            
            
        }
    }
}

struct CreateCategoryTextField: View {
    @FocusState.Binding var isFocused: Bool
    @Binding var input: String
    @Binding var showEmojiBottomSheet: Bool
    @Binding var selectedEmoji: EmojiModel?
    
    var body: some View {
        HStack(spacing: 0) {
            TextField("", text: $input)
                .focused($isFocused)
                .padding(.bottom, 8)
                .overlay(
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(isFocused ? .gray20 : .gray90)
                        .padding(.top, 40),
                    alignment: .bottom
                )
                .onChange(of: input) { newValue in
                    if newValue.count > 15 {
                        input = String(input.prefix(15))
                    }
                }
                .foregroundColor(.gray00)
                .font(PoptatoTypo.xLMedium)
                .onSubmit {
                    isFocused = false
                }
            
            Spacer().frame(width: 16)
            
            if selectedEmoji == nil {
                Image("ic_add_emoji")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .onTapGesture {
                        withAnimation {
                            showEmojiBottomSheet = true
                        }
                    }
            } else {
                PDFImageView(imageURL: selectedEmoji!.imageUrl, width: 40, height: 40)
                    .onTapGesture {
                        withAnimation {
                            showEmojiBottomSheet = true
                        }
                    }
            }
        }
    }
}

struct EmojiBottomSheet: View {
    @Binding var isPresented: Bool
    @Binding var selectedEmoji: EmojiModel?
    var emojiList: [String : [EmojiModel]]
    
    var body: some View {
        VStack {
            Spacer()
            
            ZStack(alignment: .top) {
                Color.gray100.ignoresSafeArea()
                
                ScrollView {
                    VStack {
                        ForEach(Array(emojiList.keys), id: \.self) { key in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(key)
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                if let emojis = emojiList[key] {
                                    EmojiGridView(emojiList: emojis, selectedEmoji: $selectedEmoji, isPresented: $isPresented)
                                }
                            }
                        }
                        
                        Spacer().frame(height: 10)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 550)
            .clipShape(RoundedCorner(radius: 16, corners: [.topLeft, .topRight]))
        }
    }
}

struct EmojiGridView: View {
    var emojiList: [EmojiModel]
    let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
    @Binding var selectedEmoji: EmojiModel?
    @Binding var isPresented: Bool
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(emojiList) { emoji in
                PDFImageView(imageURL: emoji.imageUrl, width: 32, height: 32)
                    .onTapGesture {
                        selectedEmoji = emoji
                        isPresented = false
                    }
            }
        }
    }
}
