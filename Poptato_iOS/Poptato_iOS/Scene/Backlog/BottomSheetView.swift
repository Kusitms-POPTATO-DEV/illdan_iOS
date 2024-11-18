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
    @State private var showDateBottomSheet: Bool = false
    var deleteTodo: () -> Void
    var editTodo: () -> Void
    var updateBookmark: () -> Void
    var updateDeadline: (String?) -> Void
    
    var body: some View {
        ZStack{
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
                            Image(todo.bookmark ? "ic_star_filled" : "ic_star_empty")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .onTapGesture {
                                    updateBookmark()
                                }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    
                    BottomSheetButton(image: "ic_pen", buttonText: "수정하기", buttonColor: .gray30, subText: "", onClickBtn: {
                        isVisible = false
                        editTodo()
                    })
                    BottomSheetButton(image: "ic_trash", buttonText: "삭제하기", buttonColor: .danger50, subText: "", onClickBtn: {
                        isVisible = false
                        deleteTodo()
                    })
                    BottomSheetButton(image: "ic_cal", buttonText: "마감기한", buttonColor: .gray30, subText: todoItem?.deadline ?? "설정하기", onClickBtn: { showDateBottomSheet = true })
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .background(Color(UIColor.gray100))
                .clipShape(RoundedCorner(radius: 16, corners: [.topLeft, .topRight]))
            }
            
            if showDateBottomSheet {
                DateBottomSheet(
                    item: $todoItem,
                    onDissmiss: { showDateBottomSheet = false },
                    updateDeadline: updateDeadline
                )
            }
        }
    }
}

struct BottomSheetButton: View {
    var image: String
    var buttonText: String
    var buttonColor: Color
    var subText: String
    var onClickBtn: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            Image(image)
            Spacer().frame(width: 8)
            Text(buttonText)
                .font(PoptatoTypo.mdRegular)
                .foregroundColor(buttonColor)
            Spacer()
            Text(subText)
                .font(PoptatoTypo.mdRegular)
                .foregroundColor(.gray60)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
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
                DateNavigatorView(
                    year: selectedYear,
                    month: selectedMonth,
                    onClickIncreaseMonth: {
                        if selectedMonth == 12 { selectedMonth = 1; selectedYear += 1 }
                        else { selectedMonth += 1 }
                        generateCalendarDays()
                    },
                    onClickDecreaseMonth: {
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
                            updateDeadline(deadline)
                        }
                    },
                    onClickBtnDelete: { updateDeadline(nil) }
                )
            }
            .frame(maxWidth: .infinity)
            .fixedSize(horizontal: false, vertical: true)
            .background(Color(UIColor.gray100))
            .clipShape(RoundedCorner(radius: 16, corners: [.topLeft, .topRight]))
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
            .padding(.horizontal, 24)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(Array(days.enumerated()), id: \.offset) { index, date in
                    if let date = date {
                        Text("\(date)")
                            .frame(width: 32, height: 32)
                            .font(PoptatoTypo.smMedium)
                            .foregroundColor(selectedDay == date ? .gray100 : .gray70)
                            .background(
                                Rectangle()
                                    .fill(selectedDay == date ? Color.primary60 : Color.gray100)
                                    .cornerRadius(8)
                            )
                            .onTapGesture {
                                selectedDay = date
                            }
                    } else {
                        Text("")
                            .frame(width: 32, height: 32)
                    }
                }
            }
            .padding(.horizontal, 24)
            
            Spacer().frame(height: 24)
            
            HStack {
                Button(
                    action: {
                        onClickBtnDelete()
                        onDissmiss()
                    }
                ) {
                    Text("삭제")
                        .font(PoptatoTypo.mdMedium)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .foregroundColor(.gray40)
                        .background(Color(.gray95))
                        .cornerRadius(8)
                }
                
                Button(
                    action: {
                        updateDeadline()
                        onDissmiss()
                    }
                ) {
                    Text("확인")
                        .font(PoptatoTypo.mdSemiBold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .foregroundColor(.gray100)
                        .background(Color(.primary60))
                        .cornerRadius(8)
                }
                
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
            
            Spacer().frame(height: 16)
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
