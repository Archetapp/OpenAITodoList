//
//  TodoRow.swift
//  Taskr
//
//  Created by Jared Davidson on 1/20/24.
//

import Foundation
import SwiftUI

struct TodoRow: View {
    @ObservedObject var taskGenerator: TaskGenerator
    @Binding var todo: Todo
    @State private var removeFlag = false
    @State private var removalWorkItem: DispatchWorkItem?
    
    @Environment(\.openURL) var openURL

    var body: some View {
        VStack(alignment: .leading) {
            Button {
                // Toggle the completion status when the cell is tapped
                todo.completed.toggle()
            } label: {
                HStack(alignment: .top) {
                    Image(systemName: todo.completed ? "checkmark.square" : "square")
                        .resizable()
                        .frame(width: 20, height: 20)
                    
                    Text(todo.task)
                        .foregroundColor(todo.completed ? .gray : .black)
                        .strikethrough(todo.completed)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
            }
            .buttonStyle(.plain)
            if let link = todo.link {
                Link(link, destination: URL(string: link)!)
                    .font(.caption)
                    .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                    .foregroundStyle(Color.white)
                    .background(Color("Blue"))
                    .clipShape(Capsule())
            }
            if var steps = self.todo.steps {
                GroupBox("Steps") {
                    VStack(alignment: .leading) {
                        ForEach(Array(zip(steps.indices, steps)), id: \.0) {
                            index, step in
                            Button {
                                self.todo.steps?[index].completed = true
                            } label: {
                                HStack {
                                    Image(systemName: step.completed ? "checkmark.square" : "square")
                                        .resizable()
                                        .frame(width: 10, height: 10)
                                    Text(step.step)
                                        .font(.caption)
                                        .strikethrough(step.completed)
                                    Spacer()
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.leading, 30)
                    }
                }
            }
            if let components = todo.components {
                GroupBox("Necessities") {
                    VStack(alignment: .leading) {
                        ForEach(Array(zip(components.indices, components)), id: \.0) {
                            index, component in
                            Button {
                                self.todo.components?[index].completed = true
                            } label: {
                                Image(systemName: component.completed ? "checkmark.square" : "square")
                                    .resizable()
                                    .frame(width: 10, height: 10)
                                Text(component.component)
                                    .font(.caption)
                                    .strikethrough(component.completed)
                                Spacer()
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.leading, 30)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(5)
        .background(todo.completed ? Color("Blue") : Color.white)
        .cornerRadius(10)
        .padding(.horizontal)
    }
}
