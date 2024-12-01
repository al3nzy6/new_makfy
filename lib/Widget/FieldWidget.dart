import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:makfy_new/Models/Option.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'dart:io';

class FieldWidget extends StatefulWidget {
  final int id;
  final List<Map<String, dynamic>>? options;
  final String name;
  final String showName;
  final String type;
  final bool? required;
  final double? width;
  final Function(dynamic)? onChanged;
  final dynamic initialValue;

  FieldWidget({
    Key? key,
    required this.id,
    this.options,
    this.width,
    required this.name,
    required this.showName,
    required this.type,
    this.required = false,
    this.onChanged,
    this.initialValue,
  }) : super(key: key);

  @override
  State<FieldWidget> createState() => _FieldWidgetState();
}

class _FieldWidgetState extends State<FieldWidget> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  List<int> _selectedIds = [];
  List<String> _selectedValues = [];
  File? _selectedImage;
  Option? selectedOption; // متغير الحالة للحفاظ على الخيار المحدد

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeDefaultValues();
  }

  void _initializeDefaultValues() {
    if (widget.initialValue != null) {
      switch (widget.type) {
        case 'String':
          _selectedValues = [widget.initialValue.toString()];
          break;
        case 'Date':
          selectedDate = DateTime.parse(widget.initialValue);
          break;
        case 'Time':
          final normalizedTime = normalizeTime(widget.initialValue);
          selectedTime = parseTime(normalizedTime);
          break;
        case 'File':
          _selectedImage = null;
          break;
        case 'Select':
          _initializeSelectedOption(widget.initialValue);
          break;
      }
      widget.onChanged?.call(widget.initialValue);
    }
  }

  String normalizeTime(String time) {
    return time.replaceAll('ص', 'AM').replaceAll('م', 'PM');
  }

  TimeOfDay parseTime(String time) {
    // تحويل "ص" و "م" إلى AM و PM
    final normalizedTime = time.replaceAll('ص', 'AM').replaceAll('م', 'PM');

    // استخراج الساعة والدقيقة والفترة (AM/PM)
    final parts = normalizedTime.split(' ');
    final timeParts = parts[0].split(':'); // الجزء الأول: الساعة والدقيقة
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final isAm = parts[1].toUpperCase() == 'AM'; // التحقق إذا كانت الفترة AM

    // إذا كانت الفترة PM والساعة أقل من 12، نضيف 12 للساعة لتكون في صيغة 24 ساعة
    final adjustedHour =
        (hour == 12 ? (isAm ? 0 : 12) : (isAm ? hour : hour + 12));

    return TimeOfDay(hour: adjustedHour, minute: minute);
  }

  void _initializeSelectedOption(dynamic initialValue) {
    // تحويل initialValue إلى int إذا كان نصيًا
    initialValue = int.tryParse(initialValue.toString());

    // تعيين الخيارات من widget.options
    final List<Option> optionsList = widget.options != null
        ? widget.options!.map((map) => Option.fromJson(map)).toList()
        : [];
    // إذا كانت optionsList غير فارغة، حاول مطابقة selectedOption بناءً على initialValue
    setState(() {
      if (optionsList.isNotEmpty) {
        if (mounted) {
          selectedOption = initialValue != null
              ? optionsList.firstWhere(
                  (option) => option.id == initialValue,
                  orElse: () => optionsList.first, // استخدام دالة تُعيد العنصر
                )
              : optionsList.first;
        }

        // طباعة البيانات للتأكد
        print(
            "Selected Option: ${selectedOption?.id}, ${selectedOption?.name}");
      } else {
        print("Options list is empty");
        selectedOption = null; // لا يوجد خيارات متاحة
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        widget.onChanged?.call(_selectedImage);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      if (mounted) {
        setState(() {
          selectedDate = picked;
          widget.onChanged
              ?.call(selectedDate.toLocal().toString().split(' ')[0]);
        });
      }
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialEntryMode: TimePickerEntryMode.input,
      initialTime: selectedTime,
    );

    if (pickedTime != null && pickedTime != selectedTime) {
      if (mounted) {
        setState(() {
          selectedTime = pickedTime;

          // تحويل الوقت إلى التنسيق الصحيح (AM/PM)
          final formattedTime = formatTime(selectedTime, context);
          widget.onChanged
              ?.call(formattedTime); // قم بإعادة الوقت بالتنسيق المطلوب
        });
      }
    }
  }

  String formatTime(TimeOfDay time, BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    return localizations.formatTimeOfDay(
      time,
      alwaysUse24HourFormat: false, // تأكد من استخدام صيغة 12 ساعة
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      child: Wrap(
        spacing: 20,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 15),
            child: Text(
              widget.showName,
              style: TextStyle(fontSize: 19),
            ),
          ),
          Container(
              padding: EdgeInsets.all(5),
              width: MediaQuery.of(context).size.width * 0.6,
              child: _buildFieldBasedOnType(screenWidth)),
        ],
      ),
    );
  }

  Widget _buildFieldBasedOnType(double screenWidth) {
    switch (widget.type) {
      case 'String':
        return _buildValidatedTextField();
      case 'Date':
        return _buildValidatedDatePicker(screenWidth);
      case 'Time':
        return _buildValidatedTimePicker(screenWidth);
      case 'Select':
        return _buildValidatedSingleSelect();
      case 'File':
        return _buildImagePicker(screenWidth);
      default:
        return Text('Invalid field type');
    }
  }

  Widget _buildValidatedTextField() {
    return TextFormField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: widget.showName,
      ),
      initialValue: widget.initialValue?.toString(),
      onChanged: (value) {
        widget.onChanged?.call(value);
      },
    );
  }

  Widget _buildValidatedDatePicker(double screenWidth) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: _buildCustomContainer(
        screenWidth: screenWidth,
        text: "${selectedDate.toLocal()}".split(' ')[0],
      ),
    );
  }

  Widget _buildValidatedTimePicker(double screenWidth) {
    return InkWell(
      onTap: () => _selectTime(context),
      child: _buildCustomContainer(
        screenWidth: screenWidth,
        text: selectedTime.format(context),
      ),
    );
  }

  Widget _buildValidatedSingleSelect() {
    final List<Option> optionsList = widget.options != null
        ? widget.options!.map((map) => Option.fromJson(map)).toList()
        : [];

    // التأكد من أن selectedOption تُشير إلى كائن داخل optionsList
    if (selectedOption != null) {
      selectedOption = optionsList.firstWhere(
        (option) => option.id == selectedOption!.id,
        orElse: () => optionsList.first, // إذا لم يتم العثور على تطابق
      );
    } else {
      selectedOption = null;
    }

    return DropdownButton<Option>(
      isExpanded: true,
      value: selectedOption,
      hint: Text('اختر'),
      items: optionsList.map((option) {
        return DropdownMenuItem<Option>(
          value: option,
          child: Text(option.name),
        );
      }).toList(),
      onChanged: (newOption) {
        setState(() {
          selectedOption = newOption;
          _selectedValues = [newOption!.name];
          _selectedIds = [newOption.id];
          widget.onChanged?.call(_selectedIds.first.toString());
        });
      },
    );
  }

  Widget _buildValidatedMultiSelect() {
    final List<Option> optionsList = widget.options != null
        ? widget.options!.map((map) => Option.fromJson(map)).toList()
        : [];

    return MultiSelectDialogField<Option>(
      searchable: true,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue, width: 1.5),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      buttonText: Text(
        _selectedValues.isNotEmpty
            ? 'تم اختيار : ${_selectedValues.first}' // تعديل النص ليعرض خيارًا واحدًا فقط
            : 'الرجاء اختر',
        style: TextStyle(fontSize: 16, color: Colors.black),
      ),
      initialValue: optionsList
          .where((option) => _selectedValues.contains(option.name))
          .toList(),
      items: optionsList
          .map((option) => MultiSelectItem<Option>(option, option.name))
          .toList(),
      onConfirm: (results) {
        if (results.isNotEmpty) {
          if (mounted) {
            setState(() {
              // السماح باختيار عنصر واحد فقط
              final selectedOption = results.first;
              _selectedIds = [selectedOption.id];
              _selectedValues = [selectedOption.name];
              widget.onChanged?.call(_selectedIds.first.toString());
            });
          }
        }
      },
      // تفعيل وضع الاختيار الفردي
      chipDisplay: MultiSelectChipDisplay.none(),
    );
  }

  Widget _buildCustomContainer(
      {required double screenWidth, required String text}) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0XFFEF5B2C),
        borderRadius: BorderRadius.circular(10),
      ),
      height: 35,
      width: screenWidth * 0.95,
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }

  Widget _buildImagePicker(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(children: [
          Container(
            height: 150,
            width: screenWidth * 0.95,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 1.5),
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[200],
            ),
            alignment: Alignment.center,
            child: _selectedImage != null
                ? Stack(children: [
                    Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: Icon(Icons.photo_library),
                        label: Text('تغيير الصورة'),
                      ),
                    ),
                  ])
                : widget.initialValue != null
                    ? _buildImageFromInitialValue(widget.initialValue)
                    : ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: Icon(Icons.photo_library),
                        label: Text(_selectedImage == null
                            ? 'اضافة صورة من البوم الكاميرا'
                            : 'تغيير الصورة'),
                      ),
          ),
        ]),
        SizedBox(height: 10),
        if (widget.required == true &&
            _selectedImage == null &&
            widget.initialValue == null)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              'الصورة مطلوبة',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  /// Helper method to handle different types of `initialValue`
  Widget _buildImageFromInitialValue(dynamic initialValue) {
    // print(initialValue);
    if (initialValue is String) {
      if (initialValue.startsWith('file://')) {
        // معالجة مسار ملف محلي
        final filePath = initialValue.replaceFirst('file://', '');
        return Stack(children: [
          Image.file(
            File(filePath),
            fit: BoxFit.cover,
            width: double.infinity,
          ),
          Center(
            child: ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: Icon(Icons.photo_library),
              label: Text('تغيير الصورة'),
            ),
          ),
        ]);
      } else if (initialValue.startsWith('http://') ||
          initialValue.startsWith('https://')) {
        // معالجة رابط شبكة
        return Stack(children: [
          Image.network(
            initialValue,
            fit: BoxFit.cover,
            width: double.infinity,
          ),
          Center(
            child: ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: Icon(Icons.photo_library),
              label: Text('تغير الصورة'),
            ),
          ),
        ]);
      }
    }
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => _pickImage(ImageSource.gallery),
        icon: Icon(Icons.photo_library),
        label: Text('تغير الصورة'),
      ),
    );
  }
}
