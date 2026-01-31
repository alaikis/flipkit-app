import 'package:flutter/material.dart';
import '../services/learning_space_service.dart';
import '../data/app_db.dart';

class SpaceSwitcher extends StatefulWidget {
  final LearningSpaceService spaceService;
  final String parentId;
  final Function(String spaceId) onSpaceChanged;

  const SpaceSwitcher({
    super.key,
    required this.spaceService,
    required this.parentId,
    required this.onSpaceChanged,
  });

  @override
  State<SpaceSwitcher> createState() => _SpaceSwitcherState();
}

class _SpaceSwitcherState extends State<SpaceSwitcher> {
  List<Map<String, dynamic>> spaces = [];
  String? activeSpaceId;

  @override
  void initState() {
    super.initState();
    _loadSpaces();
  }

  Future<void> _loadSpaces() async {
    final s = await widget.spaceService.listSpaces(widget.parentId);
    final active = await widget.spaceService.getActiveSpace();
    setState(() {
      spaces = s;
      activeSpaceId = active;
    });
  }

  Future<void> _switchSpace(String spaceId) async {
    await widget.spaceService.setActiveSpace(spaceId);
    widget.onSpaceChanged(spaceId);
    setState(() => activeSpaceId = spaceId);
  }

  Future<void> _addChild() async {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('添加孩子'),
        content: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: '孩子名字')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('取消')),
          TextButton(
            onPressed: () async {
              final newId = await widget.spaceService.createLearningSpace(
                parentId: widget.parentId,
                childName: nameCtrl.text,
              );
              await _switchSpace(newId);
              await _loadSpaces();
              if (mounted) Navigator.pop(c);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('学习空间', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...spaces.map((s) => Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ElevatedButton(
                  onPressed: activeSpaceId == s['id'] ? null : () => _switchSpace(s['id']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: activeSpaceId == s['id'] ? Colors.blue : Colors.grey[300],
                  ),
                  child: Text(s['name'], style: TextStyle(color: activeSpaceId == s['id'] ? Colors.white : Colors.black)),
                ),
              )),
              ElevatedButton.icon(
                onPressed: _addChild,
                icon: const Icon(Icons.add),
                label: const Text('添加孩子'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
