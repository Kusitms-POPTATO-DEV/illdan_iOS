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

struct CategoryDragDropDelegate: DropDelegate {
    let item: CategoryModel
    @Binding var categoryList: [CategoryModel]
    @Binding var draggedItem: CategoryModel?
    var onReorder: () -> Void
    
    func dropEntered(info: DropInfo) {
        guard let draggedItem = draggedItem, draggedItem.id != item.id else {
            return
        }
        
        if item.id == -1 || item.id == 0 {
            self.draggedItem = nil
            return
        }
        
        if let fromIndex = categoryList.firstIndex(where: { $0.id == draggedItem.id }),
           let toIndex = categoryList.firstIndex(where: { $0.id == item.id }) {
            if toIndex == 0 || toIndex == 1 {
                self.draggedItem = nil
                onReorder()
                return
            }
            withAnimation {
                categoryList.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
                onReorder()
            }
        }
    }
    
    func performDrop(info: DropInfo) -> Bool {
        draggedItem = nil
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
