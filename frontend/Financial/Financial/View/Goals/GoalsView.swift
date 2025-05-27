//
//  GoalsView.swift
//  Financial
//
//  Created by KeeR ReeK on 09.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

struct GoalsView: View {
    
    @ObservedObject var viewModel = GoalsViewModel()
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Goal.name, ascending: false)],
        animation: .default)
    private var goals: FetchedResults<Goal>
    
    var body: some View {
        VStack {
            List {
                ForEach(goals, id: \.self) { goal in
                    let calculatePercent = viewModel.сalculatePercentAchievement(count: Int(goal.count))
                    let calculateGoal = viewModel.calculateGoal(count: Int(goal.count))
                    if let name = goal.name {
                        ProgressGoalView(
                            progress: calculatePercent,
                            current: Int(goal.count),
                            goal: calculateGoal,
                            text: name
                        )
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                }
            }
            .listStyle(.plain)
            .background(Color("BackroundColor"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color("BackroundColor"))
    }
}
