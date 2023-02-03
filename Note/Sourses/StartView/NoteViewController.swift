//
//  NoteViewController.swift
//  Note
//
//  Created by Ян Нурков on 29.01.2023.
//

import UIKit
import CoreData

class NoteViewController: UIViewController {
    private let noteView = NoteView()
    private let coreDataManager = CoreDataManager()
    private var notes = [Notes]()
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private var isSearch : Bool = false
    private var isShowingFavorites = false
    private var heart = "heart"
    
    // MARK: - LifeCycle
    
    override func loadView() {
        super.loadView()
        view = noteView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.noteView.didLoadUI(controller: self)
        self.configureNavigationBar()
        self.noteView.tableView.delegate = self
        self.noteView.tableView.dataSource = self
        self.noteView.searchBar.searchResultsUpdater = self
        self.noteView.searchBar.obscuresBackgroundDuringPresentation = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showNotes()
    }
}

// MARK: - ExtensionUITableViewDataSource

extension NoteViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredData.count
        }
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoteTableViewCell.cellName, for: indexPath) as? NoteTableViewCell else {return UITableViewCell() }
        cell.configView(controller: self)
        let data: NSManagedObject
        if isFiltering {
            data = filteredData[indexPath.row]
        } else {
            data = notes[indexPath.row]
        }
        if ((notes[indexPath.row].notesView?.isEmpty) == nil) {
            cell.nameNoteLabel.text = "Новая заметка"
        } else {
            cell.nameNoteLabel.text = data.value(forKey: "notesView") as? String
        }
        return cell
    }
}

// MARK: - ExtensionUITableViewDelegate

extension NoteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let id = notes[indexPath.row].numberOfCell else {return}
            coreDataManager.deleteNote(uuid: id)
            if isFiltering {
                print("Filtering not Delete")
            } else {
                notes.remove(at: indexPath.row)
                noteView.tableView.deleteRows(at: [indexPath], with: .automatic)
                feedbackGenerator.impactOccurred()
                noteView.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: "") { (action, view, completion) in
            if self.notes[indexPath.row].flagStatus == true {
                guard let id = self.notes[indexPath.row].numberOfCell else {return}
                self.coreDataManager.updateNote(uuid: id, type: .flagStatus(false))
                self.feedbackGenerator.impactOccurred()
                self.loadFavorites()
            } else {
                guard let id = self.notes[indexPath.row].numberOfCell else {return}
                self.coreDataManager.updateNote(uuid: id, type: .flagStatus(true))
                self.feedbackGenerator.impactOccurred()
                self.noteView.tableView.reloadData()
            }
        }
        if notes[indexPath.row].flagStatus == true {
            action.image = UIImage(systemName: "heart.fill")
        } else {
            action.image = UIImage(systemName: "heart")
        }
        action.backgroundColor = Colors.lightBlue
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let uuid = notes[indexPath.row].numberOfCell else {return}
        let sketchViewController = SketchViewController(uuid: uuid)
        feedbackGenerator.impactOccurred()
        navigationController?.pushViewController(sketchViewController, animated: true)
    }
}

// MARK: — Extension

extension NoteViewController {
    private func configureNavigationBar() {
        guard let navigationbar = navigationController?.navigationBar else { return }
        self.title = "Мои Заметки"
        navigationbar.layer.shadowColor = UIColor.white.cgColor
        navigationbar.layer.shadowOffset = CGSize.zero
        navigationbar.layer.shadowRadius = 1.5
        navigationbar.layer.shadowOpacity = 1
        navigationbar.tintColor = Colors.navigationTint
        navigationbar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: Colors.navigationTint,
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18) as Any
        ]
        let addNoteButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.pencil"),
            style: .plain,
            target: self,
            action: #selector(addNoteTapped)
        )
        let addFavoriteButton = UIBarButtonItem(
            image: UIImage(systemName: heart),
            style: .plain,
            target: self,
            action: #selector(loadFavorites)
        )
        
        self.navigationItem.leftBarButtonItem = addFavoriteButton
        self.navigationItem.rightBarButtonItem = addNoteButton
        self.noteView.searchBar.searchBar.placeholder = "Поиск"
        self.navigationItem.searchController = self.noteView.searchBar
        self.definesPresentationContext = true
        self.navigationItem.backButtonDisplayMode = .minimal
    }
    
    // MARK: - Actions
    
    @objc private func addNoteTapped() {
        feedbackGenerator.impactOccurred()
        coreDataManager.addNewNote { _ in
            self.coreDataManager.loadAllNotes { notes in
                self.notes = notes.reversed()
                self.noteView.tableView.reloadData()
            }
        }
    }
    
    @objc private func loadFavorites() {
        isShowingFavorites = !isShowingFavorites
        if isShowingFavorites == true {
            notes = notes.filter { data in
                return (data.value(forKey: "flagStatus") as? Bool) == true
            }
            heart = "heart.fill"
            configureNavigationBar()
            self.noteView.tableView.reloadData()
        } else {
            showNotes()
            heart = "heart"
            configureNavigationBar()
        }
    }
    
    // MARK: - Function
    
    private func showNotes() {
        coreDataManager.loadAllNotes { notes in
            self.notes = notes.reversed()
            self.noteView.tableView.reloadData()
        }
    }
}

// MARK: - ExtensionUISearchResultsUpdating

extension NoteViewController: UISearchResultsUpdating {
    var isFiltering: Bool {
        return self.noteView.searchBar.isActive && !searchBarIsEmpty
    }
    
    var searchBarIsEmpty: Bool {
        return self.noteView.searchBar.searchBar.text?.isEmpty ?? true
    }
    
    var filteredData: [NSManagedObject] {
        return notes.filter { data in
            guard let searchText = self.noteView.searchBar.searchBar.text else { return false }
            guard let attribute = data.value(forKey: "notesView") as? String else { return false }
            return attribute.lowercased().contains(searchText.lowercased())
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        self.noteView.tableView.reloadData()
    }
}
