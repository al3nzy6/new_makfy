import 'package:flutter/material.dart';
import 'package:makfy_new/Utilities/ApiConfig.dart';
import 'package:makfy_new/Widget/FieldWidget.dart';
import 'package:makfy_new/Widget/H2Text.dart';
import 'package:makfy_new/Widget/MainScreenWidget.dart';
import 'package:makfy_new/Models/Vacation.dart';

class VacationScreen extends StatefulWidget {
  VacationScreen({Key? key}) : super(key: key);

  @override
  State<VacationScreen> createState() => _VacationScreenState();
}

class _VacationScreenState extends State<VacationScreen> {
  bool isLoading = false;
  String? statusMessage;

  // بيانات الإجازة
  String? vacation_from;
  String? vacation_to;

  // قائمة الإجازات
  List<Vacation> vacations = [];

  @override
  void initState() {
    super.initState();
    _fetchVacations();
  }

  // جلب قائمة الإجازات
  Future<void> _fetchVacations() async {
    setState(() {
      isLoading = true;
      statusMessage = "جاري جلب قائمة الإجازات...";
    });

    try {
      final result = await ApiConfig.getVacations();
      setState(() {
        vacations = result.map((e) => Vacation.fromMap(e)).toList();
        statusMessage = "تم تحميل قائمة الإجازات";
      });
    } catch (e) {
      setState(() {
        statusMessage = "حدث خطأ أثناء جلب الإجازات: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // إنشاء إجازة
  Future<void> _createVacation() async {
    if (vacation_from == null || vacation_to == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال جميع البيانات')),
      );
      return;
    }

    setState(() {
      isLoading = true;
      statusMessage = "جاري إنشاء الإجازة...";
    });

    try {
      final newVacation = Vacation(
        id: 0,
        user_id: 0,
        vacation_from: vacation_from!,
        vacation_to: vacation_to!,
      );
      await ApiConfig.createVacation(newVacation);
      _fetchVacations();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إنشاء الإجازة بنجاح!')),
      );
    } catch (e) {
      setState(() {
        statusMessage = "فشل إنشاء الإجازة: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // حذف إجازة
  Future<void> _deleteVacation(int vacationId) async {
    setState(() {
      isLoading = true;
      statusMessage = "جاري حذف الإجازة...";
    });

    try {
      await ApiConfig.deleteVacation(vacationId);
      _fetchVacations();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف الإجازة بنجاح!')),
      );
    } catch (e) {
      setState(() {
        statusMessage = "فشل حذف الإجازة: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScreenWidget(
      isLoading: isLoading,
      start: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          H2Text(
            lines: 3,
            text:
                "الرجاء إدخال تاريخ بداية ونهاية الإجازة، أو إدارة الإجازات المسجلة.",
          ),
          // حقول إنشاء إجازة
          FieldWidget(
            id: 1,
            name: "vacation_from",
            showName: "بداية الإجازة",
            type: 'Date',
            onChanged: (value) {
              vacation_from = value;
            },
          ),
          FieldWidget(
            id: 2,
            name: "vacation_to",
            showName: "نهاية الإجازة",
            type: 'Date',
            onChanged: (value) {
              vacation_to = value;
            },
          ),
          ElevatedButton(
            onPressed: _createVacation,
            child: const Text("إنشاء إجازة"),
          ),
          const Divider(),
          const Text(
            "الإجازات المسجلة:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 300, // تحديد ارتفاع ثابت أو مناسب
            child: vacations.isEmpty
                ? Center(child: Text("لا توجد إجازات مسجلة"))
                : ListView.builder(
                    itemCount: vacations.length,
                    itemBuilder: (context, index) {
                      final vacation = vacations[index];
                      return ListTile(
                        title: Text(
                            "من ${vacation.vacation_from} إلى ${vacation.vacation_to}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteVacation(vacation.id),
                        ),
                      );
                    },
                  ),
          ),
          if (statusMessage != null) ...[
            Text(
              statusMessage!,
              style: TextStyle(fontSize: 16, color: Colors.blueGrey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}
