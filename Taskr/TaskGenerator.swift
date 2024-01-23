//
//  TaskGenerator.swift
//  Taskr
//
//  Created by Jared Davidson on 1/20/24.
//

import Foundation
import SwiftUI
import OpenAI

class TaskGenerator: ObservableObject {
    @Published var loading: Bool = false
    @Published var todos: [Todo] = []
    let openAI = OpenAI(apiToken: "")
    #error("OpenAI Key Goes Here")
    
    var json = ""

    func getTodosFromGPT(promptIdea: String) {
        withAnimation(.interactiveSpring) {
            self.todos = []
        }
        self.loading = true
        self.json = ""
        var prompt = """
                    
                    Give me a list of to-do tasks that I can do daily based on the given prompt. Make it a checklist of items that I can cross off. These items are their own individual items & might include inner steps or components/ingredients, however the goal of each of these individual items should lead to the prompt given as a result. Be sure to break up the items and steps in a way that is simple and straightforward.

                    Drink 5 times a day. Exercise for 30 minutes. For example.

                    Things like: "Avoid prolonged screen time" is not a task. It's a tip, but that's not what we want. We need actionable steps that help me plan the day. Do not include anything that cannot be clearly checked off for the day.

                    If there's anything like "Learn a new programming concept or language" that is vague, be sure to make it an actual task like: "Build a pacman clone" or "Do leetcode for an hour". If you can include a helpful link, do so and mark it separately in the JSON as "link".

                    If the task is repeatable daily, mark is as "Daily". - The key is "type"
                    If the task is once only today, mark it as "Today"  - The key is "type"
                    If the task is weekly, mark it as "Weekly" - The key is "type"
                                        
                    If the prompt is something like "make eggs" or something that has a clear beginning and end, return all the steps necessary to get to the end, including all of the components that make up that task. For example "make eggs" should include the number of eggs needed. This should apply to anything like that. If there's nothing food related that's needed, for example "a computer" or something along those lines, it should be considered a component all the same. Use the key value of "component" to describe these in the key/value pair. For example: "component": "2 Eggs". DO NOT MAKE THE KEY THE INGREDIENT OR COMPONENT! DO NOT NUMBER THE COMPONENT!
                    
                    If any of those tasks have inner steps, be sure to include those using the key/value pair of "step": "The Step". DO NOT MAKE THE KEY NUMBERED OR CHANGED IN ANY WAY.

                    Return the data in a JSON format:

                    {task: "", type: ""}
                    {task: "", type: ""}
                    {task: "", type: ""}

                    If there are steps or components inside of the task, YOU MUST RETURN IT LIKE THE FOLLOWING:
                    
                    {task: "", type: "", components: [{component:""}, {component:""}], steps: [{step: ""}, {step: ""}]}
                    {task: "", type: "", components: [{component:""}, {component:""}], steps: [{step: ""}, {step: ""}]}
                    {task: "", type: "", components: [{component:""}, {component:""}], steps: [{step: ""}, {step: ""}]}
                    {task: "", type: "", components: [{component:""}, {component:""}], steps: [{step: ""}, {step: ""}]}
                    {task: "", type: "", components: [{component:""}, {component:""}], steps: [{step: ""}, {step: ""}]}

                    For Example:
                    
                    { "task": "Mix the ingredients", "type": "Today", "components": [{ "component": "2 cups all-purpose flour"}, {"component": "1 1/2 cups granulated sugar"}, {"component": "3/4 cup unsalted butter, melted"}, {"component": "3 large eggs"}, {"component": "1 cup milk"}, {"component": "2 teaspoons vanilla extract"}, {"component": "2 teaspoons baking powder"}, {"component": "1/2 teaspoon salt" }], "steps": [{"step": "Preheat the oven to 350°F (175°C) and grease a cake pan."}, {"step": "In a large mixing bowl, combine the flour, sugar, baking powder, and salt."}, {"step": "Add the melted butter, eggs, milk, and vanilla extract to the dry ingredients.", "step": "Mix the ingredients together until well combined and the batter is smooth."}, {"step": "Pour the batter into the greased cake pan and spread it evenly."}, {"step": "Bake the cake in the preheated oven for 30-35 minutes or until a toothpick inserted into the center comes out clean."}, {"step": "Remove the cake from the oven and let it cool in the pan for 10 minutes."}, {"step": "Transfer the cake to a cooling rack and let it cool completely before frosting." }] }
                    { "task": "Put it in the over", "type": "Today", "components": [{ "component": "2 cups all-purpose flour"}, {"component": "1 1/2 cups granulated sugar"}, {"component": "3/4 cup unsalted butter, melted"}, {"component": "3 large eggs"}, {"component": "1 cup milk"}, {"component": "2 teaspoons vanilla extract"}, {"component": "2 teaspoons baking powder"}, {"component": "1/2 teaspoon salt" }], "steps": [{"step": "Preheat the oven to 350°F (175°C) and grease a cake pan."}, {"step": "In a large mixing bowl, combine the flour, sugar, baking powder, and salt."}, {"step": "Add the melted butter, eggs, milk, and vanilla extract to the dry ingredients.", "step": "Mix the ingredients together until well combined and the batter is smooth."}, {"step": "Pour the batter into the greased cake pan and spread it evenly."}, {"step": "Bake the cake in the preheated oven for 30-35 minutes or until a toothpick inserted into the center comes out clean."}, {"step": "Remove the cake from the oven and let it cool in the pan for 10 minutes."}, {"step": "Transfer the cake to a cooling rack and let it cool completely before frosting." }] }
                    
                    RULES:
                    YOU MUST ADHERE TO THESE RULES. DO NOT BREAK ANY PATTERNS.
                    
                    THE KEYS SPECIFIED SHOULD NEVER CHANGE TO ANY OTHER TERM.
                    THE KEYS SHOULD NEVER BE CHANGE OR NUMBERED EVEN IF THEY"RE IN A LIST
                    DO NOT include any other keys than those specified. DO NOT include any numbers in the keys.
                    The list of valid keys is: type, task, components, component, steps, step.
                    YOU MUST NOT INCLUDE ANY OTHER KEYS
                    END OF RULES
                    
                    The prompt is: \(promptIdea).
                    """
        
        print(prompt)
        let query = ChatQuery(
            model: .gpt3_5Turbo,  // 0613 is the earliest version with function calls support.
            messages: [
                Chat(role: .user, content: prompt)
            ]
        )
        
        // Inside your function
        self.openAI.chatsStream(query: query) { result in
            switch result {
            case .success(let chat):
                self.json += chat.choices.first?.delta.content ?? ""
                
                // Parse the response and extract tasks from the JSON
                if let newTodos = self.parseTodosFromJSON(self.json) {
                    DispatchQueue.main.async {
                        withAnimation(.spring) {
                            self.todos.append(newTodos)
                        }
                    }
                }
            case .failure(let error):
                break
            }
        } completion: { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.loading = false
                } else {
                    self.loading = false
                }
            }
        }
    }
    
    func parseTodosFromJSON(_ json: String) -> Todo? {
        do {
            
            var json = json
            // Assuming json is a valid JSON string, you need to parse it
            let data = json.data(using: .utf8)!
            let decoder = JSONDecoder()
            let chatResult = try decoder.decode(Todo.self, from: data)
            self.json = ""
            // Now extract todos from chatResult
            return chatResult
        } catch {
            print(json)
            print("Error parsing JSON: \(error.localizedDescription)")
            return nil
        }
    }
}

struct Todos: Codable {
    let tasks: [Todo]
}

struct Todo: Identifiable, Codable {
    let id = UUID()
    let type: String?
    let task: String
    var completed: Bool = false
    var link: String?
    var components: [Component]?
    var steps: [Step]?
    
    enum CodingKeys: CodingKey {
//        case id
        case type
        case task
//        case completed
        case link
        case components
        case steps
    }
}

struct Component: Codable {
    var id = UUID()
    var component: String
    var completed: Bool = false
    
    enum CodingKeys: CodingKey {
        case component
    }
}

struct Step: Codable {
    var id = UUID()
    var step: String
    var completed: Bool = false
    
    enum CodingKeys: CodingKey {
        case step
    }
}

// MARK: - Binding Extension
extension Binding {
    func unwrap<Wrapped>() -> Binding<Wrapped>? where Optional<Wrapped> == Value {
        guard let value = self.wrappedValue else { return nil }
        return Binding<Wrapped>(
            get: { value },
            set: { self.wrappedValue = $0 }
        )
    }
}
