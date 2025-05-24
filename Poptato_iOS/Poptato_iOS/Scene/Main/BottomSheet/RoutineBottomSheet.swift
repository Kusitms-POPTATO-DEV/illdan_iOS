//
//  RoutineBottomSheet.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 5/23/25.
//

import SwiftUI

struct RoutineBottomSheet: View {
    @State var activeWeekdays: Set<Int> = []
    
    var updateActiveWeekdays: (Set<Int>?) -> Void
    var onClickToggle: (Bool) -> Void
    var onClickWeekdayChip: (Int) -> Void
    var onDismissRequest: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 0) {
                Spacer().frame(height: 24)
                
                FullWeekToggleView(onClickToggle: onClickToggle)
                
                Spacer().frame(height: 20)
                
                WeekdayChipView(activeWeekdays: activeWeekdays, onClickWeekdayChip: onClickWeekdayChip)
                
                Spacer().frame(height: 32)
                
                BottomSheetActionButton(
                    positiveText: "완료",
                    negativeText: "삭제",
                    onClickBtnPositive: {
                        updateActiveWeekdays(activeWeekdays)
                        onDismissRequest()
                    },
                    onClickBtnNegative: {
                        updateActiveWeekdays(nil)
                        onDismissRequest()
                    }
                )
                
                Spacer().frame(height: 20)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .background(Color.gray100)
            .clipShape(RoundedCorner(radius: 24))
        }
    }
}

private struct FullWeekToggleView: View {
    @State var isOn: Bool = false
    
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
    @State var activeWeekdays: Set<Int>
    
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
