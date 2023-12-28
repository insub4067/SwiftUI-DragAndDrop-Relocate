//
//  ContentView.swift
//  SwiftUIPractice
//
//  Created by 김인섭 on 12/21/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    
    @State var items: [Item] = []
    @State var currentDrag: Item? = .none
    
    var body: some View {
        ScrollView {
            LazyVStack(content: {
                ForEach(items, id: \.id) { item in
                    Text("Placeholder \(item.id)")
                        .frame(height: 100)
                        .padding(.horizontal, 24)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke()
                        }
                        .dragAndDrop(
                            item: item,
                            items: $items,
                            currentDragging: $currentDrag
                        )
                }
            })
        }
        .onAppear { self.items = Array(1...30).map { Item(id: $0) } }
    }
}

struct Item: Equatable, Identifiable {
    var id: Int
}

public struct DragRelocateDelegate<Item: Equatable>: DropDelegate where Item: Identifiable {
    
    let item: Item
    @Binding var items: [Item]
    @Binding var current: Item?
    
    public init(
        item: Item,
        items: Binding<[Item]>,
        current: Binding<Item?> = .constant(nil))
    {
        self.item = item
        self._items = items
        self._current = current
    }

    public func dropEntered(info: DropInfo) {
        guard item != current else { return }
        DispatchQueue.main.async {
            withAnimation {
                let from = items.firstIndex(of: current!)!
                let to = items.firstIndex(of: item)!
                if items[to].id != current!.id {
                    items.move(fromOffsets: IndexSet(integer: from),
                        toOffset: to > from ? to + 1 : to)
                }
            }
        }
    }

    public func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    public func performDrop(info: DropInfo) -> Bool {
        self.current = nil
        return true
    }
}

public extension View {
    
    @ViewBuilder func dragAndDrop<Item: Equatable & Identifiable> (
        _ state: Bool = true,
        item: Item,
        items: Binding<[Item]>,
        currentDragging: Binding<Item?>
    ) -> some View {
        if state {
            self
                .onDrag({
                    currentDragging.wrappedValue = item
                    return NSItemProvider(object: "\(item.id)" as NSString)
                })
                .onDrop(
                    of: [UTType.text],
                    delegate: DragRelocateDelegate(
                        item: item,
                        items: items,
                        current: currentDragging
                    )
                )
        } else {
            self
        }
    }
}

#Preview {
    ContentView()
}
