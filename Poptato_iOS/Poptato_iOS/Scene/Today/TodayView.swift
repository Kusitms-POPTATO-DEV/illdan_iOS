//
//  TodayView.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/27/24.
//

import SwiftUI
import UIKit
import StoreKit

struct TodayView: View {
    @EnvironmentObject var viewModel: TodoViewModel
    @FocusState private var isTextFieldFocused: Bool
    var goToBacklog: () -> Void
    var onItemSelcted: (TodoItemModel) -> Void
    var showToast: (String) -> Void
    @State private var isViewActive = false
    @State private var hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if isViewActive {
                Color(.gray100)
                    .ignoresSafeArea()
                
                VStack {
                    TodayTopBar(todayDate: viewModel.currentDate)
                    
                    if isViewActive {
                        if viewModel.todayList.isEmpty {
                            EmptyTodayView(
                                goToBacklog: goToBacklog
                            )
                        } else {
                            TodayListView(
                                todayList: $viewModel.todayList,
                                editToday: { id, content in
                                    Task {
                                        await viewModel.editToday(todoId: id, content: content)
                                    }
                                },
                                swipeToday: { id in
                                    Task {
                                        await viewModel.swipeToday(todoId: id)
                                    }
                                },
                                updateTodoCompletion: { id in
                                    Task {
                                        await viewModel.updateTodoCompletion(todoId: id)
                                        
                                        if viewModel.showThirdGuideBubble { viewModel.showThirdGuideBubble = false }
                                        
                                        if viewModel.checkAllTodoCompleted() {
                                            performDoubleHapticFeedback()
                                            showToast("와우! 수고한 나 자신에게 박수!👏")
                                        }
                                    }
                                },
                                onDragEnd: {
                                    Task {
                                        await viewModel.todayDragAndDrop()
                                    }
                                },
                                onItemSelected: { item in
                                    onItemSelcted(item)
                                },
                                activeItemId: $viewModel.activeItemId,
                                deadlineDateMode: viewModel.deadlineDateMode
                            )
                        }
                    }
                }
                
                if (viewModel.showThirdGuideBubble) {
                    Image("ic_guide_bubble_3")
                        .padding(.top, 85)
                        .padding(.leading, 20)
                }
            } else {
                Color(.gray100)
                    .ignoresSafeArea()
            }
        }
        .onAppear {
            viewModel.currentDate = TimeFormatter.getCurrentMonthDay()
            Task {
                await viewModel.getCategoryList(page: 0, size: 100)
                await viewModel.getTodayList()
                await viewModel.getYesterdayList(page: 0, size: 1)
                await MainActor.run {
                    isViewActive = true
                }
            }
        }
        .onDisappear {
            isViewActive = false
        }
        .onReceive(viewModel.reviewRequest) { _ in
            requestInAppReview()
        }
    }
    
    private func performDoubleHapticFeedback() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            hapticFeedback.impactOccurred()
        }
    }
    
    private func requestInAppReview() {
        guard let scene = UIApplication.shared
                  .connectedScenes
                  .first(where: { $0.activationState == .foregroundActive })
                  as? UIWindowScene else {
            return
        }
        SKStoreReviewController.requestReview(in: scene)
    }
}

struct TodayListView: View {
    @Binding var todayList: [TodayItemModel]
    var editToday: (Int, String) -> Void
    var swipeToday: (Int) -> Void
    var updateTodoCompletion: (Int) -> Void
    var onDragEnd: () -> Void
    var onItemSelected: (TodoItemModel) -> Void
    @Binding var activeItemId: Int?
    @State private var draggedItem: TodayItemModel?
    @State private var draggedIndex: Int?
    @State private var isDragging: Bool = false
    @State private var hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    @State var deadlineDateMode: Bool
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(todayList.indices, id: \.self) { index in
                    let item = todayList[index]
                    
                    TodayItemView(
                        item: $todayList[index],
                        todayList: $todayList,
                        activeItemId: $activeItemId,
                        editToday: editToday,
                        swipeToday: swipeToday,
                        updateTodoCompletion: updateTodoCompletion,
                        onItemSelected: onItemSelected,
                        deadlineDateMode: deadlineDateMode
                    )
                    .onDrag {
                        draggedItem = item
                        isDragging = true
                        return NSItemProvider(object: "\(item.todoId)" as NSString)
                    }
                    .onDrop(of: [.text], delegate: TodayDragDropDelegate(item: item, todayList: $todayList, draggedItem: $draggedItem, onReorder: {
                        isDragging = false
                        onDragEnd()
                    }))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
}

struct TodayItemView: View {
    @Binding var item: TodayItemModel
    @Binding var todayList: [TodayItemModel]
    @Binding var activeItemId: Int?
    var editToday: (Int, String) -> Void
    var swipeToday: (Int) -> Void
    var updateTodoCompletion: (Int) -> Void
    var onItemSelected: (TodoItemModel) -> Void
    let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    @State private var offset: CGFloat = 0
    @State var content = ""
    @State var deadlineDateMode: Bool
    @FocusState var isActive: Bool

    var body: some View {
        HStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                Image(item.todayStatus == "COMPLETED" ? "ic_checked" : "ic_unchecked")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .onTapGesture {
                        updateTodoCompletion(item.todoId)
                        if item.todayStatus == "INCOMPLETE" {
                            hapticFeedback.impactOccurred()
                            moveItemToCompleted()
                        } else {
                            moveItemToIncomplete()
                        }
                    }
                
                VStack(spacing: 8) {
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
                    
                    if item.isRepeat || item.isRoutine || item.deadline != nil { TodayRepeatDeadlineText(deadlineDateMode: deadlineDateMode, item: item) }
                    
                    if item.isBookmark || item.time != nil || item.categoryName != nil { TodayBookmarkTimeCategoryChip(item: item) }
                }
            }
            
            Spacer()
            
            VStack(spacing: 0) {
                Image("ic_dot")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(Color.gray80)
                    .frame(width: 20, height: 20)
                    .padding(.top, !item.isRepeat && !item.isBookmark && item.dDay == nil && item.categoryName == nil ? 3 : 0)
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
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(RoundedRectangle(cornerRadius: 12))
        .foregroundColor(.gray95)
        .offset(x: offset)
        .highPriorityGesture(
            DragGesture(minimumDistance: 20)
                .onChanged { gesture in
                    if item.todayStatus != "COMPLETED" && gesture.translation.width > 0 {
                        self.offset = gesture.translation.width
                    }
                }
                .onEnded { _ in
                    if item.todayStatus != "COMPLETED" {
                        if abs(offset) > 100 {
                            swipeToday(item.todoId)
                            offset = UIScreen.main.bounds.width
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                if let index = todayList.firstIndex(where: { $0.todoId == item.todoId }) {
                                    todayList.remove(at: index)
                                }
                                offset = 0
                            }
                        } else {
                            offset = 0
                        }
                    } else {
                        offset = 0
                    }
                }
        )
    }

    private func moveItemToCompleted() {
        if let index = todayList.firstIndex(where: { $0.todoId == item.todoId }) {
            var updatedItem = item
            updatedItem.todayStatus = "COMPLETED"
            
            todayList.remove(at: index)
            todayList.append(updatedItem)
        }
    }

    private func moveItemToIncomplete() {
        if let index = todayList.firstIndex(where: { $0.todoId == item.todoId }) {
            var updatedItem = item
            updatedItem.todayStatus = "INCOMPLETE"
            
            todayList.remove(at: index)
            
            if let lastIncompleteIndex = todayList.lastIndex(where: { $0.todayStatus == "INCOMPLETE" }) {
                todayList.insert(updatedItem, at: lastIncompleteIndex + 1)
            } else {
                todayList.insert(updatedItem, at: 0)
            }
        }
    }
    
    private func handleSubmit() {
        if !content.isEmpty, let activeItemId {
            item.content = content
            editToday(activeItemId, content)
        }
        isActive = false
        activeItemId = nil
    }
}

struct TodayRepeatDeadlineText: View {
    @State var deadlineDateMode: Bool
    let item: TodayItemModel
    
    var body: some View {
        HStack(spacing: 3) {
            if item.isRepeat {
                Text("일반 반복")
                    .font(PoptatoTypo.xsRegular)
                    .foregroundStyle(Color.gray50)
            }
            
            if item.isRoutine {
                Text(item.routineDays.count == 7 ? "매일" : item.routineDays.joined(separator: ""))
                    .font(PoptatoTypo.xsRegular)
                    .foregroundStyle(Color.gray50)
            }
            
            if (item.isRepeat || item.isRoutine) && item.dDay != nil {
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
                            .frame(height: 12)
                    } else {
                        if dDay == 0 {
                            Text("D-day")
                                .font(PoptatoTypo.xsRegular)
                                .foregroundColor(.gray50)
                                .frame(height: 12)
                        } else if dDay > 0 {
                            Text("D-\(dDay)")
                                .font(PoptatoTypo.xsRegular)
                                .foregroundColor(.gray50)
                                .frame(height: 12)
                        } else {
                            Text("D+\(abs(dDay))")
                                .font(PoptatoTypo.xsRegular)
                                .foregroundColor(.gray50)
                                .frame(height: 12)
                        }
                    }
                    
                }
            }
            
            if item.isRepeat || item.isRoutine || item.dDay != nil { Spacer() }
        }
    }
}

struct TodayBookmarkTimeCategoryChip: View {
    let item: TodayItemModel
    
    var body: some View {
        HStack(spacing: 6) {
            if (item.isBookmark) {
                HStack(spacing: 2) {
                    Image("ic_star_filled")
                        .resizable()
                        .frame(width: 12, height: 12)
                    Text("중요")
                        .font(PoptatoTypo.xsRegular)
                        .foregroundColor(.primary40)
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(Color.gray90)
                .cornerRadius(6)
            }
            
            if let _ = item.time {
                HStack(spacing: 2) {
                    Image("ic_clock")
                        .resizable()
                        .frame(width: 12, height: 12)
                    Text(item.timeString)
                        .font(PoptatoTypo.xsRegular)
                        .foregroundColor(.gray50)
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(Color.gray90)
                .cornerRadius(6)
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
            
            if (item.isBookmark || item.dDay != nil || item.isRepeat || item.categoryName != nil || item.time != nil) { Spacer() }
        }
        .onAppear {
            print("\(item)")
        }
    }
}

struct EmptyTodayView: View {
    var goToBacklog: () -> Void
    
    var body: some View {
        ZStack(alignment: .center) {
            VStack(spacing: 0) {
                Image("ic_fire_today")
                
                Spacer().frame(height: 8)
                
                Text("오늘 할 일은 무엇인가요?")
                    .font(PoptatoTypo.mdMedium)
                    .foregroundColor(.gray70)
                
                Spacer().frame(height: 24)
                
                Button(
                    action: { goToBacklog() }
                ) {
                    HStack {
                        Image("ic_backlog_nav")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.primary100)
                        
                        Text("할 일 가져오기")
                            .font(PoptatoTypo.mdSemiBold)
                            .foregroundColor(.gray95)
                    }
                    .frame(width: 132, height: 37)
                    .background(Color(.primary40))
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
