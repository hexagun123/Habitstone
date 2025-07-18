// lib/features/main/presentation/widgets/goal_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/model/task.dart';
import '../../../../../core/model/goal.dart';

// class GoalList extends ConsumerWidget {
//   const GoalList({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final goals = ref.watch(goalsProvider);

//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Goals',
//                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                 ),
//                 Text(
//                   '${goals.length} goals',
//                   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                         color: Theme.of(context)
//                             .colorScheme
//                             .onSurface
//                             .withOpacity(0.6),
//                       ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             goals.isEmpty
//                 ? const _EmptyGoalsIndicator()
//                 : Column(
//                     children:
//                         goals.map((goal) => _GoalListItem(goal: goal)).toList(),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _GoalListItem extends ConsumerWidget {
//   final Goal goal;

//   const _GoalListItem({required this.goal});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12.0),
//       child: Card(
//         elevation: 1,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8.0),
//           side: BorderSide(
//             color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
//           ),
//         ),
//         child: ListTile(
//           contentPadding:
//               const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//           title: Text(
//             goal.title,
//             style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                   fontWeight: FontWeight.w500,
//                 ),
//           ),
//           subtitle: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (goal.description.isNotEmpty)
//                 Text(
//                   goal.description,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                         color: Theme.of(context)
//                             .colorScheme
//                             .onSurface
//                             .withOpacity(0.7),
//                       ),
//                 ),
//               const SizedBox(height: 4),
//               Row(
//                 children: [
//                   Icon(Icons.local_fire_department,
//                       size: 16,
//                       color: goal.streak > 0 ? Colors.orange : Colors.grey),
//                   const SizedBox(width: 4),
//                   Text(
//                     '${goal.streak} day${goal.streak == 1 ? '' : 's'} streak',
//                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                           color: goal.streak > 0 ? Colors.orange : Colors.grey,
//                         ),
//                   ),
//                   const SizedBox(width: 12),
//                   Icon(Icons.checklist, size: 16, color: Colors.blue),
//                   const SizedBox(width: 4),
//                   Text(
//                     '${goal.requiredDailyTasks} task${goal.requiredDailyTasks == 1 ? '' : 's'} daily',
//                     style: Theme.of(context).textTheme.bodySmall,
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           trailing: Checkbox(
//             value: goal.isCompletedToday,
//             onChanged: (value) {
//               ref
//                   .read(goalsProvider.notifier)
//                   .updateGoalCompletion(goal, value ?? false);
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _EmptyGoalsIndicator extends StatelessWidget {
//   const _EmptyGoalsIndicator();

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 32.0),
//         child: Text(
//           'No goals created yet',
//           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
//               ),
//         ),
//       ),
//     );
//   }
// }
