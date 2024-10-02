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

  FieldWidget({
    Key? key,
    required this.id,
    this.options,
    required this.name,
    required this.showName,
    required this.type,
    this.required = false,
    this.onChanged,
  }) : super(key: key);

  @override
  State<FieldWidget> createState() => _FieldWidgetState();
}

class _FieldWidgetState extends State<FieldWidget> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  List<int> _selectedIds = [];
  List<String> _selectedValues = [];
  File? _selectedImage; // لتخزين الصورة المختارة

  final ImagePicker _picker = ImagePicker(); // مكتبة لالتقاط الصور

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile =
        await _picker.pickImage(source: source); // استخدم المدخل source
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path); // تعيين الصورة
        widget.onChanged?.call(_selectedImage); // تمرير الصورة
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day),
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
        widget.onChanged
            ?.call(selectedTime.format(context)); // Passing the new time
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
      case 'File': // النوع الجديد لاختيار الصورة
        return _buildImagePicker(screenWidth);
      default:
        return Text('Invalid field type');
    }
  }

  Widget _buildValidatedTextField() {
    return FormField<String>(
      validator: (value) {
        if (widget.required == true && (value == null || value.isEmpty)) {
          return "الرجاء ادخال قيمة بهذا الحقل";
        }
        return null;
      },
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: widget.showName,
              ),
              onChanged: (value) {
                state.didChange(value); // Update FormField state
                widget.onChanged?.call(value);
              },
            ),
            if (state.hasError) ...[
              SizedBox(height: 5),
              Text(
                state.errorText ?? '',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildValidatedDatePicker(double screenWidth) {
    return FormField<DateTime>(
      validator: (value) {
        if (widget.required == true && value == null) {
          return 'الرجاء اختيار قيمة';
        }
        return null;
      },
      builder: (FormFieldState<DateTime> state) {
        return InkWell(
          onTap: () async {
            await _selectDate(context);
            state.didChange(selectedDate); // Update FormField state
          },
          child: _buildCustomContainer(
            screenWidth: screenWidth,
            text: "${selectedDate.toLocal()}".split(' ')[0],
          ),
        );
      },
    );
  }

  Widget _buildValidatedTimePicker(double screenWidth) {
    return FormField<TimeOfDay>(
      validator: (value) {
        if (widget.required == true && value == null) {
          return 'Please select a time';
        }
        return null;
      },
      builder: (FormFieldState<TimeOfDay> state) {
        return InkWell(
          onTap: () async {
            await _selectTime(context);
            state.didChange(selectedTime); // Update FormField state
          },
          child: _buildCustomContainer(
            screenWidth: screenWidth,
            text: "${selectedTime.format(context)}",
          ),
        );
      },
    );
  }

  Widget _buildValidatedSingleSelect() {
    final List<Option> optionsList = widget.options != null
        ? widget.options!.map((map) => Option.fromJson(map)).toList()
        : [];

    return FormField<Option>(
      validator: (value) {
        if (widget.required == true && (value == null || value.name.isEmpty)) {
          return 'Please select a value';
        }
        return null;
      },
      builder: (FormFieldState<Option> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButton<Option>(
                    isExpanded: true,
                    value: _selectedValues.isNotEmpty
                        ? optionsList.firstWhere(
                            (option) => option.name == _selectedValues.first)
                        : null,
                    items: optionsList.map((option) {
                      return DropdownMenuItem<Option>(
                        value: option,
                        child: Text(option.name),
                      );
                    }).toList(),
                    onChanged: (selectedOption) {
                      setState(() {
                        _selectedValues = [selectedOption!.name];
                        _selectedIds = [selectedOption.id];
                        widget.onChanged?.call(_selectedIds.first.toString());
                        state.didChange(
                            selectedOption); // Update FormField state
                      });
                    },
                  ),
                ),
                // Add Clear Button
                IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _selectedValues.clear();
                      _selectedIds.clear();
                      state.didChange(null); // Clear the state
                      widget.onChanged?.call(null); // Notify parent widget
                    });
                  },
                ),
              ],
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  state.errorText ?? '',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildValidatedMultiSelect() {
    final List<Option> optionsList = widget.options != null
        ? widget.options!.map((map) => Option.fromJson(map)).toList()
        : [];

    return FormField<List<Option>>(
      validator: (value) {
        if (widget.required == true && (value == null || value.isEmpty)) {
          return 'Please select at least one item';
        }
        return null;
      },
      builder: (FormFieldState<List<Option>> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: MultiSelectDialogField<Option>(
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
                        .where(
                            (option) => _selectedValues.contains(option.name))
                        .toList(),
                    items: optionsList
                        .map((option) =>
                            MultiSelectItem<Option>(option, option.name))
                        .toList(),
                    title: Text(widget.showName),
                    selectedColor: Color(0XFFEF5B2C),
                    onConfirm: (List<Option> results) {
                      setState(() {
                        _selectedIds =
                            results.map((option) => option.id).toList();
                        _selectedValues =
                            results.map((option) => option.name).toList();
                        state.didChange(results); // Update FormField state
                        widget.onChanged?.call(_selectedIds.join(', '));
                      });
                    },
                  ),
                ),
                // Add Clear Button
                IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _selectedValues.clear();
                      _selectedIds.clear();
                      state.didChange([]); // Clear the state
                      widget.onChanged?.call(null); // Notify parent widget
                    });
                  },
                ),
              ],
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  state.errorText ?? '',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        );
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
              : Text(
                  'اختر صورة',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () =>
                  _pickImage(ImageSource.gallery), // اختيار من المعرض
              icon: Icon(Icons.photo_library),
              label: Text('اختر من المعرض'),
            ),
            SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () =>
                  _pickImage(ImageSource.camera), // التقاط صورة بالكاميرا
              icon: Icon(Icons.camera),
              label: Text('التقاط صورة'),
            ),
          ],
        ),
        if (widget.required == true &&
            _selectedImage == null) // التحقق من الصورة إذا كانت مطلوبة
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
