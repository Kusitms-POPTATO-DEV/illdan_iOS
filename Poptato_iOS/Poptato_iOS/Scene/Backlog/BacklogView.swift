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
    var showBottomSheet: () -> Void
    
    var body: some View {
        ZStack {
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
                        showBottomSheet: showBottomSheet,
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
                        activeItemId: $viewModel.activeItemId
                    )
                }
                
                Spacer()
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
    var showBottomSheet: () -> Void
    var editBacklog: (Int, String) -> Void
    var swipeBacklog: (Int) -> Void
    @Binding var activeItemId: Int?
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(backlogList.indices, id: \.self) { index in
                    BacklogItemView(
                        item: $backlogList[index],
                        backlogList: $backlogList,
                        onItemSelcted: onItemSelcted,
                        showBottomSheet: showBottomSheet,
                        editBacklog: editBacklog,
                        swipeBacklog: swipeBacklog,
                        activeItemId: $activeItemId
                    )
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
    }
}

struct BacklogItemView: View {
    @Binding var item: TodoItemModel
    @Binding var backlogList: [TodoItemModel]
    var onItemSelcted: (TodoItemModel) -> Void
    var showBottomSheet: () -> Void
    var editBacklog: (Int, String) -> Void
    var swipeBacklog: (Int) -> Void
    @Binding var activeItemId: Int?
    @FocusState var isActive: Bool
    @State var content = ""
    @State private var offset: CGFloat = 0
    
    var body: some View {
        VStack {
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
                    
                    Image("ic_dot")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .onTapGesture {
                            onItemSelcted(item)
                            showBottomSheet()
                        }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(RoundedRectangle(cornerRadius: 8))
        .foregroundColor(.gray95)
        .offset(x: offset)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    if gesture.translation.width < 0 {
                        self.offset = gesture.translation.width
                    }
                }
                .onEnded { _ in
                    if abs(offset) > 100 {
                        swipeBacklog(item.todoId)
                        withAnimation {
                            self.offset = -UIScreen.main.bounds.width
                        }
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

                TextField("", text: $taskInput)
                    .focused($isFocused)
                    .onSubmit {
                        if !taskInput.isEmpty {
                            createBacklog(taskInput)
                            taskInput = ""
                        }
                        isFocused = true
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
        onItemSelcted: {item in},
        showBottomSheet: {}
    )
}
