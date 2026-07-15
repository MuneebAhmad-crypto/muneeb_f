import 'package:flutter/material.dart';
import 'note.dart';
import 'storage_service.dart';
import 'note_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  List<Note> notes = [];
  List<Note> filteredNotes = [];

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<void> loadNotes() async {
    notes = await StorageService.loadNotes();

    setState(() {
      filteredNotes = List.from(notes);
    });
  }

  Future<void> addNote() async {
    if (titleController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty) {
      return;
    }

    Note note = Note(
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
    );

    notes.add(note);

    await StorageService.saveNotes(notes);

    titleController.clear();
    descriptionController.clear();

    searchNotes(searchController.text);
  }

  Future<void> deleteNote(Note note) async {
    notes.remove(note);

    await StorageService.saveNotes(notes);

    searchNotes(searchController.text);
  }

  void searchNotes(String value) {
    setState(() {
      if (value.isEmpty) {
        filteredNotes = List.from(notes);
      } else {
        filteredNotes = notes.where((note) {
          return note.title
              .toLowerCase()
              .contains(value.toLowerCase()) ||
              note.description
                  .toLowerCase()
                  .contains(value.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black26,
      appBar: AppBar(
        backgroundColor: Colors.black38,
        title: const Text("Notes Manager📝", style: TextStyle(color: Colors.white),),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: "Search Notes",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: searchNotes,
            ),

            const SizedBox(height: 15),

            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: addNote,
                child: const Text("Save Note"),
              ),
            ),

            const SizedBox(height: 15),

            Expanded(
              child: filteredNotes.isEmpty
                  ? const Center(
                child: Text(
                  "No Notes Found",
                  style: TextStyle(fontSize: 18),
                ),
              )
                  : ListView.builder(
                itemCount: filteredNotes.length,
                itemBuilder: (context, index) {
                  return NoteCard(
                    note: filteredNotes[index],
                    onDelete: () =>
                        deleteNote(filteredNotes[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}