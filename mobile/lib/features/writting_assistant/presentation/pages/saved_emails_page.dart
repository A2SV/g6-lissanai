import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/bloc/saved_email_bloc.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/bloc/saved_email_event.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/bloc/saved_email_state.dart';

class SavedEmailsPage extends StatefulWidget {
  const SavedEmailsPage({super.key});

  @override
  State<SavedEmailsPage> createState() => _SavedEmailsPageState();
}

class _SavedEmailsPageState extends State<SavedEmailsPage> {
  @override
  void initState() {
    super.initState();
    context.read<SavedEmailBloc>().add(LoadSavedEmailsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Saved Emails',
          style: TextStyle(
            color: Color(0xFF112D4F),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF112D4F)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          BlocBuilder<SavedEmailBloc, SavedEmailState>(
            builder: (context, state) {
              if (state is SavedEmailsLoaded && state.emails.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.clear_all, color: Color(0xFF112D4F)),
                  onPressed: () => _showClearAllDialog(context),
                  tooltip: 'Clear All',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocListener<SavedEmailBloc, SavedEmailState>(
        listener: (context, state) {
          if (state is SavedEmailDeleted) {
            // Automatically reload the list after successful deletion
            context.read<SavedEmailBloc>().add(LoadSavedEmailsEvent());
          } else if (state is AllEmailsCleared) {
            // Automatically reload the list after clearing all emails
            context.read<SavedEmailBloc>().add(LoadSavedEmailsEvent());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ All emails cleared successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: BlocBuilder<SavedEmailBloc, SavedEmailState>(
          builder: (context, state) {
            if (state is SavedEmailLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF112D4F)),
              );
            } else if (state is SavedEmailError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<SavedEmailBloc>().add(
                          LoadSavedEmailsEvent(),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (state is SavedEmailsLoaded) {
              if (state.emails.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.email_outlined, color: Colors.grey, size: 64),
                      SizedBox(height: 16),
                      Text(
                        'No saved emails yet',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.emails.length,
                itemBuilder: (context, index) {
                  final email = state.emails[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          email.subject,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF112D4F),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          email.body,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: email.body),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      '✅ Email copied to clipboard!',
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.copy, size: 18),
                              label: const Text('Copy'),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF009688),
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () {
                                _showDeleteDialog(context, email.id);
                              },
                              icon: const Icon(Icons.delete, size: 18),
                              label: const Text('Delete'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext pageContext, String id) {
    showDialog(
      context: pageContext,
      useRootNavigator: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Email'),
        content: const Text('Are you sure you want to delete this email?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              pageContext.read<SavedEmailBloc>().add(
                DeleteSavedEmailEvent(id: id),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext pageContext) {
    showDialog(
      context: pageContext,
      useRootNavigator: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear All Emails'),
        content: const Text('Are you sure you want to clear all emails?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              pageContext.read<SavedEmailBloc>().add(ClearAllEmailsEvent());
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
