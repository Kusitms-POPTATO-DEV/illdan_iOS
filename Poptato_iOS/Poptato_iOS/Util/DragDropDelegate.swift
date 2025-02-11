//
//  DragDropDelegate.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 2/6/25.
//

import SwiftUI

struct DragDropDelegate: DropDelegate {
    let item: TodoItemModel
    @Binding var backlogList: [TodoItemModel]
    @Binding var draggedItem: TodoItemModel?
    var onReorder: () -> Void
    
    func dropEntered(info: DropInfo) {
        guard let draggedItem = draggedItem, draggedItem.todoId != item.todoId else {
            return
        }

        if let fromIndex = backlogList.firstIndex(where: { $0.todoId == draggedItem.todoId }),
           let toIndex = backlogList.firstIndex(where: { $0.todoId == item.todoId }) {
            withAnimation {
                backlogList.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
            }
        }
    }

    func performDrop(info: DropInfo) -> Bool {
        draggedItem = nil
        onReorder()
        return true
    }
}

struct TodayDragDropDelegate: DropDelegate {
    let item: TodayItemModel
    @Binding var todayList: [TodayItemModel]
    @Binding var draggedItem: TodayItemModel?
    var onReorder: () -> Void
    
    func dropEntered(info: DropInfo) {
        guard let draggedItem = draggedItem, draggedItem.todoId != item.todoId else {
            return
        }
        
        if let fromIndex = todayList.firstIndex(where: { $0.todoId == draggedItem.todoId }),
           let toIndex = todayList.firstIndex(where: { $0.todoId == item.todoId }) {
            if todayList[fromIndex].todayStatus == "COMPLETED" || todayList[toIndex].todayStatus == "COMPLETED" { return }
            withAnimation {
                todayList.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
            }
        }
    }
    
    func performDrop(info: DropInfo) -> Bool {
        draggedItem = nil
        onReorder()
        return true
    }
}
