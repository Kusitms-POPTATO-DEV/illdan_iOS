//
//  BottomSheetView.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/26/24.
//

import SwiftUI

struct BottomSheetView: View {
    @Binding var isVisible: Bool
    @Binding var todoItem: TodoItemModel?
    @Binding var showDateBottomSheet: Bool
    @Binding var showCategoryBottomSheet: Bool
    var deleteTodo: () -> Void
    var editTodo: () -> Void
    var updateBookmark: () -> Void
    var updateDeadline: (String?) -> Void
    var updateTodoRepeat: () -> Void
    var updateCategory: (Int?) -> Void
    var categoryList: [CategoryModel]
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()

                VStack {
                    HStack {
                        if let todo = todoItem {
                            Text(todo.content)
                                .font(PoptatoTypo.xLMedium)
                                .foregroundColor(.gray00)
                                .lineLimit(1)
                            Spacer()
                            Image(todo.isBookmark ? "ic_star_filled" : "ic_star_empty")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .onTapGesture {
                                    AnalyticsManager.shared.logEvent(AnalyticsEvent.set_important, parameters: ["task_id" : todoItem?.todoId ?? -1])
                                    updateBookmark()
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    HStack(spacing: 16) {
                        EditDeleteButtonView(
                            image: "ic_pen",
                            title: "수정하기",
                            onClickButton: {
                                AnalyticsManager.shared.logEvent(AnalyticsEvent.edit_task)
                                isVisible = false
                                editTodo()
                            }
                        )
                        
                        EditDeleteButtonView(
                            image: "ic_trash",
                            title: "삭제하기",
                            onClickButton: {
                                AnalyticsManager.shared.logEvent(AnalyticsEvent.delete_task, parameters: ["task_id" : todoItem?.todoId ?? -1])
                                isVisible = false
                                deleteTodo()
                            }
                        )
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    
                    Spacer().frame(height: 20)
                    
                    BottomSheetButton(
                        image: "ic_refresh",
                        buttonText: "반복 할 일",
                        buttonColor: .gray30,
                        subText: "",
                        onClickBtn: {
                            AnalyticsManager.shared.logEvent(AnalyticsEvent.set_repeat, parameters: ["task_id" : todoItem?.todoId ?? -1])
                        },
                        isRepeat: Binding(
                            get: { todoItem?.isRepeat ?? false },
                            set: { newValue in
                                todoItem?.isRepeat = newValue
                                updateTodoRepeat()
                            }
                        )
                    )
                    BottomSheetButton(
                        image: "ic_cal",
                        buttonText: "마감기한",
                        buttonColor: .gray30,
                        subText: todoItem?.deadline ?? "설정하기",
                        onClickBtn: { showDateBottomSheet = true },
                        isRepeat: Binding(
                            get: { todoItem?.isRepeat ?? false },
                            set: { newValue in
                                todoItem?.isRepeat = newValue
                            }
                        )
                    )
                    
                    BottomSheetButton(
                        image: "ic_add_emoji",
                        buttonText: "카테고리",
                        buttonColor: .gray30,
                        onClickBtn: { showCategoryBottomSheet = true },
                        categoryName: todoItem?.categoryName ?? "",
                        emojiImageUrl: todoItem?.emojiImageUrl ?? "",
                        isRepeat: Binding(
                            get: { todoItem?.isRepeat ?? false },
                            set: { newValue in
                                todoItem?.isRepeat = newValue
                            }
                        )
                    )
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color(UIColor.gray100))
                .clipShape(RoundedCorner(radius: 24))
            }
            
            if showDateBottomSheet {
                DateBottomSheet(
                    item: $todoItem,
                    onDissmiss: { showDateBottomSheet = false },
                    updateDeadline: updateDeadline
                )
            }
            
            if showCategoryBottomSheet {
                CategoryBottomSheet(
                    categoryList: categoryList,
                    onDismiss: { showCategoryBottomSheet = false },
                    updateCategory: { id in
                        updateCategory(id)
                    },
                    selectedCategoryId: todoItem?.categoryId
                )
            }
        }
        .padding(.horizontal, 16)
    }
}

struct BottomSheetButton: View {
    var image: String
    var buttonText: String
    var buttonColor: Color
    var subText: String = ""
    var onClickBtn: () -> Void
    var categoryName: String = ""
    var emojiImageUrl: String = ""
    @Binding var isRepeat: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            Image(image)
                .resizable()
                .frame(width: 20, height: 20)
            Spacer().frame(width: 8)
            Text(buttonText)
                .font(PoptatoTypo.mdRegular)
                .foregroundColor(buttonColor)
            Spacer()
            if buttonText == "반복 할 일" {
                Toggle("", isOn: $isRepeat)
                    .tint(isRepeat ? Color.primary40 : Color.gray80)
            }
            if !subText.isEmpty {
                Text(subText)
                    .font(PoptatoTypo.mdRegular)
                    .foregroundColor(.gray60)
            } else if !categoryName.isEmpty {
                HStack(alignment: .center, spacing: 4) {
                    PDFImageView(imageURL: emojiImageUrl, width: 20, height: 20)
                    Text(categoryName)
                        .font(PoptatoTypo.mdMedium)
                        .foregroundColor(.gray00)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.gray90)
                .cornerRadius(32)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.clear)
        .contentShape(Rectangle())
        .onTapGesture {
            onClickBtn()
        }
    }
}

struct DateBottomSheet: View {
    @Binding var item: TodoItemModel?
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedDay: Int? = Calendar.current.component(.day, from: Date())
    @State private var days: [Int?] = []
    var onDissmiss: () -> Void
    var updateDeadline: (String?) -> Void

    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 0) {
                Spacer().frame(height: 24)
                
                BottomSheetDateNavigatorView(
                    year: selectedYear,
                    month: selectedMonth,
                    onClickIncreaseMonth: {
                        AnalyticsManager.shared.logEvent(AnalyticsEvent.check_month)
                        if selectedMonth == 12 { selectedMonth = 1; selectedYear += 1 }
                        else { selectedMonth += 1 }
                        generateCalendarDays()
                    },
                    onClickDecreaseMonth: {
                        AnalyticsManager.shared.logEvent(AnalyticsEvent.check_month)
                        if selectedMonth == 1 { selectedMonth = 12; selectedYear -= 1 }
                        else { selectedMonth -= 1 }
                        generateCalendarDays()
                    }
                )
                
                Spacer().frame(height: 16)
                
                BottomSheetCalendarView(
                    days: days,
                    selectedDay: $selectedDay,
                    onDissmiss: onDissmiss,
                    updateDeadline: {
                        if let day = selectedDay {
                            let formattedMonth = String(format: "%02d", selectedMonth)
                            let formattedDay = String(format: "%02d", day)
                            let deadline = "\(String(selectedYear))-\(formattedMonth)-\(formattedDay)"
                            AnalyticsManager.shared.logEvent(
                                AnalyticsEvent.set_dday,
                                parameters: [
                                    "set_date" : TimeFormatter.currentDateString(),
                                    "dday" : deadline,
                                    "task_id" : item?.todoId ?? -1
                                ]
                            )
                            updateDeadline(deadline)
                        }
                    },
                    onClickBtnDelete: { updateDeadline(nil) }
                )
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 30)
            .fixedSize(horizontal: false, vertical: true)
            .background(Color(UIColor.gray100))
            .clipShape(RoundedCorner(radius: 24))
        }
        .onAppear {
            initializeSelectedDate()
            generateCalendarDays()
        }
    }
    
    func initializeSelectedDate() {
        guard let deadline = item?.deadline else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        
        if let date = formatter.date(from: deadline) {
            let calendar = Calendar.current
            selectedYear = calendar.component(.year, from: date)
            selectedMonth = calendar.component(.month, from: date)
            selectedDay = calendar.component(.day, from: date)
        }
    }
    
    func generateCalendarDays() {
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: selectedYear, month: selectedMonth)
        guard let firstDayOfMonth = calendar.date(from: dateComponents) else { return }
        let weekday = calendar.component(.weekday, from: firstDayOfMonth)

        days = Array(repeating: nil, count: weekday - 1)

        if let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth) {
            days += range.map { Optional($0) }
        }
    }
}

struct BottomSheetCalendarView: View {
    var days: [Int?]
    @Binding var selectedDay: Int?
    var onDissmiss: () -> Void
    var updateDeadline: () -> Void
    var onClickBtnDelete: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                ForEach(["일", "월", "화", "수", "목", "금", "토"], id: \.self) { day in
                    Text(day)
                        .font(PoptatoTypo.xsRegular)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.gray60)
                }
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(Array(days.enumerated()), id: \.offset) { index, date in
                    if let date = date {
                        Text("\(date)")
                            .frame(width: 32, height: 32)
                            .font(PoptatoTypo.smMedium)
                            .foregroundColor(selectedDay == date ? .gray100 : .gray10)
                            .background(
                                Rectangle()
                                    .fill(selectedDay == date ? Color.primary40 : Color.gray100)
                                    .cornerRadius(8)
                            )
                            .onTapGesture {
                                AnalyticsManager.shared.logEvent(AnalyticsEvent.check_date)
                                selectedDay = date
                            }
                    } else {
                        Text("")
                            .frame(width: 32, height: 32)
                    }
                }
            }
            
            Spacer().frame(height: 24)
            
            BottomSheetActionButton(
                positiveText: "완료",
                negativeText: "삭제",
                onClickBtnPositive: {
                    updateDeadline()
                    onDissmiss()
                },
                onClickBtnNegative: {
                    onClickBtnDelete()
                    onDissmiss()
                }
            )
            
            Spacer().frame(height: 16)
        }
    }
}

struct BottomSheetDateNavigatorView: View {
    let year: Int
    let month: Int
    
    var onClickIncreaseMonth: () -> Void
    var onClickDecreaseMonth: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            
            Image("ic_arrow_left")
                .renderingMode(.template)
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(.gray40)
                .onTapGesture {
                    onClickDecreaseMonth()
                }
            
            Spacer()
            
            Text("\(String(format: "%d", year))년 \(String(format: "%2d", month))월")
                .font(PoptatoTypo.mdMedium)
                .foregroundColor(.gray00)
            
            Spacer()
            
            Image("ic_arrow_right")
                .renderingMode(.template)
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(.gray40)
                .onTapGesture {
                    onClickIncreaseMonth()
                }
        }
        .frame(maxWidth: .infinity)
    }
}

struct CategoryBottomSheet: View {
    var categoryList: [CategoryModel]
    var onDismiss: () -> Void
    var updateCategory: (Int?) -> Void
    @State var selectedCategoryId: Int?
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack {
                if categoryList.isEmpty {
                    Spacer()
                    Text("생성된\n카테고리가 없어요.")
                        .font(PoptatoTypo.lgMedium)
                        .foregroundColor(.gray80)
                        .multilineTextAlignment(.center)
                    Spacer()
                } else {
                    Spacer().frame(height: 24)
                    ScrollView {
                        LazyVStack {
                            ForEach(categoryList, id: \.id) { category in
                                HStack(alignment: .center, spacing: 0) {
                                    Spacer().frame(width: 24)
                                    if category.id == -1 {
                                        Image("ic_category_all")
                                            .resizable()
                                            .frame(width: 24, height: 24)
                                    } else if category.id == 0 {
                                        Image("ic_category_bookmark")
                                            .resizable()
                                            .frame(width: 24, height: 24)
                                    } else {
                                        PDFImageView(imageURL: category.imageUrl, width: 24, height: 24)
                                    }
                                   
                                    Spacer().frame(width: 8)
                                    Text(category.name)
                                        .font(PoptatoTypo.mdMedium)
                                        .foregroundColor(.gray00)
                                    Spacer()
                                    if selectedCategoryId != nil && category.id == selectedCategoryId {
                                        Image("ic_check")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                    }
                                    Spacer().frame(width: 24)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(category.id == selectedCategoryId ? Color.gray90 : Color.gray100)
                                .onTapGesture {
                                    if selectedCategoryId == category.id {
                                        selectedCategoryId = nil
                                    } else {
                                        selectedCategoryId = category.id
                                    }
                                }
                            }
                        }
                    }
                    Spacer().frame(height: 16)
                    BottomSheetActionButton(
                        positiveText: "완료",
                        negativeText: "취소",
                        onClickBtnPositive: {
                            AnalyticsManager.shared.logEvent(AnalyticsEvent.set_category)
                            updateCategory(selectedCategoryId)
                            onDismiss()
                        },
                        onClickBtnNegative: { onDismiss() }
                    )
                    Spacer().frame(height: 16)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 392)
            .background(Color(UIColor.gray100))
            .clipShape(RoundedCorner(radius: 16, corners: [.topLeft, .topRight]))
        }
    }
}

struct BottomSheetActionButton: View {
    var positiveText: String
    var negativeText: String
    var onClickBtnPositive: () -> Void
    var onClickBtnNegative: () -> Void
    
    var body: some View {
        HStack {
            Button(
                action: {
                    onClickBtnNegative()
                }
            ) {
                Text(negativeText)
                    .font(PoptatoTypo.mdMedium)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .foregroundColor(.gray50)
                    .background(Color(.gray95))
                    .cornerRadius(8)
            }
            
            Button(
                action: {
                    onClickBtnPositive()
                }
            ) {
                Text(positiveText)
                    .font(PoptatoTypo.mdSemiBold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .foregroundColor(.gray90)
                    .background(Color(.primary40))
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

struct EditDeleteButtonView: View {
    let image: String
    let title: String
    
    var onClickButton: () -> Void
    
    var body: some View {
        Button(action: onClickButton) {
            HStack(spacing: 4) {
                Image(image)
                    .resizable()
                    .frame(width: 20, height: 20)
                
                Text(title)
                    .font(PoptatoTypo.mdMedium)
                    .foregroundStyle(Color.gray30)
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(Color.gray95)
            .clipShape(RoundedCorner(radius: 12))
        }
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = 16
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
