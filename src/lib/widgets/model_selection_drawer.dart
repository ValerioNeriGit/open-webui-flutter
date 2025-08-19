import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/model.dart';
import '../services/model_service.dart';

class ModelSelectionDrawer extends StatefulWidget {
  final Model? selectedModel;
  final Function(Model) onModelSelected;

  const ModelSelectionDrawer({
    super.key,
    required this.selectedModel,
    required this.onModelSelected,
  });

  @override
  State<ModelSelectionDrawer> createState() => _ModelSelectionDrawerState();
}

class _ModelSelectionDrawerState extends State<ModelSelectionDrawer> {
  final _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final modelService = Provider.of<ModelService>(context);
    final filteredModels = modelService.availableModels
        .where((model) =>
            model.name.toLowerCase().contains(_searchText.toLowerCase()))
        .toList();

    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: const Text('Select a Model'),
            automaticallyImplyLeading: false,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search models...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredModels.length,
              itemBuilder: (context, index) {
                final model = filteredModels[index];
                final isSelected = model.id == widget.selectedModel?.id;
                return ListTile(
                  title: Text(model.name),
                  tileColor: isSelected ? Theme.of(context).colorScheme.primary.withAlpha(51) : null,
                  onTap: () {
                    widget.onModelSelected(model);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
