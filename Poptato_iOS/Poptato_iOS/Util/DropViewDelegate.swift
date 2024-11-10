//
//  DropViewDelegate.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 11/10/24.
//
import SwiftUI

struct DropViewDelegate: DropDelegate {
    var item: TodoItemModel
    @Binding var backlogList: [TodoItemModel]
    @Binding var draggedItem: TodoItemModel?
    @Binding var draggedIndex: Int?
    var onReorder: () -> Void
    
    func dropEntered(info: DropInfo) {
        guard let fromIndex = draggedIndex else { return }
        
        if let toIndex = backlogList.firstIndex(where: { $0.todoId == item.todoId }), toIndex != fromIndex {
            withAnimation {
                backlogList.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
                self.draggedIndex = toIndex
            }
        }
    }
    
    func performDrop(info: DropInfo) -> Bool {
        self.draggedItem = nil
        self.draggedIndex = nil
        onReorder()
        return true
    }
}

struct TodayDropViewDelegate: DropDelegate {
    var item: TodayItemModel
    @Binding var todayList: [TodayItemModel]
    @Binding var draggedItem: TodayItemModel?
    @Binding var draggedIndex: Int?
    var onReorder: () -> Void
    
    func dropEntered(info: DropInfo) {
        guard let fromIndex = draggedIndex else { return }
        
        if let toIndex = todayList.firstIndex(where: { $0.todoId == item.todoId }), toIndex != fromIndex {
            withAnimation {
                todayList.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
                self.draggedIndex = toIndex
            }
        }
    }
    
    func performDrop(info: DropInfo) -> Bool {
        self.draggedItem = nil
        self.draggedIndex = nil
        onReorder()
        return true
    }
}
