//
//  ContentView.swift
//  Taskr
//
//  Created by Jared Davidson on 1/20/24.
//

import SwiftUI
import OpenAI

struct ContentView: View {
    @State private var prompt: String = ""
    
    @StateObject var taskGenerator: TaskGenerator = .init()
    @FocusState var isFocused: Bool
    
    var body: some View {
        VStack {
            TextField("What do you want to do?", text: self.$prompt)
                .frame(height: 60)
                .padding(5)
                .background(Color("Blue"))
                .cornerRadius(15)
                .shadow(radius: isFocused ? 1 : 0)
                .onSubmit {
                    Task {
                        await fetchTodos()
                    }
                }
                .focused(self.$isFocused)
                .multilineTextAlignment(.center)
                .padding()
            if isFocused || !self.taskGenerator.todos.isEmpty || self.taskGenerator.loading {
                ScrollView {
                    VStack {
                        ForEach(self.$taskGenerator.todos, id: \.id) { task in
                            TodoRow(taskGenerator: taskGenerator, todo: task)
                                .transition(.asymmetric(insertion: .slide, removal: .slide))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .animation(.smooth, value: self.isFocused)
    }
    
    private func fetchTodos() async {
        guard !prompt.isEmpty else { return }
        taskGenerator.getTodosFromGPT(promptIdea: prompt)
    }
}
