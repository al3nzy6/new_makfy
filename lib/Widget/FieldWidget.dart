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
  final Function(dynamic)? onChanged;
  final dynamic initialValue;

  FieldWidget({
    Key? key,
    required this.id,
    this.options,
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
    _initializeSelectedOption(
        widget.initialValue); // تعيين القيمة الأولية للخيار
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
          selectedTime = TimeOfDay(
              hour: int.parse(widget.initialValue.split(":")[0]),
              minute: int.parse(widget.initialValue.split(":")[1]));
          break;
        case 'File':
          _selectedImage = null;
          break;
      }
      widget.onChanged?.call(widget.initialValue);
    }
  }

  void _initializeSelectedOption(dynamic initalValue) {
    final optionsList = widget.options != null
        ? widget.options!.map((map) => Option.fromJson(map)).toList()
        : [];

    // تعيين القيمة الابتدائية إذا كانت متوفرة وتتطابق مع عنصر في optionsList
    void _initializeSelectedOption() {
      final optionsList = widget.options != null
          ? widget.options!.map((map) => Option.fromJson(map)).toList()
          : [];

      // إذا كانت optionsList غير فارغة، حاول مطابقة selectedOption بناءً على initialValue
      if (optionsList.isNotEmpty) {
        selectedOption = (widget.initialValue != null)
            ? optionsList.firstWhere(
                (option) => option.id == widget.initialValue,
                orElse: () =>
                    optionsList.first) // استخدم الخيار الأول كخيار افتراضي
            : optionsList.first;

        // التأكد من أن selectedOption يتطابق مع عنصر في optionsList
        if (!optionsList.contains(selectedOption)) {
          selectedOption =
              optionsList.first; // تعيين الخيار الأول إذا لم يكن هناك تطابق
        }
      }
    }
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
      setState(() {
        selectedDate = picked;
        widget.onChanged?.call(selectedDate.toLocal().toString().split(' ')[0]);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialEntryMode: TimePickerEntryMode.input,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
        widget.onChanged?.call(selectedTime.format(context));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      child: Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.showName,
              style: TextStyle(fontSize: 19),
            ),
          ),
          _buildFieldBasedOnType(screenWidth),
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
        return (ModalRoute.of(context)?.settings.name == '/create_service')
            ? _buildValidatedSingleSelect()
            : _buildValidatedMultiSelect();
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

    // تحقق من أن selectedOption متطابقة مع أحد الخيارات في DropdownMenuItem
    if (!optionsList.contains(selectedOption)) {
      selectedOption = null; // اجعلها null إذا لم يكن هناك تطابق
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
            ? 'Selected values: ${_selectedValues.join(', ')}'
            : 'Choose items',
        style: TextStyle(fontSize: 16, color: Colors.black),
      ),
      initialValue: optionsList
          .where((option) => _selectedValues.contains(option.name))
          .toList(),
      items: optionsList
          .map((option) => MultiSelectItem<Option>(option, option.name))
          .toList(),
      onConfirm: (results) {
        setState(() {
          _selectedIds = results.map((option) => option.id).toList();
          _selectedValues = results.map((option) => option.name).toList();
          widget.onChanged?.call(_selectedIds.join(', '));
        });
      },
    );
  }

  Widget _buildCustomContainer(
      {required double screenWidth, required String text}) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0XFFEF5B2C),
        borderRadius: BorderRadius.circular(10),
      ),
      height: 60,
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
              ? Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                )
              : widget.initialValue != null && widget.initialValue is String
                  ? Image.network(
                      widget.initialValue, // عرض الصورة من الرابط الافتراضي
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : Text(
                      'اختر صورة',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: Icon(Icons.photo_library),
              label: Text(
                  _selectedImage == null ? 'اختر من المعرض' : 'تغيير الصورة'),
            ),
            SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: Icon(Icons.camera),
              label:
                  Text(_selectedImage == null ? 'التقاط صورة' : 'التقاط جديدة'),
            ),
          ],
        ),
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
}
