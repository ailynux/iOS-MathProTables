//
//  ContentView.swift
//  flashcards_
//
//  Created by Ailyn Diaz on 3/21/24.
//  "Challenge from 100 days of SwiftUI"
//
// notes:
// used confetti:
// https://github.com/GetStream/effects-library --> animations package / Effects Library SwiftUI
//

import SwiftUI
import EffectsLibrary

struct ContentView: View {
    
    //variables
    @State private var selectedTables = Set<Int>()
    @State private var selectedQuestions = 5
    @State private var questions: [(String, Int)] = []
    @State private var userAnswers: [String] = []
    @State private var answerStatus: [Bool] = []
    @State private var showResults = false
    @State private var gameStarted = false

    let availableTables = Array(1...12) //table
    let availableQuestionCounts = [5, 10, 20] // questions

    //body
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 20) {
                    // the header
                    Text(" Math")
                        .font(.custom("Chalkduster", size: 43))
                        .fontWeight(.bold)
                        .foregroundColor(.red)


                    Text("📚 Study x*! 🧠 ")
                        .font(.headline)
                    .foregroundColor(.gray)}

                .padding(.top, 30)

                Spacer()

                //logo image
                Image("Image")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 200, height: 250)
            }

            .padding(.horizontal, 20)

            //tables section
            Text("Select tables to practice")
                .font(.headline)
                .foregroundColor(.blue)
                .padding(.top, 10)

            ScrollView(.horizontal) { // colorful buttons
                HStack {
                    ForEach(availableTables, id: \.self) { table in
                        Button(action: {
                            if self.selectedTables.contains(table) {
                                self.selectedTables.remove(table)
                            } else {
                                self.selectedTables.insert(table)
                            }
                        }) {
                            Text("\(table)")
                                .padding(10)
                                .font(.title)
                                .foregroundColor(.white)
                                .background(
                                    self.selectedTables.contains(table) ?
                                    Color.blue.opacity(0.7) :
                                        Color.red.opacity(0.7)
                                )
                                .clipShape(Circle())
                        }
                        .frame(width: 60, height: 60)
                        .padding(5)
                    }
                }
            }

            Text("Select number of questions")
                .font(.headline)
                .foregroundColor(.blue)
                .padding(.top)

            Picker(selection: $selectedQuestions, label: Text("Number of questions")) {
                ForEach(availableQuestionCounts, id: \.self) { count in
                    Text("\(count)")
                        .foregroundColor(.purple)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()


            //practice button -->
            if !showResults && !gameStarted {
                Button(action: {
                    withAnimation {
                        self.generateQuestions()
                        self.gameStarted = true
                    }
                }) {
                    // fancy big button
                    Text("Start Practice")
                        .font(.system(size: 36, weight: .bold))
                        .padding(.vertical, 50)
                        .padding(.horizontal, 20)
                        .foregroundColor(.white)
                        .background(
                            ZStack {
                                LinearGradient(gradient: Gradient(colors: [Color.green, Color.blue]), startPoint: .leading, endPoint: .trailing)
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white, lineWidth: 2)
                            }
                        )
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white, lineWidth: 2)
                                .scaleEffect(showResults ? 1.2 : 1.0)
                                .opacity(showResults ? 0.3 : 1.0)
                        )
                        .shadow(color: .black, radius: showResults ? 0 : 10)
                        .animation(.easeInOut(duration: 0.5), value: showResults)
                }
                .padding(60)

            }


            //new view
            ScrollView {
                VStack {
                    ForEach(0..<questions.count, id: \.self) { index in
                        HStack {
                            Text("\(self.questions[index].0) = ")
                                .foregroundColor(self.answerStatus[index] ? .black : .red)
                                .font(.headline)
                            TextField("Enter answer", text: self.binding(forIndex: index))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                                .background(self.answerStatus[index] ? Color.white : Color.red.opacity(0.3))
                        }
                        .padding()
                    }
                    
                    // answers button
                    if gameStarted && !showResults {
                                Button(action: {
                                    withAnimation {
                                        self.checkAnswers()
                                        self.showResults = true
                                    }
                        }) {
                            Text("Submit Answers")
                                .font(.headline)
                                .fontWeight(.bold)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding()
                    }
                }
            }


            //the score at the end
            if showResults {
                let score = calculateScore()
                Text("Score: \(score)%")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)

                Button(action: {
                    withAnimation {
                        self.restart()
                    }
                }) {
                        Text("Restart")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                            .shadow(color: .black, radius: 5)
                    }

                    if score == 100 { // shows Confetti if score is 100 :)
                        ConfettiView()
                            .edgesIgnoringSafeArea(.all)
                    }
            }
        }
    }

    // My Functions begin
    func generateQuestions() {
        questions.removeAll()
        userAnswers.removeAll()
        answerStatus.removeAll()

        for _ in 0..<selectedQuestions {
            let table = selectedTables.randomElement() ?? 2
            let multiplier = Int.random(in: 1...12)
            let question = "\(table) x \(multiplier)"
            questions.append((question, table * multiplier))
            userAnswers.append("")
            answerStatus.append(true)
        }
    }

    func binding(forIndex index: Int) -> Binding<String> {
        Binding<String>(
            get: { self.userAnswers[index] },
            set: { self.userAnswers[index] = $0 }
        )
    }

    func checkAnswers() {
        for i in 0..<questions.count {
            if userAnswers[i].isEmpty || (Int(userAnswers[i]) != nil && Int(userAnswers[i]) != questions[i].1) {
                answerStatus[i] = false
            }
        }
    }

    func calculateScore() -> Int {
        guard !questions.isEmpty else {
            return 0
        }

        let correctCount = answerStatus.filter { $0 }.count
        return Int(Double(correctCount) / Double(questions.count) * 100)
    }

    func restart() {
        //resets everything >,<
        selectedTables.removeAll()
        selectedQuestions = 5
        questions.removeAll()
        userAnswers.removeAll()
        answerStatus.removeAll()
        showResults = false
        gameStarted = false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
