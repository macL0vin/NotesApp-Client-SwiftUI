//
//  UpdateNoteView.swift
//  NotesApp
//
//  Created by Uahit on 20.10.2024.
//

import SwiftUI

struct UpdateNoteView: View {
	
	@Binding var text: String
	@Binding var noteId: String
	@Environment(\.presentationMode) var presentationMode

	var body: some View {
		HStack {
			TextField("Update note", text: $text)
				.padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
				.clipped()
			
			Button(action: updateNotes) {
				Text("Update")
			}
			.padding(8)
		}
	}
	
	private func updateNotes() {
		let params = ["note": text] as [String:Any]
		
		let url = URL(string: "http://localhost:3000/notes/\(noteId)")!
		let session = URLSession.shared
		var request = URLRequest(url: url)
		request.httpMethod = "PATCH"
		do {
			request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
		} catch {
			print(error)
		}
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		
		let task = session.dataTask(with: request) { data, response, error in
			guard error == nil else { return }
			
			guard let data = data else { return }
			
			do {
				if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any] {
					print(json)
				}
			} catch {
				print(error)
			}
		}
		task.resume()
		
		text = ""
		presentationMode.wrappedValue.dismiss()
	}
}
