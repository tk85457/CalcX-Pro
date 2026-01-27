import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/history_entry.dart';
import '../providers/history_provider.dart';
import '../providers/calculator_provider.dart';

class HistoryDrawer extends StatefulWidget {
  const HistoryDrawer({super.key});

  @override
  State<HistoryDrawer> createState() => _HistoryDrawerState();
}

class _HistoryDrawerState extends State<HistoryDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<HistoryProvider, CalculatorProvider>(
      builder: (context, historyProvider, calculatorProvider, child) {
        // Filter history by current calculator type
        final filteredHistory = historyProvider.history
            .where((entry) =>
                entry.calculatorType == calculatorProvider.calculatorType)
            .toList();

        return Drawer(
          child: Column(
            children: [
              // Animated Header
              _AnimatedHistoryHeader(
                animation: _animation,
                onClear: historyProvider.history.isNotEmpty
                    ? () => historyProvider.clearHistory()
                    : null,
              ),
              Expanded(
                child: filteredHistory.isEmpty
                    ? _AnimatedEmptyState(animation: _animation)
                    : AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return ListView.builder(
                            itemCount: filteredHistory.length,
                            itemBuilder: (context, index) {
                              final entry = filteredHistory[index];

                              // Calculate stagger
                              final staggerDelay = (index * 0.06).clamp(0.0, 0.5);
                              final staggerEnd = (staggerDelay + 0.4).clamp(0.0, 1.0);

                              double progress = 0.0;
                              if (_animation.value > staggerDelay) {
                                progress = ((_animation.value - staggerDelay) / (staggerEnd - staggerDelay)).clamp(0.0, 1.0);
                              }

                              return Transform.translate(
                                offset: Offset(50 * (1 - progress), 0),
                                child: Opacity(
                                  opacity: progress,
                                  child: _AnimatedHistoryItem(
                                    entry: entry,
                                    onDismissed: () {
                                      final entryIndex = historyProvider.history.indexOf(entry);
                                      historyProvider.deleteEntry(entryIndex);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text('Calculation deleted'),
                                          action: SnackBarAction(
                                            label: 'Undo',
                                            onPressed: () => historyProvider.addEntry(
                                              entry.expression,
                                              entry.result,
                                              entry.calculatorType,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    onExpressionTap: () {
                                      Provider.of<CalculatorProvider>(context, listen: false)
                                          .setExpression(entry.expression);
                                      Navigator.of(context).pop();
                                    },
                                    onResultTap: () {
                                      Provider.of<CalculatorProvider>(context, listen: false)
                                          .setDisplay(entry.result);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AnimatedHistoryHeader extends StatelessWidget {
  final Animation<double> animation;
  final VoidCallback? onClear;

  const _AnimatedHistoryHeader({
    required this.animation,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            bottom: 16,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1 + animation.value * 0.3, -1),
              end: Alignment(1 - animation.value * 0.3, 1),
              colors: [
                colorScheme.primaryContainer,
                colorScheme.primaryContainer.withValues(alpha: 0.8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Transform.translate(
            offset: Offset(-30 * (1 - animation.value), 0),
            child: Opacity(
              opacity: animation.value,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.history,
                      color: colorScheme.onPrimaryContainer,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Calculation History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  if (onClear != null)
                    TextButton.icon(
                      onPressed: onClear,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Clear'),
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.error,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedEmptyState extends StatelessWidget {
  final Animation<double> animation;

  const _AnimatedEmptyState({required this.animation});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Center(
          child: Transform.scale(
            scale: 0.5 + animation.value * 0.5,
            child: Opacity(
              opacity: animation.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.history_toggle_off,
                      size: 64,
                      color: colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No calculations yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your calculation history will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedHistoryItem extends StatefulWidget {
  final HistoryEntry entry;
  final VoidCallback onDismissed;
  final VoidCallback onExpressionTap;
  final VoidCallback onResultTap;

  const _AnimatedHistoryItem({
    required this.entry,
    required this.onDismissed,
    required this.onExpressionTap,
    required this.onResultTap,
  });

  @override
  State<_AnimatedHistoryItem> createState() => _AnimatedHistoryItemState();
}

class _AnimatedHistoryItemState extends State<_AnimatedHistoryItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Dismissible(
            key: Key(widget.entry.timestamp.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.red.withValues(alpha: 0.8),
                    Colors.red,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.delete_forever,
                color: Colors.white,
                size: 28,
              ),
            ),
            onDismissed: (_) => widget.onDismissed(),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Expression row
                  InkWell(
                    onTapDown: (_) => _controller.forward(),
                    onTapUp: (_) {
                      _controller.reverse();
                      widget.onExpressionTap();
                    },
                    onTapCancel: () => _controller.reverse(),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.entry.expression,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.touch_app,
                              size: 14,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Result row
                  InkWell(
                    onTapDown: (_) => _controller.forward(),
                    onTapUp: (_) {
                      _controller.reverse();
                      widget.onResultTap();
                    },
                    onTapCancel: () => _controller.reverse(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.05),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '= ${widget.entry.result}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                          Text(
                            DateFormat('MMM dd, HH:mm').format(widget.entry.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

