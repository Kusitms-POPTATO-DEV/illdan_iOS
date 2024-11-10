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
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.gray100
                .ignoresSafeArea()
            
            VStack {
                TopBar(
                    titleText: "할 일",
                    subText: String(viewModel.backlogList.count)
                )
                
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
                .padding(.vertical, 12)
            }
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
        .onAppear {
            Task {
                await viewModel.fetchBacklogList()
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
                    if (item.bookmark) {
                        HStack(spacing: 2) {
                            Image("ic_star_filled")
                                .resizable()
                                .frame(width: 12, height: 12)
                            Text("중요")
                                .font(PoptatoTypo.xsSemiBold)
                                .foregroundColor(.primary60)
                        }
                    }
                    
                    if let dDay = item.dday {
                        if dDay == 0 {
                            Text("D-day")
                                .font(PoptatoTypo.xsSemiBold)
                                .foregroundColor(.gray70)
                                .frame(height: 12)
                        } else if dDay > 0 {
                            Text("D-\(dDay)")
                                .font(PoptatoTypo.xsSemiBold)
                                .foregroundColor(.gray70)
                                .frame(height: 12)
                        } else {
                            Text("D+\(abs(dDay))")
                                .font(PoptatoTypo.xsSemiBold)
                                .foregroundColor(.gray70)
                                .frame(height: 12)
                        }
                    }
                    if (item.bookmark || item.dday != nil) { Spacer() }
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
            
            ZStack(alignment: (item.bookmark || item.dday != nil) ? .top : .center) {
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

#Preview {
    BacklogView(
        onItemSelcted: {item in}
    )
}
