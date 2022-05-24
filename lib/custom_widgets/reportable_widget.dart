import 'package:flutter/material.dart';

class ReportableWidget extends StatefulWidget {

  final Function()? violationCallback;

  Widget child;
  String? comment;
  //TODO: fix the setback to false when screen is rebuilt.
  bool isAViolation = false;

  ReportableWidget({required this.child, this.violationCallback});

  @override
  _ReportableWidgetState createState() => _ReportableWidgetState();
}

class _ReportableWidgetState extends State<ReportableWidget> {

  Color _backgroundColor = Colors.white;
  bool _isAViolation = false;
  TextEditingController reportViolationController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _backgroundColor,
      child: Row(
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.fromLTRB(10, 5, 40, 5),
              child: widget.child,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              child:
              _isAViolation ?
              IconButton(
                  iconSize: 30,
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.warning, color: Colors.red),
                  onPressed: () {
                    _reviewReportViolationDialog();
                  }) :
              IconButton(
                iconSize: 30,
                padding: EdgeInsets.zero,
                icon: Icon(Icons.add, color: Colors.blue),
                onPressed: () {
                  _showReportViolationDialog();
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  void _toggleViolation() {
    widget.violationCallback!();
    setState(() {
      widget.isAViolation = !_isAViolation;
      _isAViolation = !_isAViolation;
      if (widget.isAViolation) {
        _backgroundColor = Colors.orange;
      } else {
        _backgroundColor = Colors.white;
      }
    });
  }

  void _setComment(String value) {
    setState(() {
      widget.comment = value;
    });
  }

  void _showReportViolationDialog() {
    reportViolationController = new TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('What is the violation here?'),
            content: TextField(
              controller: reportViolationController,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(hintText: "Please enter and explain the violation."),
            ),
            actions: [
              MaterialButton(
                  onPressed: () {
                    _dismissDialog();
                  },
                  color: Colors.white,
                  child: Text('Cancel, no violation')
              ),
              MaterialButton(
                  onPressed: () {
                    _setComment(reportViolationController.text);
                    _toggleViolation();
                    _dismissDialog();
                  },
                  color: Colors.blue,
                  child: Text('Add violation', style: TextStyle(color: Colors.white))
              )
            ],
          );
        }
    );
  }

  void _reviewReportViolationDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Would you like to remove the entered violation below?'),
            content: Text(widget.comment!),
            actions: [
              MaterialButton(
                  onPressed: () {
                    _dismissDialog();
                  },
                  color: Colors.white,
                  child: Text('No, leave it')
              ),
              MaterialButton(
                  onPressed: () {
                    _setComment("");
                    _toggleViolation();
                    _dismissDialog();
                  },
                  color: Colors.red,
                  child: Text('Yes, delete', style: TextStyle(color: Colors.white))
              )
            ],
          );
        }
    );
  }

  _dismissDialog() {
    Navigator.pop(context);
  }

}