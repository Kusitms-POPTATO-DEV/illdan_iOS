//
//  RoutineBottomSheet.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 5/23/25.
//

import SwiftUI

struct RoutineBottomSheet: View {
    @State private var routineType: RoutineType = .WEEKDAY
    @State private var isOn: Bool = false
    @State var activeWeekdays: Set<Int> = []
    
    var updateTodoRoutine: (Set<Int>?) -> Void
    var updateTodoRepeat: (Bool) -> Void
    var onDismissRequest: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 0) {
                Spacer().frame(height: 24)
                
                RoutineTypeSelectorView(selectedType: $routineType)
                
                Spacer().frame(height: 32)
                
                switch routineType {
                case .WEEKDAY:
                    FullWeekToggleView(isOn: $isOn, onClickToggle: { newValue in
                        if newValue { activeWeekdays.formUnion(0...6) }
                        else {
                            if activeWeekdays.count == 7 {
                                activeWeekdays.removeAll()
                            }
                        }
                    })
                    
                    Spacer().frame(height: 20)
                    
                    WeekdayChipView(activeWeekdays: $activeWeekdays, onClickWeekdayChip: { newValue in
                        if activeWeekdays.contains(newValue) { activeWeekdays.remove(newValue) }
                        else { activeWeekdays.insert(newValue) }
                    })
                case .GENERAL:
                    GeneralRoutineGuideView()
                }
                
                Spacer().frame(height: 40)
                
                BottomSheetActionButton(
                    positiveText: "완료",
                    negativeText: "삭제",
                    onClickBtnPositive: {
                        if routineType == RoutineType.WEEKDAY {
                            updateTodoRoutine(activeWeekdays)
                        } else {
                            updateTodoRepeat(true)
                        }
                        
                        onDismissRequest()
                    },
                    onClickBtnNegative: {
                        if routineType == RoutineType.WEEKDAY {
                            updateTodoRoutine(nil)
                        } else {
                            updateTodoRepeat(false)
                        }
                        
                        onDismissRequest()
                    }
                )
                
                Spacer().frame(height: 20)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .background(Color.gray100)
            .clipShape(RoundedCorner(radius: 24))
            .onChange(of: activeWeekdays.count) { count in
                isOn = count == 7
            }
        }
    }
}

private struct FullWeekToggleView: View {
    @Binding var isOn: Bool
    
    var onClickToggle: (Bool) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Text("매일")
                .font(PoptatoTypo.lgMedium)
                .foregroundStyle(Color.gray00)
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SmallToggleStyle())
                .tint(isOn ? Color.primary40 : Color.gray80)
                .onChange(of: isOn) { newValue in
                    onClickToggle(newValue)
                }
            
            Spacer()
        }
    }
}

private struct WeekdayChipView: View {
    @Binding var activeWeekdays: Set<Int>
    
    private let weekdays = ["월", "화", "수", "목", "금", "토", "일"]
    
    var onClickWeekdayChip: (Int) -> Void
    
    var body: some View {
        HStack {
            ForEach(Array(weekdays.enumerated()), id: \.offset) { index, day in
                let isSelected = activeWeekdays.contains(index)
                
                Text(day)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 9)
                    .background(isSelected ? Color.primary40 : Color.gray95)
                    .foregroundStyle(isSelected ? Color.gray90 : Color.gray50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .onTapGesture {
                        onClickWeekdayChip(index)
                    }
                
                if index != 6 { Spacer() }
            }
        }
    }
}

private struct RoutineTypeSelectorView: View {
    @Binding var selectedType: RoutineType
    
    var body: some View {
        HStack(spacing: 8) {
            Text(RoutineType.WEEKDAY.name)
                .font(PoptatoTypo.smMedium)
                .foregroundStyle(selectedType == RoutineType.WEEKDAY ? Color.primary40 : Color.gray50)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(selectedType == RoutineType.WEEKDAY ? Color.primary30 : Color.gray70, lineWidth: 1)
                )
                .onTapGesture {
                    selectedType = RoutineType.WEEKDAY
                }
            
            Text(RoutineType.GENERAL.name)
                .font(PoptatoTypo.smMedium)
                .foregroundStyle(selectedType == RoutineType.GENERAL ? Color.primary40 : Color.gray50)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(selectedType == RoutineType.GENERAL ? Color.primary30 : Color.gray70, lineWidth: 1)
                )
                .onTapGesture {
                    selectedType = RoutineType.GENERAL
                }
            Spacer()
        }
    }
}

private struct GeneralRoutineGuideView: View {
    var body: some View {
        Text("불규칙하게 반복되는 할 일에 설정하세요.\n완료해도 할 일이 사라지지 않아요.")
            .font(PoptatoTypo.mdRegular)
            .foregroundStyle(Color.gray50)
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
            .padding(.horizontal,  16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray95)
            )
    }
}
