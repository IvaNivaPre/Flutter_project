import 'dart:core';
import 'package:first_application/services/crud/crud_exceptions.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart'
        show getApplicationDocumentsDirectory,
        MissingPlatformDirectoryException;
import 'package:sqflite/sqflite.dart';


class NotesService {
  Database? _db;

  Database _getDatabaseOrThrowError() {
    final db = _db;
    if (db == null) throw DatabaseNotOpenException();
    return db;
  }

  Future<void> open() async {
    if (_db != null) throw DatabaseAlreadyOpenException();

    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      _db = await openDatabase(dbPath);

      await _db?.execute(createUsersTable);
      await _db?.execute(createNotesTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectoryException();
    }
  }

  Future<void> close() async {
    if (_db == null) throw DatabaseNotOpenException();
    _db?.close();
    _db = null;
  }

  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrowError();
    final deletedCount = await db.delete(
      usersTable,
      where: '$emailColumn = ?',
      whereArgs: [email.toLowerCase()]
    );
    if (deletedCount == 0) throw CouldNotFindUserException();
  }

  Future<DatabaseUser> createUser({required email}) async {
    final db = _getDatabaseOrThrowError();
    final results = await db.query(
      usersTable,
      where: '$emailColumn = ?',
      whereArgs: [email.toLowerCase()],
      limit: 1
    );
    if (results.isNotEmpty) throw UserAlreadyExistsException();

    final id = await db.insert(
      usersTable, 
      {emailColumn: email.toLowerCase()}
    );

    return DatabaseUser(id: id, email: email);
  }

  Future<DatabaseUser> getUser({required email}) async {
    final db = _getDatabaseOrThrowError();

    final request = await db.query(
      usersTable,
      where: '$emailColumn = ?',
      whereArgs: [email.toLowerCase()],
      limit: 1
    );

    if (request.isEmpty) throw CouldNotFindUserException();

    return DatabaseUser.fromRow(request.first);
  }

  Future<DatabaseNote> createNote({
    required DatabaseUser owner,
    String text = '',
  }) async {
    final db = _getDatabaseOrThrowError();
    await getUser(email: owner.email);
    
    final noteId = await db.insert(
      notesTable,
      {
        userIdColumn: owner.id,
        textColumn: text
      }
    );

    return DatabaseNote(id: noteId, userId: owner.id, text: text);
  }

  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrowError();

    final deletedCount = await db.delete(
      notesTable,
      where: '$idColumn = ?',
      whereArgs: [id.toString()]
    );

    if (deletedCount == 0) throw CouldNotFindNoteException();
  }

  Future<void> deleteAllNotes() async {
    final db = _getDatabaseOrThrowError();
    await db.delete(notesTable);
  }

  Future<DatabaseNote> getNote({required int id}) async {
    final db = _getDatabaseOrThrowError();
    final request = await db.query(
      notesTable,
      where: '$idColumn = ?',
      whereArgs: [id],
      limit: 1
    );

    if (request.isEmpty) throw CouldNotFindNoteException();

    return DatabaseNote.fromRow(request.first);
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    final db = _getDatabaseOrThrowError();
    final request = await db.query(notesTable);

    return request.map((el) => DatabaseNote.fromRow(el));
  }

  Future<DatabaseNote> updateNote({
    required id,
    required text
    }) async {
      final db = _getDatabaseOrThrowError();
      await getNote(id: id);
      
      final updatesCount = await db.update(
        notesTable,
        {textColumn: text},
        where: '$idColumn = ?',
        whereArgs: [id]
      );
      if (updatesCount == 0) throw CouldNotUpdateNoteException();

      return await getNote(id: id);
  }
}


@immutable
class DatabaseUser {
  final int id;
  final String email;
  const DatabaseUser({required this.id, required this.email});

  DatabaseUser.fromRow(Map<String, Object?> map)
                : id = map[idColumn] as int,
                email = map[emailColumn] as String;
  
  @override
  String toString() => 'Person, ID: $id, email: $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}


@immutable
class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  const DatabaseNote({
    required this.id,
    required this.userId,
    required this.text
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
            : id = map[idColumn] as int,
            userId = map[userIdColumn] as int,
            text = map[textColumn] as String;
    
  @override
  String toString() => 'Note ID: $id, User ID: $userId';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';
const notesTable = 'notes';
const usersTable = 'users';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';

const createUsersTable = '''
      CREATE TABLE "users" IF NOT EXISTS (
        "id"	INTEGER NOT NULL,
        "email"	TEXT,
        PRIMARY KEY("id" AUTOINCREMENT)
      );''';

const createNotesTable = '''
      CREATE TABLE "notes" IF NOT EXISTS (
        "id"	INTEGER NOT NULL,
        "user_id"	INTEGER NOT NULL,
        "text"	TEXT,
        PRIMARY KEY("id" AUTOINCREMENT),
        FOREIGN KEY("user_id") REFERENCES ""
      );''';