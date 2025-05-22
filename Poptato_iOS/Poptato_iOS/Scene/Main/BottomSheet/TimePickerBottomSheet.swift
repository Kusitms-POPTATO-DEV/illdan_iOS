//
//  TimePickerBottomSheet.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 5/23/25.
//

import SwiftUI

struct TimePickerBottomSheet: View {
    @State var selectedMeridiem: String = ""
    @State var selectedHour: Int = 1
    @State var selectedMinute: Int = 0
    
    private let meridiems = ["오전", "오후"]
    private let hours = Array(1...12)
    private let minutes = stride(from: 0, through: 55, by: 5).map { $0 }
    
    var updateTodoTime: (TimeInfo?) -> Void
    var onDismissRequest: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 0) {
                Spacer().frame(height: 24)
                
                HStack {
                    CustomScrollPicker(
                        items: meridiems,
                        selected: $selectedMeridiem
                    )
                    .frame(width: 82)
                    
                    CustomScrollPicker(
                        items: hours.map { String(format: "%02d", $0) },
                        selected: Binding(
                            get: { String(format: "%02d", selectedHour) },
                            set: { selectedHour = Int($0) ?? selectedHour }
                        )
                    )
                    .frame(width: 82)

                    CustomScrollPicker(
                        items: minutes.map { String(format: "%02d", $0) },
                        selected: Binding(
                            get: { String(format: "%02d", selectedMinute) },
                            set: { selectedMinute = Int($0) ?? selectedMinute }
                        )
                    )
                    .frame(width: 82)
                }
                
                Spacer().frame(height: 32)
                
                BottomSheetActionButton(
                    positiveText: "완료",
                    negativeText: "삭제",
                    onClickBtnPositive: {
                        updateTodoTime(TimeInfo(meridiem: selectedMeridiem, hour: selectedHour, minute: selectedMinute))
                        onDismissRequest()
                    },
                    onClickBtnNegative: {
                        updateTodoTime(nil)
                        onDismissRequest()
                    }
                )
                
                Spacer().frame(height: 20)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, maxHeight: 221)
            .background(Color.gray100)
            .clipShape(RoundedCorner(radius: 24))
        }
    }
}

struct CustomScrollPicker: View {
    let items: [String]
    @Binding var selected: String

    @State private var itemOffsets: [Int: CGFloat] = [:]
    @State private var scrollViewHeight: CGFloat = 0
    @State private var snapWorkItem: DispatchWorkItem?

    var body: some View {
        GeometryReader { geo in
            let centerY = geo.size.height / 2

            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 8) {
                        ForEach(items.indices, id: \.self) { idx in
                            Text(items[idx])
                                .font(PoptatoTypo.lgBold)
                                .foregroundColor(isCentered(idx: idx, centerY: centerY)
                                                 ? Color.gray00
                                                 : Color.gray60)
                                .frame(height: 27)
                                .frame(maxWidth: .infinity)
                                .scaleEffect(isCentered(idx: idx, centerY: centerY) ? 1.1 : 1.0)
                                .id(idx)
                                .background(GeometryReader { itemGeo in
                                    Color.clear.preference(
                                        key: ItemOffsetKey.self,
                                        value: [idx: itemGeo
                                            .frame(in: .named("picker")).midY]
                                    )
                                })
                        }
                    }
                    .padding(.vertical, 27)
                }
                .coordinateSpace(name: "picker")
                .onAppear {
                    scrollViewHeight = geo.size.height
                }
                .onPreferenceChange(ItemOffsetKey.self) { offsets in
                    itemOffsets = offsets

                    snapWorkItem?.cancel()

                    let work = DispatchWorkItem {
                        guard !offsets.isEmpty else { return }
                        let nearest = offsets.min {
                            abs($0.value - centerY) < abs($1.value - centerY)
                        }!
                        let newIndex = nearest.key

                        selected = items[newIndex]
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo(newIndex, anchor: .center)
                        }
                    }
                    snapWorkItem = work

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: work)
                }
            }
        }
    }

    private func isCentered(idx: Int, centerY: CGFloat) -> Bool {
        return items[idx] == selected
    }
}

private struct ItemOffsetKey: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]
    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}
