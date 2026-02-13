import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../widgets/common_appbar.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final apiService = context.read<ApiService>();
    await apiService.fetchUsers();
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final apiService = context.watch<ApiService>();
    
    return Scaffold(
      appBar: const CommonAppBar(title: 'Users'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Total users: ${apiService.users.length}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.pushNamed(context, '/create-user');
                          _loadUsers();
                        },
                        icon: const Icon(Icons.person_add),
                        label: const Text('Add'),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: apiService.users.isEmpty
                        ? const Center(child: Text('No users yet'))
                        : ListView.builder(
                            itemCount: apiService.users.length,
                            itemBuilder: (context, i) {
                              final u = apiService.users[i];
                              return Card(
                                child: ListTile(
                                  title: Text(u.name),
                                  subtitle: Text(
                                    u.email +
                                        (u.expiryDate != null
                                            ? ' • Expires ${u.expiryDate!.toLocal().toString().split(' ')[0]}'
                                            : ' • No expiry'),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (u.isBlocked)
                                        const Chip(
                                          label: Text('Blocked', style: TextStyle(fontSize: 11)),
                                          backgroundColor: Colors.red,
                                          labelStyle: TextStyle(color: Colors.white),
                                        ),
                                      PopupMenuButton<String>(
                                        onSelected: (v) async {
                                          if (v == 'block') {
                                            await apiService.blockUser(u.id);
                                          } else if (v == 'unblock') {
                                            await apiService.unblockUser(u.id);
                                          }
                                        },
                                        itemBuilder: (_) => [
                                          if (!u.isBlocked)
                                            const PopupMenuItem(value: 'block', child: Text('Block User'))
                                          else
                                            const PopupMenuItem(value: 'unblock', child: Text('Unblock User')),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  )
                ],
              ),
            ),
    );
  }
}
