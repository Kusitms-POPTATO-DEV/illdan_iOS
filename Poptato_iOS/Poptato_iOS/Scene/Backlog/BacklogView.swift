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
    @FocusState private var isEditingActive: Bool
    var onItemSelcted: (TodoItemModel) -> Void
    @Binding var isYesterdayTodoViewPresented: Bool
    @Binding var isCreateCategoryViewPresented: Bool
    @State private var settingsMenuPosition: CGPoint = .zero
    @State private var isViewActive = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.gray100
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    CategoryListView(
                        categoryList: $viewModel.categoryList,
                        selectedIndex: $viewModel.selectedCategoryIndex,
                        onClickCategory: { Task { await viewModel.fetchBacklogList() } },
                        onDragEnd: { Task { await viewModel.categoryDragAndDrop() } }
                    )
                    HStack {
                        Image("ic_create_category")
                            .onTapGesture {
                                viewModel.isCategoryEditMode = false
                                isCreateCategoryViewPresented = true
                            }
                        Spacer().frame(width: 16)
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
                                    viewModel.showCategorySettingMenu = !viewModel.showCategorySettingMenu
                                }
                        }
                        .frame(width: 24, height: 24)
                    }
                }
                .padding(.trailing, 20)
                
                CreateBacklogTextField(
                    isFocused: $isTextFieldFocused,
                    createBacklog: { task in
                        Task {
                            await viewModel.createBacklog(task)
                        }
                    }
                )
                
                Spacer().frame(height: 16)
                
                ZStack(alignment: .top) {
                    if viewModel.backlogList.isEmpty { EmptyBacklogView() }
                    else {
                        BacklogListView(
                            backlogList: $viewModel.backlogList,
                            onItemSelected: onItemSelcted,
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
                            activeItemId: $viewModel.activeItemId,
                            content: $viewModel.editingContent,
                            isActive: $isEditingActive,
                            deadlineDateMode: viewModel.deadlineDateMode
                        )
                    }
                    
                    if viewModel.showFirstGuideBubble {
                        Image("ic_guide_bubble_1")
                            .offset(x: 80, y: -20)
                    }
                    
                    if viewModel.showSecondGuideBubble {
                        VStack {
                            Spacer()
                            HStack {
                                Image("ic_guide_bubble_2")
                                    .padding(.leading, 20)
                                Spacer()
                            }
                        }
                    }
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
                    .onTapGesture {
                        viewModel.isCategoryEditMode = true
                        isCreateCategoryViewPresented = true
                    }
                    Divider().background(Color.gray90)
                    HStack(spacing: 0) {
                        Spacer().frame(width: 12)
                        Image("ic_trash_warning")
                            .resizable()
                            .frame(width: 16, height: 16)
                        Spacer().frame(width: 4)
                        Text("삭제하기")
                            .padding(.vertical, 10)
                            .font(PoptatoTypo.smMedium)
                            .foregroundColor(.warning40)
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
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .simultaneousGesture(
            TapGesture().onEnded {
                isTextFieldFocused = false
                viewModel.showCategorySettingMenu = false
                if isEditingActive {
                    submitEditing()
                }
            }
        )
        .onAppear {
            Task {
                await viewModel.getCategoryList(page: 0, size: 100)
                await viewModel.fetchBacklogList()
                await MainActor.run {
                    isViewActive = true
                }
            }
        }
        .onDisappear {
            if viewModel.showSecondGuideBubble {
                viewModel.showSecondGuideBubble = false
                viewModel.isNewUser = false
            }
            isViewActive = false
        }
        .onChange(of: isCreateCategoryViewPresented) { newValue in
            if !newValue {
                Task {
                    await viewModel.getCategoryList(page: 0, size: 100)
                    viewModel.selectedCategoryIndex = viewModel.categoryList.count - 1
                    await viewModel.fetchBacklogList()
                }
            }
        }
    }
    
    private func submitEditing() {
        if viewModel.editingContent.isEmpty {
            isEditingActive = false
            viewModel.activeItemId = nil
        }
        guard let itemId = viewModel.activeItemId, !viewModel.editingContent.isEmpty else { return }
        Task {
            await viewModel.editBacklog(todoId: itemId, content: viewModel.editingContent)
            await MainActor.run {
                isEditingActive = false
                viewModel.activeItemId = nil
                viewModel.editingContent = ""
            }
        }
    }
}

struct CategoryListView: View {
    @Binding var categoryList: [CategoryModel]
    @Binding var selectedIndex: Int
    @State private var draggedCategory: CategoryModel?
    @State private var isDragging: Bool = false
    var onClickCategory: () -> Void
    var onDragEnd: () -> Void
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 12) {
                ForEach(Array(categoryList.enumerated()), id: \.element.id) { index, item in
                    let image = imageName(for: index)
                    CategoryItemView(item: item, image: image, isSelected: index == selectedIndex)
                        .onTapGesture {
                            selectedIndex = index
                            onClickCategory()
                        }
                        .if(item.id != -1 && item.id != 0) { view in
                            view.onDrag {
                                draggedCategory = item
                                isDragging = true
                                return NSItemProvider(object: "\(item.id)" as NSString)
                            }
                        }
                        .onDrop(of: [.text],
                                delegate: CategoryDragDropDelegate(item: item,
                                                                   categoryList: $categoryList,
                                                                   draggedItem: $draggedCategory,
                                                                   onReorder: {
                            isDragging = false
                            onDragEnd()
                        }))
                }
            }
        }
        .scrollIndicators(.hidden)
    }
    
    private func imageName(for index: Int) -> String? {
        switch categoryList[index].id {
        case -1: return "ic_category_all"
        case 0: return "ic_category_bookmark"
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
            if image == nil {
                PDFImageView(imageURL: item.imageUrl, width: 24, height: 24)
            } else {
                if let image = image {
                    Image(image)
                        .resizable()
                        .frame(width: 24, height: 24)
                }
            }
            
        }
        .frame(width: 40, height: 40)
        .background(isSelected ? Color.gray90 : Color.gray100)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct BacklogListView: View {
    @Binding var backlogList: [TodoItemModel]
    var onItemSelected: (TodoItemModel) -> Void
    var editBacklog: (Int, String) -> Void
    var swipeBacklog: (Int) -> Void
    var onDragEnd: () -> Void
    @Binding var activeItemId: Int?
    @Binding var content: String
    @FocusState.Binding var isActive: Bool
    @State private var draggedItem: TodoItemModel?
    @State private var isDragging: Bool = false
    var deadlineDateMode: Bool
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(backlogList.indices, id: \.self) { index in
                    let item = backlogList[index]
                    
                    BacklogItemView(
                        item: $backlogList[index],
                        backlogList: $backlogList,
                        onItemSelected: onItemSelected,
                        editBacklog: editBacklog,
                        swipeBacklog: swipeBacklog,
                        activeItemId: $activeItemId,
                        content: $content,
                        isActive: $isActive,
                        deadlineDateMode: deadlineDateMode
                    )
                    .onDrag {
                        draggedItem = item
                        isDragging = true
                        return NSItemProvider(object: "\(item.todoId)" as NSString)
                    }
                    .onDrop(of: [.text], delegate: DragDropDelegate(item: item, backlogList: $backlogList, draggedItem: $draggedItem, onReorder: {
                        isDragging = false
                        onDragEnd()
                    }))
                }
            }
            Spacer().frame(height: 45)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
    }
}

struct BacklogItemView: View {
    @Binding var item: TodoItemModel
    @Binding var backlogList: [TodoItemModel]
    var onItemSelected: (TodoItemModel) -> Void
    var editBacklog: (Int, String) -> Void
    var swipeBacklog: (Int) -> Void
    @Binding var activeItemId: Int?
    @Binding var content: String
    @FocusState.Binding var isActive: Bool
    @State private var offset: CGFloat = 0
    var deadlineDateMode: Bool
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        HStack {
            VStack(spacing: 0) {
                if activeItemId == item.todoId {
                    TextField("", text: $content, axis: .vertical)
                        .focused($isActive)
                        .onAppear {
                            isActive = true
                            content = item.content
                        }
                        .onChange(of: content) { newValue in
                            if newValue.contains("\n") {
                                content = newValue.replacingOccurrences(of: "\n", with: "")
                                handleSubmit()
                            }
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
                
                if item.isRepeat || item.dDay != nil {
                    Spacer().frame(height: 8)
                    BacklogRepeatDeadlineText(deadlineDateMode: deadlineDateMode, item: item)
                }
                
                if item.isBookmark || item.categoryName != nil {
                    Spacer().frame(height: 8)
                    BacklogBookmarkCategoryChip(item: item)
                }
            }
            
            Spacer()
            
            VStack(spacing: 0) {
                Image("ic_dot")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(Color.gray80)
                    .frame(width: 20, height: 20)
                    .padding(.top, !item.isRepeat && !item.isBookmark && item.dDay == nil && item.categoryName == nil ? 2.5 : 0)
                    .onTapGesture {
                        onItemSelected(
                            TodoItemModel(
                                todoId: item.todoId,
                                content: item.content,
                                isBookmark: item.isBookmark,
                                isRepeat: item.isRepeat,
                                dDay: item.dDay,
                                deadline: item.deadline
                            )
                        )
                    }
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 12))
        .foregroundColor(.gray95)
        .offset(x: offset)
        .highPriorityGesture(
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
    
    private func handleSubmit() {
        if !content.isEmpty, let activeItemId {
            editBacklog(activeItemId, content)
        }
        isActive = false
        activeItemId = nil
        content = ""
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
                            .foregroundColor(Color.gray80)

                        Text("할 일 추가하기...")
                            .foregroundColor(Color.gray80)
                    }
                    .padding(.leading, 16)
                }

                TextField("", text: $taskInput, axis: .vertical)
                    .focused($isFocused)
                    .onChange(of: taskInput) { newValue in
                        if newValue.contains("\n") {
                            taskInput = newValue.replacingOccurrences(of: "\n", with: "")
                            handleSubmit()
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
            }
            .background(RoundedRectangle(cornerRadius: 8).stroke(isFocused ? Color.white : Color.gray80, lineWidth: 1))
            .padding(.horizontal, 20)
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

    private func handleSubmit() {
        if taskInput.isEmpty {
            Task {
                await MainActor.run {
                    isFocused = false
                }
            }
        } else {
            createBacklog(taskInput)
            taskInput = ""
            
            Task {
                await MainActor.run {
                    isFocused = true
                }
            }
        }
    }
}

struct BacklogRepeatDeadlineText: View {
    @State var deadlineDateMode: Bool
    let item: TodoItemModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 3) {
            if item.isRepeat {
                Text("반복 할 일")
                    .font(PoptatoTypo.xsRegular)
                    .foregroundStyle(Color.gray50)
            }
            
            if item.isRepeat && item.dDay != nil {
                Text("·")
                    .font(PoptatoTypo.xsRegular)
                    .foregroundStyle(Color.gray50)
            }
            
            if let dDay = item.dDay, let deadline = item.deadline {
                ZStack {
                    if deadlineDateMode {
                        Text(deadline)
                            .font(PoptatoTypo.xsRegular)
                            .foregroundColor(.gray50)
                    } else {
                        if dDay == 0 {
                            Text("D-day")
                                .font(PoptatoTypo.xsRegular)
                                .foregroundColor(.gray50)
                        } else if dDay > 0 {
                            Text("D-\(dDay)")
                                .font(PoptatoTypo.xsRegular)
                                .foregroundColor(.gray50)
                        } else {
                            Text("D+\(abs(dDay))")
                                .font(PoptatoTypo.xsRegular)
                                .foregroundColor(.gray50)
                        }
                    }
                    
                }
            }
            
            if item.isRepeat || item.dDay != nil { Spacer().frame(height: 0) }
        }
    }
}

struct BacklogBookmarkCategoryChip: View {
    let item: TodoItemModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            if (item.isBookmark) {
                HStack(spacing: 2) {
                    Image("ic_star_filled")
                        .resizable()
                        .frame(width: 12, height: 12)
                    Text("중요")
                        .font(PoptatoTypo.calSemiBold)
                        .foregroundColor(.primary40)
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(Color.gray90)
                .cornerRadius(4)
            }
            
            if let categoryName = item.categoryName, let imageUrl = item.imageUrl {
                HStack(spacing: 2) {
                    PDFImageView(imageURL: imageUrl, width: 12, height: 12)
                    Text(categoryName)
                        .font(PoptatoTypo.xsRegular)
                        .foregroundColor(.gray50)
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(Color.gray90)
                .cornerRadius(6)
            }
            
            if (item.isBookmark || item.categoryName != nil) { Spacer().frame(height: 0) }
        }
    }
}

struct EmptyBacklogView: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            HStack {
                Image("ic_arrow_curved")
                Spacer()
            }
            .padding(.horizontal, 37)
            .padding(.top, 37)
            
            VStack(alignment: .center) {
                Image("ic_fire_today")
                
                Text("일단, 할 일을\n모두 추가해 보세요")
                    .font(PoptatoTypo.mdMedium)
                    .foregroundColor(.gray70)
                    .multilineTextAlignment(.center)
            }
            .frame(maxHeight: .infinity)
            .frame(maxWidth: .infinity)
        }
    }
}
