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
                                .frame(width: 20, height: 20)
                                .onTapGesture {
                                    updateBookmark()
                                }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    
                    HStack {
                        Button(
                            action: {
                                editTodo()
                                withAnimation {
                                    isVisible = false
                                }
                            }
                        ) {
                            Text("수정")
                                .frame(maxWidth: .infinity)
                                .frame(height: 40)
                                .foregroundColor(.gray40)
                                .background(Color(.gray95))
                                .cornerRadius(8)
                        }
                        
                        Button(
                            action: {
                                deleteTodo()
                                withAnimation {
                                    isVisible = false
                                }
                            }
                        ) {
                            Text("삭제")
                                .frame(maxWidth: .infinity)
                                .frame(height: 40)
                                .foregroundColor(.danger40)
                                .cornerRadius(8)
                                .background(Color(.danger40).opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                    
                    Divider()
                        .background(Color(.gray95))
                    
                    if let todo = todoItem {
                        HStack {
                            if todo.deadline == nil {
                                Image("ic_plus")
                                    .onTapGesture {
                                        showDateBottomSheet = true
                                    }
                            } else {
                                Image("ic_minus")
                                    .onTapGesture {
                                        updateDeadline(nil)
                                    }
                            }
                            
                            Text("마감기한")
                                .font(PoptatoTypo.mdMedium)
                                .foregroundColor(.gray40)
                            
                            Spacer()
                            
                            if let deadline = todo.deadline {
                                Text(deadline)
                                    .font(PoptatoTypo.mdMedium)
                                    .foregroundColor(.gray20)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                    }

                    Divider()
                        .background(Color(.gray95))
                    
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

struct DateBottomSheet: View {
    @Binding var item: TodoItemModel?
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedDay = Calendar.current.component(.day, from: Date())
    var onDissmiss: () -> Void
    var updateDeadline: (String?) -> Void

    let years = Array(2000...2100)
    let months = Array(1...12)
    let days = Array(1...31)

    var body: some View {
        VStack {
            Spacer()
            
            VStack {
                HStack(spacing: 20) {
                    Picker("Year", selection: $selectedYear) {
                        ForEach(years, id: \.self) { year in
                            Text(String(year))
                                .tag(year)
                                .font(PoptatoTypo.xLSemiBold)
                                .foregroundColor(.gray00)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .pickerStyle(WheelPickerStyle())
                    
                    Picker("Month", selection: $selectedMonth) {
                        ForEach(months, id: \.self) { month in
                            Text("\(month)")
                                .tag(month)
                                .font(PoptatoTypo.xLSemiBold)
                                .foregroundColor(.gray00)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .pickerStyle(WheelPickerStyle())
                    
                    Picker("Day", selection: $selectedDay) {
                        ForEach(days(for: selectedYear, month: selectedMonth), id: \.self) { day in
                            Text("\(day)")
                                .tag(day)
                                .font(PoptatoTypo.xLSemiBold)
                                .foregroundColor(.gray00)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .pickerStyle(WheelPickerStyle())
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 40)
                
                HStack {
                    Button(
                        action: {
                            onDissmiss()
                        }
                    ) {
                        Text("취소")
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .foregroundColor(.gray40)
                            .background(Color(.gray95))
                            .cornerRadius(8)
                    }
                    
                    Button(
                        action: {
                            let deadline = "\(String(selectedYear))-\(selectedMonth)-\(selectedDay)"
                            updateDeadline(deadline)
                            onDissmiss()
                        }
                    ) {
                        Text("확인")
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .foregroundColor(.gray100)
                            .cornerRadius(8)
                            .background(Color(.primary60))
                            .cornerRadius(8)
                    }
                    
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 300)
            .background(Color(UIColor.gray100))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(radius: 10)
        }
    }
    
    private func days(for year: Int, month: Int) -> [Int] {
        var components = DateComponents()
        components.year = year
        components.month = month
        
        let calendar = Calendar.current
        let date = calendar.date(from: components) ?? Date()
        let range = calendar.range(of: .day, in: .month, for: date) ?? (1..<32)
        return Array(range)
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
