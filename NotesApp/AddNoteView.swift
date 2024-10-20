//
//  AddNoteView.swift
//  NotesApp
//
//  Created by Uahit on 20.10.2024.
//

import SwiftUI

struct AddNoteView: View {
	
	@State var text = ""
	
	@Environment(\.presentationMode) var presentationMode
	
	var body: some View {
		HStack {
			TextField("Write a note", text: $text)
				.padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
				.border(.gray, width: 1)
				.cornerRadius(5.0)

			Button(action: {
				postNotes()
			}, label: {
				Text("Add")
			})
			.padding(8)
		}.padding(16)
	}
	
	private func postNotes() {
		let params = ["note": text] as [String:Any]
		
		let url = URL(string: "http://localhost:3000/notes")!
		let session = URLSession.shared
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
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

struct AddNoteView_Previews: PreviewProvider {
	static var previews: some View {
		AddNoteView()
	}
}
