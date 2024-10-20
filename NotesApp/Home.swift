//
//  ContentView.swift
//  NotesApp
//
//  Created by Uahit on 19.10.2024.
//

import SwiftUI

struct Home: View {
	
	@State var notes = [Note]()
	@State var showAdd = false
	@State var showAlert = false
	@State var deleteItem: Note?
	@State var isEditMode: EditMode = .inactive
	@State var updateNote = ""
	@State var noteId = ""

    var body: some View {
		NavigationView {
			List(notes) { note in
				if isEditMode == .inactive {
					Text("\(note.note)")
						.padding()
						.onLongPressGesture {
							self.showAlert.toggle()
							deleteItem = note
						}
				} else {
					HStack {
						Image(systemName: "pencil.circle.fill")
							.foregroundColor(.yellow)
						
						Text("\(note.note)")
							.padding()
					}.onTapGesture {
						updateNote = note.note ?? ""
						noteId = note.id
						showAdd.toggle()
					}
				}
			}
			.alert(isPresented: $showAlert, content: {
				alert
			})
			.sheet(isPresented: $showAdd, onDismiss: {
				fetchNotes()
			}, content: {
				if isEditMode == .inactive {
					AddNoteView()
				} else {
					UpdateNoteView(text: $updateNote, noteId: $noteId)
				}
			})
			.onAppear(perform: {
				fetchNotes()
			})
			.navigationTitle("Notes")
			.navigationBarItems(
				leading: Button(action: {
					if isEditMode == .inactive {
						isEditMode = .active
					} else {
						isEditMode = .inactive
					}
				}, label: {
					if isEditMode == .inactive {
						Text("Edit")
					} else {
						Text("Done")
					}
				}),
				trailing: Button(
					action: {
						showAdd.toggle()
					},
					label: {
						Text("+").font(.largeTitle)
					}
				)
			)
		}
    }
	
	private var alert: Alert {
		Alert(
			title: Text("Delete"),
			message: Text("Are you sure?"),
			primaryButton: .destructive(Text("Delete"),action: delete),
			secondaryButton: .cancel()
		)
	}
	
	private func fetchNotes() {
		let url = URL(string: "http://localhost:3000/notes")
		
		let task = URLSession.shared.dataTask(with: url!) { data,response,error in
			guard let data = data else {
				return
			}
			
			print(String(data: data, encoding: .utf8))
			do {
				self.notes = try JSONDecoder().decode([Note].self, from: data)
			}
			catch {
				print(error)
			}
		}
		task.resume()
		
		if isEditMode == .active {
			isEditMode = .inactive
		}
	}
	
	private func delete() {
		guard let id = deleteItem?.id else {
			return
		}
		let url = URL(string: "http://localhost:3000/notes/\(id)")
		var request = URLRequest(url: url!)
		request.httpMethod = "DELETE"
		let task = URLSession.shared.dataTask(with: request) {data,response,error in
			
			guard error == nil, let data else {
				return
			}
			
			print(String(data: data, encoding: .utf8))
			
			do {
				if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any] {
					print(json)
					
					
				}
			} catch {
				print(error)
			}
			
		}
		task.resume()
		fetchNotes()
	}
}

struct Note: Identifiable, Codable {
	var id: String { _id }
	var _id: String
	var note: String?
}

#Preview {
    Home()
}
