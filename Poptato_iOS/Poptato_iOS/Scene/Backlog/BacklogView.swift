//
//  BacklogView.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/23/24.
//

import SwiftUI
import Combine

struct BacklogView: View {
    @EnvironmentObject var viewModel: BacklogViewModel
    @FocusState private var isTextFieldFocused: Bool
    var onItemSelcted: (TodoItemModel) -> Void
    @Binding var isYesterdayTodoViewPresented: Bool
    @Binding var isCreateCategoryViewPresented: Bool
    @State private var settingsMenuPosition: CGPoint = .zero
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.gray100
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    CategoryListView(
                        categoryList: viewModel.categoryList,
                        onClickCategory: { Task{ await viewModel.fetchBacklogList() } },
                        selectedIndex: $viewModel.selectedCategoryIndex
                    )
                    Image("ic_create_category")
                        .onTapGesture {
                            isCreateCategoryViewPresented = true
                        }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 42)
                .padding(.leading, 16)
                .padding(.top, 16)
                
                HStack {
                    TopBar(
                        titleText: viewModel.categoryList.isEmpty ? "전체" : viewModel.categoryList[viewModel.selectedCategoryIndex].name,
                        subText: String(viewModel.backlogList.count)
                    )
                    Spacer()
                    if viewModel.selectedCategoryIndex != 0 && viewModel.selectedCategoryIndex != 1 {
                        GeometryReader { geometry in
                            Image("ic_settings")
                                .onTapGesture {
                                    settingsMenuPosition = geometry.frame(in: .global).origin
                                    viewModel.showCategorySettingMenu = true
                                }
                        }
                        .frame(width: 20, height: 20)
                    }
                }
                .padding(.trailing, 14)
                
                CreateBacklogTextField(
                    isFocused: $isTextFieldFocused,
                    createBacklog: { task in
                        Task {
                            await viewModel.createBacklog(task)
                        }
                    }
                )
                
                Spacer().frame(height: 16)
                
                if viewModel.backlogList.isEmpty {
                    Spacer()
                    
                    Text("일단, 할 일을\n모두 추가해 보세요.")
                        .font(PoptatoTypo.lgMedium)
                        .foregroundColor(.gray80)
                        .multilineTextAlignment(.center)
                } else {
                    BacklogListView(
                        backlogList: $viewModel.backlogList,
                        onItemSelcted: onItemSelcted,
                        editBacklog: { id, content in
                            Task {
                                await viewModel.editBacklog(todoId: id, content: content)
                            }
                        },
                        swipeBacklog: { id in
                            Task {
                                await viewModel.swipeBacklog(todoId: id)
                            }
                        },
                        onDragEnd: {
                            Task {
                                await viewModel.dragAndDrop()
                            }
                        },
                        activeItemId: $viewModel.activeItemId
                    )
                }
                
                Spacer()
            }
            
            if (viewModel.showCategorySettingMenu) {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Spacer().frame(width: 12)
                        Image("ic_pen")
                            .resizable()
                            .frame(width: 16, height: 16)
                        Spacer().frame(width: 4)
                        Text("수정하기")
                            .padding(.vertical, 10)
                            .font(PoptatoTypo.smMedium)
                            .foregroundColor(.gray30)
                        Spacer().frame(width: 16)
                    }
                    Divider().background(Color.gray90)
                    HStack(spacing: 0) {
                        Spacer().frame(width: 12)
                        Image("ic_trash")
                            .resizable()
                            .frame(width: 16, height: 16)
                        Spacer().frame(width: 4)
                        Text("삭제하기")
                            .padding(.vertical, 10)
                            .font(PoptatoTypo.smMedium)
                            .foregroundColor(.danger50)
                        Spacer().frame(width: 16)
                    }
                    .onTapGesture {
                        viewModel.showDeleteCategoryDialog = true
                    }
                }
                .frame(width: 97, height: 82)
                .background(Color.gray95)
                .cornerRadius(12)
                .position(x: settingsMenuPosition.x - 30, y: settingsMenuPosition.y + 20)
            }
            
            if viewModel.isExistYesterdayTodo {
                ZStack {
                    Color.primary60.ignoresSafeArea()
                    HStack(spacing: 0) {
                        Text("어제 한 일 체크를 깜빡했다면?")
                            .font(PoptatoTypo.smMedium)
                            .foregroundColor(.gray100)
                        Spacer()
                        Text("확인하기")
                            .font(PoptatoTypo.smSemiBold)
                            .foregroundColor(.gray100)
                            .onTapGesture {
                                isYesterdayTodoViewPresented = true
                            }
                        Spacer().frame(width: 4)
                        Image("ic_arrow_right")
                            .resizable()
                            .frame(width: 12, height: 12)
                    }
                    .padding(.horizontal, 16)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 45)
                .clipShape(RoundedCorner(radius: 8, corners: [.topLeft, .topRight]))
            }
            
            if viewModel.showDeleteCategoryDialog {
                CommonDialog(
                    title: "카테고리를 삭제하시겠어요?",
                    content: "카테고리에 저장된 할 일도 함께 삭제돼요",
                    positiveButtonText: "삭제",
                    negativeButtonText: "취소",
                    onClickBtnPositive: {
                        Task {
                            await viewModel.deleteCategory()
                        }
                    },
                    onClickBtnNegative: { viewModel.showDeleteCategoryDialog = false },
                    onDismissRequest: { viewModel.showDeleteCategoryDialog = false }
                )
            }
        }
        .onTapGesture {
            viewModel.showCategorySettingMenu = false
            isTextFieldFocused = false
        }
        .onAppear {
            Task {
                await viewModel.getCategoryList(page: 0, size: 100)
                await viewModel.fetchBacklogList()
            }
        }
        .onChange(of: isCreateCategoryViewPresented) {
            if !isCreateCategoryViewPresented {
                Task {
                    await viewModel.getCategoryList(page: 0, size: 100)
                }
            }
        }
    }
}

struct CategoryListView: View {
    var categoryList: [CategoryModel]
    var onClickCategory: () -> Void
    @Binding var selectedIndex: Int
    
    var body: some View {
        LazyHStack(spacing: 12) {
            ForEach(Array(categoryList.enumerated()), id: \.element.id) { index, item in
                let image = imageName(for: index)
                CategoryItemView(item: item, image: image, isSelected: index == selectedIndex)
                    .onTapGesture {
                        selectedIndex = index
                        onClickCategory()
                    }
            }
        }
    }
    
    private func imageName(for index: Int) -> String? {
        switch categoryList[index].id {
        case -1: return "ic_category_all"
        case 1: return "ic_category_bookmark"
        default: return nil
        }
    }
}

struct CategoryItemView: View {
    var item: CategoryModel
    var image: String?
    var isSelected: Bool
    
    var body: some View {
        ZStack(alignment: .center) {
            Circle()
                .frame(width: 40, height: 40)
                .foregroundColor(.gray100)
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.gray00 : Color.gray95, lineWidth: 1)
                )
            if image == nil {
                SVGImageView(imageURL: item.imageUrl, width: 24, height: 24)
            } else {
                if let image = image {
                    Image(image)
                        .resizable()
                        .frame(width: 24, height: 24)
                }
            }
            
        }
    }
}

struct BacklogListView: View {
    @Binding var backlogList: [TodoItemModel]
    var onItemSelcted: (TodoItemModel) -> Void
    var editBacklog: (Int, String) -> Void
    var swipeBacklog: (Int) -> Void
    var onDragEnd: () -> Void
    @Binding var activeItemId: Int?
    @State private var draggedItem: TodoItemModel?
    @State private var draggedIndex: Int?
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(backlogList, id: \.todoId) { item in
                    let index = backlogList.firstIndex(where: { $0.todoId == item.todoId }) ?? 0
                    
                    BacklogItemView(
                        item: Binding(
                            get: { item },
                            set: { newItem in
                                if let index = backlogList.firstIndex(where: { $0.todoId == newItem.todoId }) {
                                    backlogList[index] = newItem
                                }
                            }
                        ),
                        backlogList: $backlogList,
                        onItemSelcted: onItemSelcted,
                        editBacklog: editBacklog,
                        swipeBacklog: swipeBacklog,
                        activeItemId: $activeItemId
                    )
                    .onDrag {
                        self.draggedItem = item
                        self.draggedIndex = index
                        let provider = NSItemProvider(object: String(item.todoId) as NSString)
                        provider.suggestedName = ""
                        return provider
                    }
                    .onDrop(of: [.text], delegate: DropViewDelegate(
                        item: item,
                        backlogList: $backlogList,
                        draggedItem: $draggedItem,
                        draggedIndex: $draggedIndex,
                        onReorder: { onDragEnd() }
                    ))
                }
            }
            Spacer().frame(height: 45)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
    }
}

struct BacklogItemView: View {
    @Binding var item: TodoItemModel
    @Binding var backlogList: [TodoItemModel]
    var onItemSelcted: (TodoItemModel) -> Void
    var editBacklog: (Int, String) -> Void
    var swipeBacklog: (Int) -> Void
    @Binding var activeItemId: Int?
    @FocusState var isActive: Bool
    @State var content = ""
    @State private var offset: CGFloat = 0
    
    var body: some View {
        HStack {
            VStack {
                HStack(spacing: 6) {
                    if (item.isBookmark) {
                        HStack(spacing: 2) {
                            Image("ic_star_filled")
                                .resizable()
                                .frame(width: 12, height: 12)
                            Text("중요")
                                .font(PoptatoTypo.calSemiBold)
                                .foregroundColor(.primary60)
                        }
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color.gray90)
                        .cornerRadius(4)
                    }
                    
                    if item.isRepeat {
                        HStack(spacing: 2) {
                            Image("ic_refresh")
                                .resizable()
                                .frame(width: 12, height: 12)
                            Text("반복")
                                .font(PoptatoTypo.calSemiBold)
                                .foregroundColor(.gray50)
                        }
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color.gray90)
                        .cornerRadius(4)
                    }
                    
                    if let dDay = item.dday {
                        ZStack {
                            if dDay == 0 {
                                Text("D-day")
                                    .font(PoptatoTypo.calMedium)
                                    .foregroundColor(.gray50)
                                    .frame(height: 12)
                            } else if dDay > 0 {
                                Text("D-\(dDay)")
                                    .font(PoptatoTypo.calMedium)
                                    .foregroundColor(.gray50)
                                    .frame(height: 12)
                            } else {
                                Text("D+\(abs(dDay))")
                                    .font(PoptatoTypo.calMedium)
                                    .foregroundColor(.gray50)
                                    .frame(height: 12)
                            }
                        }
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color.gray90)
                        .cornerRadius(4)
                    }
                    if (item.isBookmark || item.dday != nil || item.isRepeat) { Spacer() }
                }
                
                if activeItemId == item.todoId {
                    TextField("", text: $content)
                        .focused($isActive)
                        .onAppear {
                            isActive = true
                            content = item.content
                        }
                        .onSubmit {
                            if !content.isEmpty, let activeItemId {
                                item.content = content
                                editBacklog(activeItemId, content)
                            }
                            isActive = false
                            activeItemId = nil
                        }
                        .font(PoptatoTypo.mdRegular)
                        .foregroundColor(.gray00)
                } else {
                    HStack{
                        Text(item.content)
                            .font(PoptatoTypo.mdRegular)
                            .foregroundColor(.gray00)
                        
                        Spacer()
                    }
                }
            }
            
            Spacer()
            
            ZStack(alignment: (item.isBookmark || item.dday != nil) ? .top : .center) {
                Image("ic_dot")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .onTapGesture {
                        onItemSelcted(item)
                    }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(RoundedRectangle(cornerRadius: 8))
        .foregroundColor(.gray95)
        .offset(x: offset)
        .simultaneousGesture(
            DragGesture(minimumDistance: 20)
                .onChanged { gesture in
                    if gesture.translation.width < 0 {
                        self.offset = gesture.translation.width
                    }
                }
                .onEnded { _ in
                    if abs(offset) > 100 {
                        swipeBacklog(item.todoId)
                        offset = -UIScreen.main.bounds.width
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            if let index = backlogList.firstIndex(where: { $0.todoId == item.todoId }) {
                                backlogList.remove(at: index)
                            }
                            offset = 0
                        }
                    } else {
                        withAnimation {
                            offset = 0
                        }
                    }
                }
        )
    }
}

struct CreateBacklogTextField: View {
    @FocusState.Binding var isFocused: Bool
    @State private var taskInput: String = ""
    
    var onValueChange: (String) -> Void = { _ in }
    var createBacklog: (String) -> Void = { _ in }

    var body: some View {
        ZStack(alignment: .trailing) {
            ZStack(alignment: .leading) {
                if taskInput.isEmpty && !isFocused {
                    HStack {
                        Image(systemName: "plus")
                            .foregroundColor(.gray)

                        Text("할 일을 입력하세요")
                            .foregroundColor(.gray)
                    }
                    .padding(.leading, 16)
                }

                TextField("", text: $taskInput, axis: .vertical)
                    .focused($isFocused)
                    .onChange(of: taskInput) {
                        guard let newValueLastChar = taskInput.last else { return }
                        
                        if newValueLastChar == "\n" {
                            taskInput.removeLast()
                            if !taskInput.isEmpty {
                                createBacklog(taskInput)
                                taskInput = "" 
                            }
                            isFocused = true
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
            }
            .background(RoundedRectangle(cornerRadius: 8).stroke(isFocused ? Color.white : Color.gray, lineWidth: 1))
            .padding(.horizontal, 16)
            .onTapGesture {
                isFocused = true
            }

            if !taskInput.isEmpty {
                Button(action: {
                    taskInput = ""
                    onValueChange("")
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .frame(width: 24, height: 24)
                        .offset(x: -10)
                        .foregroundColor(.gray95)
                }
                .padding(.trailing, 16)
            }
        }
    }
}
