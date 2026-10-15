import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_provider.dart';
import '../widgets/app_bar_actions.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isAdmin = provider.isAdmin;
    final currentStudents = provider.students.where((s) => s.circleId == provider.selectedAttendanceCircleId).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('تحضير الطلاب للإدارة', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF065F46),
        foregroundColor: Colors.white,
        actions: const [UserAppBarActions()],
      ),
      body: Column(
        children: [
          const ReadOnlyBanner(),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: provider.circles.map((c) {
                final selected = c.id == provider.selectedAttendanceCircleId;
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    label: Text(c.name),
                    selected: selected,
                    onSelected: (_) => provider.setAttendanceCircle(c.id),
                  ),
                );
              }).toList(),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => provider.shiftAttendanceDate(-1)),
                  Text(provider.attendanceDateString, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => provider.shiftAttendanceDate(1)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('عدد الطلاب: ${currentStudents.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                if (isAdmin)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF047857),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => provider.markAllPresent(),
                    icon: const Icon(Icons.done_all, size: 16),
                    label: const Text('تحضير الكل كحاضر'),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'عرض الحضور فقط',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: currentStudents.isEmpty
                ? const Center(child: Text('لا يوجد طلاب مسجلون في هذه الحلقة'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: currentStudents.length,
                    itemBuilder: (context, index) {
                      final student = currentStudents[index];
                      final attendance = provider.getOrCreateAttendance(student.id, student.circleId);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  if (!isAdmin)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(attendance.status).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: _getStatusColor(attendance.status), width: 1),
                                      ),
                                      child: Text(
                                        attendance.status,
                                        style: TextStyle(
                                          color: _getStatusColor(attendance.status),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (isAdmin)
                                Row(
                                  children: ['حاضر', 'متأخر', 'غائب', 'معذور'].map((status) {
                                    final isSelected = attendance.status == status;
                                    return Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 2),
                                        child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: isSelected ? _getStatusColor(status) : null,
                                            foregroundColor: isSelected ? Colors.white : Colors.black87,
                                            padding: EdgeInsets.zero,
                                          ),
                                          onPressed: () => provider.updateAttendanceStatus(student.id, status),
                                          child: Text(status, style: const TextStyle(fontSize: 12)),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                )
                              else
                                Text(
                                  'تاريخ الرصد: ${attendance.date}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'حاضر':
        return Colors.green[700]!;
      case 'متأخر':
        return Colors.amber[800]!;
      case 'غائب':
        return Colors.red[700]!;
      case 'معذور':
        return Colors.blue[700]!;
      default:
        return Colors.grey;
    }
  }
}
