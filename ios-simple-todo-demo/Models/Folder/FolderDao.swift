//
//  FolderDao.swift
//  ios-simple-todo-demo
//
//  Created by Eiji Kushida on 2017/06/01.
//  Copyright © 2017年 Eiji Kushida. All rights reserved.
//

import Foundation
import RealmSwift
import STV_Extensions

final class FolderDao {

    static let dao = RealmDaoHelper<Folder>()

    /// フォルダを追加する
    ///
    /// - Parameter title: フォルダタイトル
    static func add(title: String) {

        let object = Folder()
        object.folderID = FolderDao.dao.newId()!
        object.title = title
        object.date = Date().now()
        dao.add(data: object)
    }

    /// 該当フォルダを更新する
    ///
    /// - Parameter folder: フォルダ
    static func update(folder: Folder) {

        guard let target = dao.findFirst(key: folder.folderID as AnyObject) else {
            return
        }

        let object = Folder()
        object.folderID = target.folderID
        object.title = folder.title
        object.date = Date().now()
        object.todos.append(objectsIn: folder.todos)
        dao.update(data: object)
    }

    /// 該当フォルダを削除する
    ///
    /// - Parameter folderID: フォルダID
    static func delete(folderID: Int) {

        guard let target = dao.findFirst(key: folderID as AnyObject) else {
            return
        }
        
        target.todos.forEach {
            ToDoDao.delete(todoID: $0.todoID)
        }
        dao.delete(data: target)
    }

    /// すべてのフォルダを削除する
    static func deleteAll() {
        ToDoDao.deleteAll()
        dao.deleteAll()
    }
    
    /// 該当のフォルダを取得する
    ///
    /// - Parameter folderID: フォルダID
    /// - Returns: フォルダ
    static func findByID(folderID: Int) -> Folder? {
        guard let object = dao.findFirst(key: folderID as AnyObject) else {
            return nil
        }
        return object
    }

    /// すべてのフォルダを取得する
    ///
    /// - Returns: フォルダ一覧
    static func findAll() -> [Folder] {
        return FolderDao.dao.findAll()
            .sorted(byKeyPath: "date", ascending: false)
            .map { Folder(value: $0) }        
    }
    
    //MARK: - 関連テーブル(ToDo)
    
    /// 該当フォルダ内のすべてのToDoを削除する
    ///
    /// - Parameter folderID: フォルダID
    static func deleteAllToDo(folderID: Int) {
        
        if let folder = FolderDao.findByID(folderID: folderID) {
            
            folder.todos.forEach {
                ToDoDao.delete(todoID: $0.todoID)
            }
            dao.update(data: folder)
        }
    }
    
    /// 該当フォルダ内のすべてのToDoを取得する
    ///
    /// - Parameters:
    ///   - folderID: フォルダID
    /// - Returns: ToDo一覧
    static func findAllToDo(folderID: Int) -> [ToDo] {
            
        let objects = FolderDao.findByID(folderID: folderID)
        
        guard let todos = objects?.todos else {
            return []
        }
        return todos.sorted { $0.date! > $1.date! }
    }
}
