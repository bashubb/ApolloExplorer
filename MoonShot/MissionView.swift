//
//  MissionView.swift
//  MoonShot
//
//  Created by HubertMac on 08/10/2023.
//

import SwiftUI

struct MissionView: View {
    struct CrewMember{
        let role: String
        let astronaut: Astronaut
    }
    
    let mission: Mission
    let crew: [CrewMember]
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack {
                    Image(mission.image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: geo.size.width * 0.6)
                        .padding(.top)
                    
                    
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .frame(height: 2)
                        .padding(.vertical, 10)
                    
                    
                    VStack(alignment: .leading) {
                        Text("Mission Highlights")
                            .font(.title.bold())
                            .padding(.bottom, 5)
                        
                        Text(mission.description)
                    }
                    .padding(.horizontal)
                    
                    
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .frame(height: 2)
                        .padding(.vertical, 10)
                    
                    Text("Crew")
                        .font(.title.bold())
                        .padding(.horizontal)
                        .padding(.bottom, 5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    
                    ScrollView(.horizontal, showsIndicators:false) {
                        HStack {
                            ForEach(crew, id: \.role) {crewMember in
                                NavigationLink {
                                    Text("Astronaut details")
                                } label: {
                                    HStack {
                                        Image(crewMember.astronaut.id)
                                            .resizable()
                                            .frame(width: 104, height: 72)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                            .overlay (
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(.white, lineWidth: 1)
                                            )
                                        VStack (alignment: .leading) {
                                            Text(crewMember.astronaut.name)
                                                .foregroundStyle(Color.white)
                                                .font(.headline.bold())
                                            
                                            Text(crewMember.role)
                                                .foregroundStyle(crewMember.role.hasPrefix("Command") ? Color.red.opacity(0.8) : Color.secondary)
                                                
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                    .background(.ultraThinMaterial)
                }
            }
        }
        .navigationTitle(mission.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .background(.darkBackground)
    }
    
    init(mission: Mission, astronauts: [String: Astronaut]) {
        self.mission = mission
        self.crew = mission.crew.map { member in
            if let astronaut = astronauts[member.name]{
                return CrewMember(role: member.role, astronaut: astronaut)
            } else {
                fatalError("Missing \(member.name)")
            }
        }
    }
}

#Preview {
    let missions: [Mission] =  Bundle.main.decode("missions.json")
    let astronauts: [String: Astronaut] = Bundle.main.decode("astronauts.json")
    
    return MissionView(mission: missions[0], astronauts: astronauts)
        .preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
    
}
