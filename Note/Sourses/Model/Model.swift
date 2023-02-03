//
//  Model.swift
//  Note
//
//  Created by Ян Нурков on 29.01.2023.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager {
    enum type {
        case flagStatus(Bool)
        case image(Data)
        case notesView(String)
        case fontSize(Float)
        case red(Float)
        case green(Float)
        case blue(Float)
        case imageSize(Float)
    }
    
    private lazy var context: NSManagedObjectContext = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {fatalError()}
        return appDelegate.persistentContainer.viewContext
    }()
    
    // MARK: - LoadAllNotes
    
    func loadAllNotes(completion: @escaping ([Notes]) -> Void) {
        let request: NSFetchRequest<Notes> = Notes.fetchRequest()
        do {
            let result = try context.fetch(request)
            completion(result)
        } catch {
            print("errorloadAllNotes")
        }
    }
    
    // MARK: - AddNewNote
    
    func addNewNote(completion: @escaping (UUID) -> Void) {
        let note = Notes(context: context)
        let id = UUID()
        note.numberOfCell = id
        do {
            try context.save()
            completion(id)
        } catch {
            print("erroraddNewNote")
        }
    }
    
    // MARK: - LoadNote
    
    func loadNote(uuid: UUID, completion: @escaping (Notes) -> Void) {
        let request: NSFetchRequest<Notes> = Notes.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", "numberOfCell", uuid as CVarArg)
        do {
            let notes = try context.fetch(request)
            guard let notes = notes.first else {return}
            completion(notes)
        } catch {
            print("errorloadNotes")
        }
    }
    
    // MARK: - UpdateNote
    
    func updateNote(uuid: UUID, type: type) {
        loadNote(uuid: uuid){ newNote in
            switch type {
            case .flagStatus(let bool):
                newNote.flagStatus = bool
            case .image(let Data):
                newNote.image = Data
            case .notesView(let string):
                newNote.notesView = string
            case .fontSize(let float):
                newNote.fontSize = float
            case .red(let float):
                newNote.red = float
            case .blue(let float):
                newNote.blue = float
            case .green(let float):
                newNote.green = float
            case .imageSize(let float):
                newNote.imageSize = float
            }
            do {
                try self.context.save()
            } catch {
                print("errorUpdateNote")
            }
        }
    }
    
    // MARK: - DeleteNote
    
    func deleteNote(uuid: UUID) {
        let request: NSFetchRequest<Notes> = Notes.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", "numberOfCell", uuid as CVarArg)
        guard let result = try? context.fetch(request).first else {return}
        context.delete(result)
        try? context.save()
    }
}
