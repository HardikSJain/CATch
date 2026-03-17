import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import 'cubit/concepts_cubit.dart';

class ConceptsScreen extends StatelessWidget {
  const ConceptsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConceptsCubit, ConceptsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Learn',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      if (state.reviewDue > 0)
                        GestureDetector(
                          onTap: () => context.push('/learn/review'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.grey900,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Review (${state.reviewDue})',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 0, 24, 20),
                  child: Text(
                    'Theory, formulas & concepts',
                    style: TextStyle(fontSize: 14, color: AppColors.grey500),
                  ),
                ),

                // Section tabs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: Section.values.map((section) {
                      final isSelected =
                          state.selectedSection == section.code;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => context
                              .read<ConceptsCubit>()
                              .selectSection(section.code),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.grey900
                                  : AppColors.grey100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              section.label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.grey600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),

                // Concepts list
                Expanded(
                  child: state.loading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 1.5,
                          ),
                        )
                      : state.concepts.isEmpty
                          ? const Center(
                              child: Text(
                                'No concepts yet',
                                style: TextStyle(color: AppColors.grey500),
                              ),
                            )
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              itemCount: state.concepts.length,
                              itemBuilder: (context, index) {
                                final c = state.concepts[index];
                                return _ConceptTile(
                                  topic: c['topic'] as String,
                                  title: c['title'] as String,
                                  content: c['content'] as String,
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ConceptTile extends StatefulWidget {
  final String topic;
  final String title;
  final String content;

  const _ConceptTile({
    required this.topic,
    required this.title,
    required this.content,
  });

  @override
  State<_ConceptTile> createState() => _ConceptTileState();
}

class _ConceptTileState extends State<_ConceptTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        margin: const EdgeInsets.only(bottom: 1),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.grey200, width: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.topic.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                            color: AppColors.grey400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.remove : Icons.add,
                    size: 18,
                    color: AppColors.grey400,
                  ),
                ],
              ),
            ),
            if (_expanded)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  widget.content,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.7,
                    color: AppColors.grey700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
