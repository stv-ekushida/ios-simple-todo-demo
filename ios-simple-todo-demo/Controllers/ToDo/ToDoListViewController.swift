//
//  ToDoListViewController.swift
//  ios-simple-todo-demo
//
//  Created by Eiji Kushida on 2017/06/01.
//  Copyright © 2017年 Eiji Kushida. All rights reserved.
//

import UIKit

final class ToDoListViewController: UIViewController {

    //MARK: - Properties
    fileprivate let dataSource = ToDoListProvider()
    fileprivate let alert = ToDoAlert()
    fileprivate var folder: Folder!
    
    //MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    //MARK: - Action
    @IBAction func didTapEditToDo(_ sender: UIBarButtonItem) {
        
        if tableView.isEditing {
            alert.showDeleteAll(topOf: self)
        } else {
            alert.showCreate(topOf: self)
        }
    }

    //MARK: - Initializers
    /// ToDo一覧画面のインスタンスを取得する
    ///
    /// - Parameter folder: フォルダ
    /// - Returns: ToDo一覧画面のインスタンス
    static func configuredWith(folder: Folder) -> ToDoListViewController {

        let vc = UIStoryboard
            .viewController(storyboardName: ToDoListViewController.className,
                            identifier: ToDoListViewController.className)
            as? ToDoListViewController
        vc?.folder = folder
        vc?.title = folder.title
        return vc!
    }

    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadToDoList()
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.isEditing = editing
        setupToolBar(isEditing: editing)
    }
    
    //MARK: - FilePrivate Methods
    /// タスク一覧を取得する
    fileprivate func reloadToDoList() {
        dataSource.set(todos: FolderDao.findAllToDo(folderID: folder.folderID))
        tableView.reloadData()
    }
    
    //MARK: - Private Methods
    /// ナビゲーションバーを設定する
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = editButtonItem
        navigationItem.hideBackButtonTitle()
    }

    /// ツールバーを設定する
    ///
    /// - Parameter isEditing: 編集モードか？
    private func setupToolBar(isEditing: Bool) {
        editButton.title = isEditing ?
            Constrains.ToolBar.deleteAllButton : Constrains.ToolBar.addTaskButton
    }

    /// テーブルビューを設定する
    private func setupTableView() {
        dataSource.delegate = self
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.allowsSelectionDuringEditing = true
    }
}

//MARK: - AlertHelperDelegate
extension ToDoListViewController: FormAlertHelperDelegate {

    /// フォルダの追加または、更新完了通知を受信したときの処理
    ///
    /// - Parameters:
    ///   - type: 更新タイプ(登録 or 更新)
    ///   - title: フォルダ名
    func addAndUpdate(type: FormAlertHelperType, title: String) {

        switch type {
        case .add:
            let todoId = ToDoDao.add(title: title)
            
            if let todo = ToDoDao.findByID(todoID: todoId) {
                folder.todos.append(todo)
                FolderDao.update(folder: folder)
            }

        case .update(let index):
            let currentTodo = dataSource.todo(index: index)
            
            let updateTodo = ToDo(value: currentTodo)
            updateTodo.title = title
            ToDoDao.update(todo: updateTodo)
        }

        reloadToDoList()
        tableView.reloadData()
    }

    /// 全フォルダとそれに関連するタスクを削除する
    func deleteAll() {
        FolderDao.deleteAllToDo(folderID: folder.folderID)
        reloadToDoList()
        tableView.reloadData()
    }
}

//MARK: - UITableViewDelegate
extension ToDoListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if isEditing {
            let folder = dataSource.todo(index: indexPath.row)
            alert.showUpdate(index: indexPath.row,
                             title: folder.title,
                             topOf: self)
            return
        }
    }
}

//MARK: - ToDoListProviderDelegate
extension ToDoListViewController: ToDoListProviderDelegate {

    /// タスクを削除する
    ///
    /// - Parameter todoID: タスクID
    func deleteToDo(todoID: Int) {
        ToDoDao.delete(todoID: todoID)
        tableView.reloadData()
    }
}
